DELIMITER $$

-- -----------------------------------------------
DROP FUNCTION IF EXISTS App_User_Password_Check $$
CREATE FUNCTION App_User_Password_Check(id_user INT UNSIGNED, password VARCHAR(30))
RETURNS BOOLEAN
BEGIN
   DECLARE pcount INT UNSIGNED;
   SELECT COUNT(*) INTO pcount
     FROM User u
          INNER JOIN Salt s ON u.id = s.id_user
    WHERE u.id = id_user
      AND u.pword_hash = ssys_hash_password_with_salt(password, s.salt);

   RETURN pcount=1;
END $$

-- ----------------------------------------------
DROP PROCEDURE IF EXISTS App_User_Password_Set $$
CREATE PROCEDURE App_User_Password_Set(user_id INT UNSIGNED, password VARCHAR(30))
BEGIN
   DECLARE new_salt CHAR(32) DEFAULT make_randstr(32);
   DECLARE scount INT UNSIGNED;
   DECLARE new_hash BINARY(16) DEFAULT ssys_hash_password_with_salt(password, new_salt);

   SELECT COUNT(*) INTO scount
     FROM Salt
    WHERE id_user = user_id;

   IF scount = 0 THEN
      INSERT INTO Salt (id_user, salt)
             VALUES(user_id, new_salt);

      UPDATE User
         SET pword_hash = new_hash
       WHERE id = user_id;
   ELSE
      UPDATE User u
             INNER JOIN Salt s on u.id = s.id_user
         SET s.salt = new_salt,
             u.pword_hash = new_hash
       WHERE u.id = user_id;
   END IF;
END $$
     

-- ---------------------------------------
DROP PROCEDURE IF EXISTS App_User_Login $$
CREATE PROCEDURE App_User_Login(email VARCHAR(128), password VARCHAR(30))
proc_block: BEGIN
   DECLARE user_id INT UNSIGNED;

   IF NOT (ssys_current_session_is_valid()) THEN
      SELECT 1 AS error, 'The session has expired.' AS msg;
      LEAVE proc_block;
   END IF;

   SELECT u.id INTO user_id
     FROM User u
    WHERE u.email = email;

   IF user_id IS NULL OR NOT(App_User_Password_Check(user_id, password)) THEN
      SELECT 2 AS error, 'The login email or password is invalid.' AS msg;
      LEAVE proc_block;
   END IF;

   CALL App_Session_Initialize(user_id);
   SELECT 0 AS error;
END $$

-- ------------------------------------------
DROP PROCEDURE IF EXISTS App_User_Register $$
CREATE PROCEDURE App_User_Register(email VARCHAR(128), password VARCHAR(30))
proc_block: BEGIN
   DECLARE email_count INT UNSIGNED;
   DECLARE user_id INT UNSIGNED;

   SELECT COUNT(*) INTO email_count
     FROM User u
    WHERE u.email = email;

   IF email_count > 0 THEN
      SELECT 1 AS error, 'This email is already in use.' AS msg;
      LEAVE proc_block;
   END IF;

   INSERT INTO User (email)
      VALUES(email);

   IF ROW_COUNT() > 0 THEN
      SELECT LAST_INSERT_ID() INTO user_id;
      CALL App_User_Password_Set(user_id, password);
      CALL App_Session_Initialize(user_id);
      SELECT 0 AS error;
   END IF;
   
END $$

-- ----------------------------------------
DROP PROCEDURE IF EXISTS App_User_Logout $$
CREATE PROCEDURE App_User_Logout()
BEGIN
   CALL App_Session_Abandon(@session_confirmed_id);
   SELECT 2 AS jump;
END $$

