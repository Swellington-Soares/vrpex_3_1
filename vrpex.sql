-- --------------------------------------------------------
-- Servidor:                     localhost
-- Versão do servidor:           11.2.2-MariaDB-1:11.2.2+maria~ubu2204 - mariadb.org binary distribution
-- OS do Servidor:               debian-linux-gnu
-- HeidiSQL Versão:              12.8.0.6935
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Copiando estrutura do banco de dados para vrpex
CREATE DATABASE IF NOT EXISTS `vrpex` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
USE `vrpex`;

-- Copiando estrutura para tabela vrpex.banned
CREATE TABLE IF NOT EXISTS `banned` (
  `user_id` int(11) NOT NULL,
  `reason` longtext DEFAULT 'banned from server by anti-cheat',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`) USING BTREE,
  CONSTRAINT `FK_banned_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.logs
CREATE TABLE IF NOT EXISTS `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `log_type` varchar(50) NOT NULL,
  `data` longtext NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_bolos
CREATE TABLE IF NOT EXISTS `mdt_bolos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(50) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `plate` varchar(50) DEFAULT NULL,
  `owner` varchar(50) DEFAULT NULL,
  `individual` varchar(50) DEFAULT NULL,
  `detail` text DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `gallery` text DEFAULT NULL,
  `officersinvolved` text DEFAULT NULL,
  `time` varchar(20) DEFAULT NULL,
  `jobtype` varchar(25) NOT NULL DEFAULT 'police',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_bulletin
CREATE TABLE IF NOT EXISTS `mdt_bulletin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text NOT NULL,
  `desc` text NOT NULL,
  `author` varchar(50) NOT NULL,
  `time` varchar(20) NOT NULL,
  `jobtype` varchar(25) DEFAULT 'police',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_clocking
CREATE TABLE IF NOT EXISTS `mdt_clocking` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL DEFAULT '',
  `firstname` varchar(255) NOT NULL DEFAULT '',
  `lastname` varchar(255) NOT NULL DEFAULT '',
  `clock_in_time` varchar(255) NOT NULL DEFAULT '',
  `clock_out_time` varchar(50) DEFAULT NULL,
  `total_time` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`) USING BTREE,
  KEY `id` (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_convictions
CREATE TABLE IF NOT EXISTS `mdt_convictions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) DEFAULT NULL,
  `linkedincident` int(11) NOT NULL DEFAULT 0,
  `warrant` varchar(50) DEFAULT NULL,
  `guilty` varchar(50) DEFAULT NULL,
  `processed` varchar(50) DEFAULT NULL,
  `associated` varchar(50) DEFAULT '0',
  `charges` text DEFAULT NULL,
  `fine` int(11) DEFAULT 0,
  `sentence` int(11) DEFAULT 0,
  `recfine` int(11) DEFAULT 0,
  `recsentence` int(11) DEFAULT 0,
  `time` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_data
CREATE TABLE IF NOT EXISTS `mdt_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `information` mediumtext DEFAULT NULL,
  `tags` text NOT NULL,
  `gallery` text NOT NULL,
  `jobtype` varchar(25) DEFAULT 'police',
  `pfp` text DEFAULT NULL,
  `fingerprint` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`cid`),
  KEY `id` (`id`),
  CONSTRAINT `FK_mdt_data_players` FOREIGN KEY (`cid`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_impound
CREATE TABLE IF NOT EXISTS `mdt_impound` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vehicleid` int(11) NOT NULL,
  `linkedreport` int(11) NOT NULL,
  `fee` int(11) DEFAULT NULL,
  `time` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_incidents
CREATE TABLE IF NOT EXISTS `mdt_incidents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(50) NOT NULL DEFAULT '',
  `title` varchar(50) NOT NULL DEFAULT '0',
  `details` longtext NOT NULL,
  `tags` text NOT NULL,
  `officersinvolved` text NOT NULL,
  `civsinvolved` text NOT NULL,
  `evidence` text NOT NULL,
  `time` varchar(20) DEFAULT NULL,
  `jobtype` varchar(25) NOT NULL DEFAULT 'police',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_logs
CREATE TABLE IF NOT EXISTS `mdt_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` text NOT NULL,
  `time` varchar(20) DEFAULT NULL,
  `jobtype` varchar(25) DEFAULT 'police',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_reports
CREATE TABLE IF NOT EXISTS `mdt_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(50) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `details` longtext DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `officersinvolved` text DEFAULT NULL,
  `civsinvolved` text DEFAULT NULL,
  `gallery` text DEFAULT NULL,
  `time` varchar(20) DEFAULT NULL,
  `jobtype` varchar(25) DEFAULT 'police',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_vehicleinfo
CREATE TABLE IF NOT EXISTS `mdt_vehicleinfo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plate` varchar(50) DEFAULT NULL,
  `information` text NOT NULL DEFAULT '',
  `stolen` tinyint(1) NOT NULL DEFAULT 0,
  `code5` tinyint(1) NOT NULL DEFAULT 0,
  `image` text NOT NULL DEFAULT '',
  `points` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.mdt_weaponinfo
CREATE TABLE IF NOT EXISTS `mdt_weaponinfo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `serial` varchar(50) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `information` text NOT NULL DEFAULT '',
  `weapClass` varchar(50) DEFAULT NULL,
  `weapModel` varchar(50) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial` (`serial`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.okokBanking_societies
CREATE TABLE IF NOT EXISTS `okokBanking_societies` (
  `society` varchar(255) DEFAULT NULL,
  `society_name` varchar(255) DEFAULT NULL,
  `value` int(50) DEFAULT NULL,
  `iban` varchar(255) NOT NULL,
  `is_withdrawing` int(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.okokBanking_transactions
CREATE TABLE IF NOT EXISTS `okokBanking_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `receiver_identifier` varchar(255) NOT NULL,
  `receiver_name` varchar(255) NOT NULL,
  `sender_identifier` varchar(255) NOT NULL,
  `sender_name` varchar(255) NOT NULL,
  `date` varchar(255) NOT NULL,
  `value` int(50) NOT NULL,
  `type` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.ox_inventory
CREATE TABLE IF NOT EXISTS `ox_inventory` (
  `owner` varchar(60) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `data` longtext DEFAULT NULL,
  `lastupdated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  UNIQUE KEY `owner` (`owner`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.players
CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `registration` varchar(8) NOT NULL,
  `gender` enum('M','F','TF','TM') NOT NULL DEFAULT 'M',
  `phone` varchar(10) NOT NULL,
  `birth_date` date NOT NULL,
  `money` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT json_object() CHECK (json_valid(`money`)),
  `inventory` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT json_array() CHECK (json_valid(`inventory`)),
  `datatable` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT json_object() CHECK (json_valid(`datatable`)),
  `skin` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`skin`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  `iban` varchar(255) DEFAULT NULL,
  `pincode` int(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `registration` (`registration`),
  UNIQUE KEY `phone` (`phone`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `FK__players_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.player_data
CREATE TABLE IF NOT EXISTS `player_data` (
  `player_id` int(11) NOT NULL,
  `dkey` varchar(50) NOT NULL,
  `dvalue` longtext NOT NULL,
  UNIQUE KEY `player_id_dkey` (`player_id`,`dkey`),
  CONSTRAINT `FK__player_data_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.player_vehicles
CREATE TABLE IF NOT EXISTS `player_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vehicle` varchar(30) NOT NULL,
  `player_id` int(11) NOT NULL,
  `seized` tinyint(1) DEFAULT 0,
  `properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT json_object() CHECK (json_valid(`properties`)),
  `plate` char(8) NOT NULL DEFAULT '',
  `garage` varchar(50) DEFAULT NULL,
  `gear_type` enum('GEAR_AUTO','GEAR_MANUAL') NOT NULL DEFAULT 'GEAR_AUTO',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `glovebox` longtext DEFAULT NULL,
  `trunk` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vehicle_player_id` (`vehicle`,`player_id`),
  UNIQUE KEY `plate` (`plate`),
  KEY `FK__players_vehicles` (`player_id`),
  KEY `garage` (`garage`),
  CONSTRAINT `FK__players_vehicles` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.properties
CREATE TABLE IF NOT EXISTS `properties` (
  `property_id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_citizenid` int(11) DEFAULT NULL,
  `street` varchar(100) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `has_access` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT json_array() CHECK (json_valid(`has_access`)),
  `extra_imgs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT json_array() CHECK (json_valid(`extra_imgs`)),
  `furnitures` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT json_array() CHECK (json_valid(`furnitures`)),
  `for_sale` tinyint(1) NOT NULL DEFAULT 1,
  `price` int(11) NOT NULL DEFAULT 0,
  `shell` varchar(50) NOT NULL,
  `apartment` varchar(50) DEFAULT NULL,
  `door_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`door_data`)),
  `garage_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`garage_data`)),
  `zone_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`zone_data`)),
  PRIMARY KEY (`property_id`),
  UNIQUE KEY `UQ_owner_apartment` (`owner_citizenid`,`apartment`),
  CONSTRAINT `FK_properties_players` FOREIGN KEY (`owner_citizenid`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.server_data
CREATE TABLE IF NOT EXISTS `server_data` (
  `dkey` varchar(50) NOT NULL,
  `dvalue` longtext DEFAULT NULL,
  UNIQUE KEY `dkey` (`dkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.sw_vehicleshop
CREATE TABLE IF NOT EXISTS `sw_vehicleshop` (
  `vehicle` varchar(50) NOT NULL,
  `price` bigint(20) DEFAULT NULL,
  `shop` varchar(50) NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `max_speed` decimal(5,2) DEFAULT 0.00,
  `traction` decimal(5,2) DEFAULT 0.00,
  `acceleration` decimal(5,2) DEFAULT 0.00,
  `agility` decimal(5,2) DEFAULT 0.00,
  `seats` int(11) DEFAULT 1,
  `trunk` int(11) DEFAULT 0,
  PRIMARY KEY (`vehicle`),
  KEY `shop` (`shop`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allowed` tinyint(1) NOT NULL DEFAULT 0,
  `license` varchar(80) NOT NULL,
  `discord` varchar(50) NOT NULL,
  `fivem_id` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `license` (`license`),
  UNIQUE KEY `discord` (`discord`),
  UNIQUE KEY `fivem_id` (`fivem_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela vrpex.user_data
CREATE TABLE IF NOT EXISTS `user_data` (
  `user_id` int(11) NOT NULL,
  `dkey` varchar(50) NOT NULL DEFAULT '',
  `dvalue` longtext NOT NULL,
  UNIQUE KEY `user_id_dkey` (`user_id`,`dkey`),
  CONSTRAINT `FK__user_data_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para view vrpex.vplayers
-- Criando tabela temporária para evitar erros de dependência de VIEW
CREATE TABLE `vplayers` (
	`id` INT(11) NOT NULL,
	`user_id` INT(11) NOT NULL,
	`license` VARCHAR(1) NULL COLLATE 'utf8mb4_unicode_ci',
	`firstname` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`lastname` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`registration` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`gender` ENUM('M','F','TF','TM') NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`phone` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`birth_date` DATE NOT NULL,
	`money` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
	`skin` LONGTEXT NULL COLLATE 'utf8mb4_bin',
	`datatable` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
	`created_at` TIMESTAMP NOT NULL,
	`deleted_at` TIMESTAMP NULL,
	`iban` VARCHAR(1) NULL COLLATE 'utf8mb4_unicode_ci',
	`pincode` INT(50) NULL
) ENGINE=MyISAM;

-- Copiando estrutura para procedure vrpex.add_player_vehicle
DELIMITER //
CREATE PROCEDURE `add_player_vehicle`(
	IN `p_vehicle` VARCHAR(50),
	IN `p_player_id` INT,
	IN `p_plate` CHAR(8)
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	BEGIN
		ROLLBACK;
		SELECT CONCAT('Não foi adicionar o veículo ', p_vehicle, ' para o player ', p_player_id) AS `message`;
	END;	
	START TRANSACTION;
	
	INSERT INTO player_vehicles (vehicle, player_id, seized, plate) VALUES (p_vehicle, p_player_id, 0, UPPER(p_plate));		
	COMMIT;
	
	SELECT 'Veículo adicionado com sucesso.' AS `message`; 
END//
DELIMITER ;

-- Copiando estrutura para procedure vrpex.transfer_player_vehicle
DELIMITER //
CREATE PROCEDURE `transfer_player_vehicle`(
	IN `p_vehicle` VARCHAR(50),
	IN `p_player_from` INT,
	IN `p_player_to` INT
)
`transfer_player_vehicle`:
BEGIN
	DECLARE v_user_from INT;
	DECLARE v_user_to INT;
	DECLARE is_seized TINYINT(1);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SELECT 'Não foi possível fazer a transferência do veículo' AS `message`;
	END;
	
	START TRANSACTION;
	
	IF p_player_from = p_player_to THEN
		ROLLBACK;
		SELECT 'Não é possível transferir o seu veículo para si mesmo.' AS `message`;
		LEAVE `transfer_player_vehicle`;
	END IF;
	
	IF NOT EXISTS(SELECT 1 FROM player_vehicles WHERE vehicle = LOWER(p_vehicle) AND player_id = p_player_from) THEN
		ROLLBACK;
		SELECT 'Veículo não disponível para transferência.' AS `message`;
		LEAVE `transfer_player_vehicle`;
	END IF;
	
	IF EXISTS(SELECT 1 FROM player_vehicles WHERE vehicle = LOWER(p_vehicle) AND player_id = p_player_to) THEN
		ROLLBACK;
		SELECT 'O outro player já possui o mesmo veículo' AS `message`;
		LEAVE `transfer_player_vehicle`;
	END IF;
	
	SELECT user_id into v_user_from FROM players WHERE id = p_player_from;
	SELECT user_id INTO v_user_to FROM players WHERE id = p_player_to;
	SELECT seized INTO is_seized FROM player_vehicles WHERE vehicle = LOWER(p_vehicle) AND player_id = p_player_from;
   
   IF is_seized = TRUE then
   	ROLLBACK;
		SELECT 'Veículo apreendido, não podem ser transferido.' AS `message`;
		LEAVE `transfer_player_vehicle`;
   END IF;
   
   IF v_user_from IS null THEN
   	SELECT CONCAT('Player com Id ', p_player_from, ' não encontrado.') AS `message`;
   	ROLLBACK;
	   LEAVE `transfer_player_vehicle`;
   END IF;
   
   IF v_user_to IS null THEN
   	SELECT CONCAT('Player com Id ', p_player_to, ' não encontrado.') AS `message`;
   	ROLLBACK;
	   LEAVE `transfer_player_vehicle`;
   END IF;

	IF v_user_to = v_user_from THEN
   	SELECT 'Veículo não pode ser transferido entre personagens da mesma conta' AS `message`;
   	ROLLBACK;
	   LEAVE `transfer_player_vehicle`;
   END IF;

	UPDATE player_vehicles SET player_id = p_player_to WHERE player_id = p_player_from AND vehicle = LOWER(p_vehicle);
	
	COMMIT;
	
	SELECT 'Transferência realizada com sucesso.' AS `message`;
	
END//
DELIMITER ;

-- Copiando estrutura para procedure vrpex.wipe
DELIMITER //
CREATE PROCEDURE `wipe`()
BEGIN
	#ps-mdt
	DELETE FROM mdt_convictions; 
	DELETE FROM mdt_data; 
	DELETE FROM mdt_logs; 
	DELETE FROM mdt_bolos; 
	DELETE FROM mdt_incidents; 
	DELETE FROM mdt_vehicleinfo; 
	DELETE FROM mdt_clocking; 
	DELETE FROM mdt_reports; 
	DELETE FROM mdt_bulletin; 
	DELETE FROM mdt_weaponinfo; 
	DELETE FROM mdt_impound; 
	#ps-housing
	DELETE FROM properties;
	
	#ox_inventort
	DELETE FROM ox_inventory;
	
	DELETE FROM okokBanking_societies;
	DELETE FROM okokBanking_transactions;
	
	#VRPEX CORE
	DELETE FROM `logs`;
	DELETE FROM users;
	DELETE FROM server_data;
	ALTER TABLE users AUTO_INCREMENT=1;
	ALTER TABLE players AUTO_INCREMENT=1;	
	ALTER TABLE mdt_data AUTO_INCREMENT=1;
	ALTER TABLE mdt_bolos AUTO_INCREMENT=1;
	ALTER TABLE mdt_bulletin AUTO_INCREMENT=1;
	ALTER TABLE mdt_clocking AUTO_INCREMENT=1;
	ALTER TABLE mdt_impound AUTO_INCREMENT=1;
	ALTER TABLE mdt_incidents AUTO_INCREMENT=1;
	ALTER TABLE mdt_logs AUTO_INCREMENT=1;
	ALTER TABLE mdt_reports AUTO_INCREMENT=1;
	ALTER TABLE mdt_vehicleinfo AUTO_INCREMENT=1;
	ALTER TABLE mdt_weaponinfo AUTO_INCREMENT=1;
	ALTER TABLE okokBanking_transactions AUTO_INCREMENT = 1;
	
	ALTER TABLE `logs` AUTO_INCREMENT=1;
	
END//
DELIMITER ;

-- Removendo tabela temporária e criando a estrutura VIEW final
DROP TABLE IF EXISTS `vplayers`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vplayers` AS select `players`.`id` AS `id`,`players`.`user_id` AS `user_id`,(select `users`.`license` from `users` where `users`.`id` = `players`.`user_id`) AS `license`,`players`.`firstname` AS `firstname`,`players`.`lastname` AS `lastname`,`players`.`registration` AS `registration`,`players`.`gender` AS `gender`,`players`.`phone` AS `phone`,`players`.`birth_date` AS `birth_date`,`players`.`money` AS `money`,`players`.`skin` AS `skin`,`players`.`datatable` AS `datatable`,`players`.`created_at` AS `created_at`,`players`.`deleted_at` AS `deleted_at`,`players`.`iban` AS `iban`,`players`.`pincode` AS `pincode` from `players`;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
