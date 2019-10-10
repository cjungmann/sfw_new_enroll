DELIMITER $$

-- The procedures defined in this script must follow after
-- the procedures in procs_0_session.sql that were generated
-- using the **gensfw_session_procs** command, but before
-- any procedures that need to access the contained procedures

-- ------------------------------------------------
-- Template for admin-restricted SRM response modes.
--
-- Replace the commented-out AND admin_session_flag
-- clause with appropriate filters to confirm admin
-- privileges.
-- --------------------------------------------
DROP PROCEDURE IF EXISTS App_Admin_Confirm $$
CREATE PROCEDURE App_Admin_Confirm(session_id INT UNSIGNED)
BEGIN

   SELECT COUNT(*)
     FROM Session_Info
    WHERE id_session = session_id
      -- AND admin_session_flag
      ;

END $$


DELIMITER ;
