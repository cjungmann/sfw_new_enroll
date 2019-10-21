DELIMITER $$

-- -----------------------------------------
DROP PROCEDURE IF EXISTS App_User_Targets $$
CREATE PROCEDURE App_User_Targets()
BEGIN
   -- This query can be conditional to selectively
   -- include navigation options.
   SELECT t.label, t.url
     FROM Target t;
END $$

-- --------------------------------------
DROP PROCEDURE IF EXISTS App_User_Home $$
CREATE PROCEDURE App_User_Home()
BEGIN
   SELECT email
     FROM User
    WHERE id = @session_confirmed_id;

   CALL App_User_Targets();
END $$

-- ------------------------------------------------
DROP PROCEDURE IF EXISTS App_User_Profile_Values $$
CREATE PROCEDURE App_User_Profile_Values()
BEGIN
   SELECT id, fname, lname
     FROM User
    WHERE id = @session_confirmed_id;
END $$

-- ------------------------------------------------
DROP PROCEDURE IF EXISTS App_User_Profile_Update $$
CREATE PROCEDURE App_User_Profile_Update(id INT UNSIGNED, fname VARCHAR(30), lname VARCHAR(30))
BEGIN
   UPDATE User u
      SET u.fname = fname,
          u.lname = lname
    WHERE u.id = id;

    IF ROW_COUNT() = 0 THEN
       SELECT 1 AS error, 'Failed to save record.' AS msg;
    ELSE
       SELECT 0 AS error;
    END IF;
END $$

DELIMITER ;
