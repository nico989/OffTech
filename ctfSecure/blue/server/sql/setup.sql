CREATE DATABASE ourdb;
USE ourdb;

CREATE TABLE users_secure_table (
    username CHAR(20) NOT NULL, 
    password CHAR(200) NOT NULL, 
    PRIMARY KEY (username)
);

CREATE TABLE transfers_secure_table_random (
    id MEDIUMINT NOT NULL AUTO_INCREMENT, 
    username CHAR(20) NOT NULL, 
    amount INT NOT NULL, 
    timestamp DATETIME NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (username) REFERENCES users_secure_table(username)
);

INSERT INTO users_secure_table VALUES('jelena','1b17ad46d4fd647e39546deda1e53c2673479b6e15369d6034dcd0b6d90707ec6b75d68c34b418fb254f388b7524a6696a1f146a44fdc8fd25d140fac84a0aef');
INSERT INTO users_secure_table VALUES('john','b8b26a7541f9f740da77e57344c8a50c08c1fbe05fedfdebe1c303db99d1b24afa9a160105931211c74f3b36d25e27efbc4d96faca5db94efe1c0ccb0592eaf8');
INSERT INTO users_secure_table VALUES('kate','e77b15f22de1e06d5b9d71d6bae2f69eef495ef2c5a38cf7b634ed5936946accd246e5deed017688fd0a3848b60ae45e1b5640282c4db204a41b08bfcba9dc49');

SET time_zone = "+1:00";
INSERT INTO transfers_secure_table_random (username, amount, timestamp) VALUES ('jelena','100', now());
INSERT INTO transfers_secure_table_random (username, amount, timestamp) VALUES ('john','100', now());
INSERT INTO transfers_secure_table_random (username, amount, timestamp) VALUES ('kate','300', now());

CREATE USER 'offtech'@'localhost' IDENTIFIED WITH mysql_native_password by 'UnRsqUlTE3lufZR09gw2';
GRANT SELECT ON ourdb.transfers_secure_table_random TO 'offtech'@'localhost';
GRANT SELECT ON ourdb.users_secure_table TO 'offtech'@'localhost';
GRANT INSERT ON ourdb.transfers_secure_table_random TO 'offtech'@'localhost';
GRANT INSERT ON ourdb.users_secure_table TO 'offtech'@'localhost';
FLUSH PRIVILEGES;
