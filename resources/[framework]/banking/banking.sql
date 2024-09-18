CREATE TABLE `okokBanking_transactions`	(
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`receiver_identifier` varchar(255) NOT NULL,
	`receiver_name` varchar(255) NOT NULL,
	`sender_identifier` varchar(255) NOT NULL,
	`sender_name` varchar(255) NOT NULL,
	`date` varchar(255) NOT NULL,
	`value` int(50) NOT NULL,
	`type` varchar(255) NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `okokBanking_societies`	(
  `society` varchar(255) NULL DEFAULT NULL,
	`society_name` varchar(255) NULL DEFAULT NULL,
	`value` int(50) NULL DEFAULT NULL,
	`iban` varchar(255) NOT NULL,
	`is_withdrawing` int(1) NULL DEFAULT NULL
);

ALTER TABLE `players` ADD COLUMN `iban` varchar(255) NULL DEFAULT NULL;

ALTER TABLE `players` ADD COLUMN `pincode` int(50) NULL DEFAULT NULL;