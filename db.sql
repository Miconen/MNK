/* *************** Users *************** */
CREATE TABLE users
(
 name         character varying(16) NOT NULL,
 password     character varying(64) NOT NULL,
 role         character varying(8) NOT NULL,
 CONSTRAINT   PK_User PRIMARY KEY ( name )
);

/* *************** Chats *************** */
CREATE TABLE chats
(
 "Id"         integer NOT NULL GENERATED ALWAYS AS IDENTITY,
 name bit     varying(64) NOT NULL,
 CONSTRAINT   PK_ChatId PRIMARY KEY ( "Id" )
);

/* *************** Messages *************** */
CREATE TABLE Messages
(
 "Id"         integer NOT NULL,
 creationdate character varying(64) NOT NULL,
 chat         integer NOT NULL,
 content      character varying(2048) NOT NULL,
 type         character varying(8) NOT NULL,
 author       character varying(16) NOT NULL,
 CONSTRAINT   PK_MessageId PRIMARY KEY ( "Id" ),
 CONSTRAINT   FK_UserMessages FOREIGN KEY ( author ) REFERENCES Users ( name ),
 CONSTRAINT   FK_ChatMessages FOREIGN KEY ( chat ) REFERENCES Chats ( "Id" )
);

CREATE INDEX FK_UserMessages ON Messages
(
 author
);

CREATE INDEX FK_ChatMessages ON Messages
(
 chat
);