-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS App_User_Password_Request_Rescue $$
CREATE PROCEDURE App_User_Password_Request_Rescue(email VARCHAR(128))
BEGIN
   DECLARE new_code CHAR(6) DEFAULT make_randstr(6);
   DECLARE user_id INT UNSIGNED;
   DECLARE new_expires DATETIME DEFAULT ADDTIME(NOW(),'0:20:0');
   DECLARE attempts_allowed INT UNSIGNED DEFAULT 8;

   DECLARE rowcount INT UNSIGNED;

   SELECT u.id INTO user_id
     FROM User u
    WHERE u.email = email;

   IF user_id IS NOT NULL THEN
      UPDATE Password_Reset pw
         SET pw.code = new_code,
             pw.expires = new_expires,
             pw.attempts_left = attempts_allowed
       WHERE pw.id_user = user_id;

      SELECT ROW_COUNT() INTO rowcount;

      IF rowcount = 0 THEN
         INSERT
           INTO Password_Reset (id_user, code, email, expires, attempts_left)
         VALUES (user_id,
                 new_code,
                 email,
                 new_expires,
                 attempts_allowed);

         SELECT ROW_COUNT() INTO rowcount;
      END IF;

      IF rowcount = 0 THEN
         SELECT 1 AS error, 'Password rescue code failed.  Try again later.' AS msg;
      ELSE
         -- Use error=1 because error=0 goes to Home.srm
         SELECT 1 AS error, 'Password rescue code will be sent to your email.' AS msg;
      END IF;
   ELSE
      SELECT 1 AS error, 'That email is not recognized.' AS msg;
   END IF;
END $$

-- ------------------------------------------------------
DROP PROCEDURE IF EXISTS App_User_Password_Rescue $$
CREATE PROCEDURE App_User_Password_Rescue(email VARCHAR(128),
                                          code CHAR(6),
                                          password VARCHAR(30))
BEGIN
   DECLARE user_id INT UNSIGNED;
   DECLARE saved_code CHAR(6);
   DECLARE expires DATETIME;
   DECLARE attempts_left INT UNSIGNED;

   SELECT pr.id_user, pr.code, pr.expires, pr.attempts_left
     INTO user_id, saved_code, expires, attempts_left
     FROM Password_Reset pr
    WHERE pr.email = email;

   IF user_id IS NULL THEN
      SELECT 1 AS error, 'Unrecognized email.' AS msg;
   ELSEIF expires < NOW() OR attempts_left < 1 THEN
      SELECT 1 AS error, 'Password rescue code has expired.' AS msg;

      DELETE FROM pr USING Password_Reset AS pr
       WHERE pr.id_user = user_id;

   ELSEIF STRCMP(saved_code, code) THEN
      SET attempts_left = attempts_left - 1;
      IF attempts_left = 0 THEN
         SELECT 1 AS error, 'Incorrect code.  That was the final allowed attempt.' AS msg;

         DELETE FROM pr USING Password_Reset AS pr
          WHERE pr.id_user = user_id;
      ELSE
         SELECT 1 AS error, CONCAT('Incorrect code. ', attempts_left, ' attempts remaining.') AS msg;

         UPDATE Password_Reset pr
            SET pr.attempts_left = attempts_left
          WHERE pr.id_user = user_id;
      END IF;
   ELSE
      CALL App_User_Password_Set(user_id, password);
      SELECT 0 AS error, 'Password set.' AS msg;

      DELETE FROM pr USING Password_Reset AS pr
       WHERE pr.id_user = user_id;
   END IF;
END $$

-- -------------------------------------------------
DROP PROCEDURE IF EXISTS App_User_Password_Change $$
CREATE PROCEDURE App_User_Password_Change(original VARCHAR(30),
                                          new_password VARCHAR(30))
BEGIN
   DECLARE user_id INT UNSIGNED;

   SELECT u.id INTO user_id
     FROM User u
          INNER JOIN Salt s ON u.id = s.id_user
    WHERE u.pword_hash = ssys_hash_password_with_salt(original, s.salt);

   IF user_id IS NULL THEN
      SELECT 1 AS error, 'Incorrect password.' AS msg;
   ELSE
      CALL App_User_Password_Set(user_id, new_password);
      SELECT 0 AS error, 'Password changed.' AS msg;
   END IF;
END $$

-- ----------------------------------------------------
DROP PROCEDURE IF EXISTS App_Password_Rescues_To_Send $$
CREATE PROCEDURE App_Password_Rescues_To_Send()
BEGIN
   SELECT id_user, email, code
     FROM Password_Reset
    WHERE emailed IS NULL;
END $$

-- -------------------------------------------------
DROP PROCEDURE IF EXISTS App_Password_Rescues_Sent $$
CREATE PROCEDURE App_Password_Rescues_Sent(ids_sent TEXT)
BEGIN
   DECLARE dnow DATETIME DEFAULT NOW();

   CALL ssys_make_SFW_IntTable_from_list(ids_sent);

   UPDATE Password_Reset
      SET emailed = dnow
    WHERE id_user IN (SELECT val FROM SFW_IntTable);

   DROP TABLE SFW_IntTable;
END $$

DELIMITER ;
