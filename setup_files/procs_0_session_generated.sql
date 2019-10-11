
USE SFW_Enroll2;
DELIMITER $$
    
-- --------------------------------------------
-- System Session Procedure Override
-- --------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Cleanup $$
CREATE PROCEDURE App_Session_Cleanup()
BEGIN
   SELECT NULL
     INTO @session_id_user;
END $$
  
-- ------------------------------------------
-- System Session Procedure Override
-- ------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Start $$
CREATE PROCEDURE App_Session_Start(session_id INT UNSIGNED)
BEGIN
   INSERT INTO Session_Info(id_session)
          VALUES(session_id);
END $$
  
-- --------------------------------------------
-- System Session Procedure Override
-- --------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Restore $$
CREATE PROCEDURE App_Session_Restore(session_id INT UNSIGNED)
BEGIN
   SELECT id_user
     INTO @session_id_user
     FROM Session_Info
    WHERE id_session = session_id;
END $$
  
-- --------------------------------------------
-- System Session Procedure Override
-- --------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Abandon $$
CREATE PROCEDURE App_Session_Abandon(session_id INT UNSIGNED)
BEGIN
   DELETE FROM Session_Info
      WHERE id_session = session_id;
END $$
  
-- -----------------------------------------------
-- Call this procedure at a successful login
-- -----------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Initialize $$
CREATE PROCEDURE App_Session_Initialize(id_user INT(10) UNSIGNED)
BEGIN
   UPDATE Session_Info s
      SET s.id_user = id_user
    WHERE s.id_session = @session_confirmed_id;

   SELECT id_user
     INTO @session_id_user;
   
END $$
  
-- --------------------------------------------
-- Procedure to check for existing session.
-- --------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Confirm $$
CREATE PROCEDURE App_Session_Confirm(session_id INT UNSIGNED)
BEGIN
   SELECT COUNT(*)
     FROM Session_Info
    WHERE id_session = session_id;
END $$
  
-- -----------------------------------------------
-- Sets the persistent 'id_user' session value.
-- -----------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Set_id_user $$
CREATE PROCEDURE App_Session_Set_id_user(val INT(10) UNSIGNED)
BEGIN
   SET @session_id_user = val;
   UPDATE Session_Info
      SET id_user = val
    WHERE id_session = @session_confirmed_id;
END $$
  
DELIMITER ;
  