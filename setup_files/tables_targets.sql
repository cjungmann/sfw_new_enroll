CREATE TABLE IF NOT EXISTS Target
(
   id          INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
   id_category INT UNSIGNED,
   label       VARCHAR(80),
   url         VARCHAR(128),

   INDEX(id_category)
);

DELIMITER $$

-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS App_Targets_Initial_Populate $$
CREATE PROCEDURE App_Targets_Initial_Populate()
BEGIN
   DECLARE count INT UNSIGNED;

   SELECT COUNT(*) INTO count
     FROM Target;

   IF count = 0 THEN
      INSERT INTO Target (id_category, label, url)
         VALUES (1, "Admin Calendar", "admin_calendar.srm"),
                (1, "People", "people.srm"),
                (1, "Items", "items.srm");
   END IF;
END $$

DELIMITER ;


CALL App_Targets_Initial_Populate();

DROP PROCEDURE IF EXISTS App_Targets_Initial_Populate;
