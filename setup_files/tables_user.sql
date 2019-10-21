CREATE TABLE IF NOT EXISTS User
(
   -- fundamental fields to track user
   id         INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
   email      VARCHAR(128) UNIQUE,
   pword_hash BINARY(16) NULL,

   -- extra fields for profile
   fname      VARCHAR(30),
   lname      VARCHAR(30),

   INDEX(email)
);

CREATE TABLE IF NOT EXISTS Salt
(
   id_user  INT UNSIGNED NOT NULL PRIMARY KEY,
   salt     CHAR(32)
);

CREATE TABLE IF NOT EXISTS Password_Reset
(
   id_user       INT UNSIGNED NOT NULL PRIMARY KEY,
   email         VARCHAR(128) UNIQUE,
   code          CHAR(6),
   expires       DATETIME,
   attempts_left INT UNSIGNED,
   emailed       DATETIME NULL,

   INDEX(id_user),
   INDEX(email),
   INDEX(emailed)
);

CREATE TABLE IF NOT EXISTS Session_Info
(
   id_session INT UNSIGNED UNIQUE KEY,
   id_user    INT UNSIGNED NULL
);
