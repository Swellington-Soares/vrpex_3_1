-- --------------------------------------------------------
-- Servidor:                     localhost
-- Versão do servidor:           11.2.2-MariaDB-1:11.2.2+maria~ubu2204 - mariadb.org binary distribution
-- OS do Servidor:               debian-linux-gnu
-- HeidiSQL Versão:              12.8.0.6908
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

-- Copiando dados para a tabela vrpex.banned: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela vrpex.logs
CREATE TABLE IF NOT EXISTS `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `log_type` varchar(50) NOT NULL,
  `data` longtext NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela vrpex.logs: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela vrpex.players
CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `registration` varchar(8) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `birth_date` date NOT NULL,
  `money` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT json_object() CHECK (json_valid(`money`)),
  `inventory` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT json_array() CHECK (json_valid(`inventory`)),
  `datatable` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT json_object() CHECK (json_valid(`datatable`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `registration` (`registration`),
  UNIQUE KEY `phone` (`phone`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `FK__players_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela vrpex.players: ~2 rows (aproximadamente)

-- Copiando estrutura para tabela vrpex.player_data
CREATE TABLE IF NOT EXISTS `player_data` (
  `player_id` int(11) NOT NULL,
  `dkey` varchar(50) NOT NULL,
  `dvalue` longtext NOT NULL,
  UNIQUE KEY `player_id_dkey` (`player_id`,`dkey`),
  CONSTRAINT `FK__player_data_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela vrpex.player_data: ~2 rows (aproximadamente)

-- Copiando estrutura para tabela vrpex.player_vehicles
CREATE TABLE IF NOT EXISTS `player_vehicles` (
  `vehicle` varchar(30) NOT NULL,
  `player_id` int(11) NOT NULL,
  `seized` tinyint(1) DEFAULT 0,
  `properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT json_object() CHECK (json_valid(`properties`)),
  `plate` char(8) NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`vehicle`),
  UNIQUE KEY `vehicle_player_id` (`vehicle`,`player_id`),
  UNIQUE KEY `plate` (`plate`),
  KEY `FK__players_vehicles` (`player_id`),
  CONSTRAINT `FK__players_vehicles` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela vrpex.player_vehicles: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela vrpex.server_data
CREATE TABLE IF NOT EXISTS `server_data` (
  `dkey` varchar(50) NOT NULL,
  `dvalue` longtext DEFAULT NULL,
  UNIQUE KEY `dkey` (`dkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela vrpex.server_data: ~0 rows (aproximadamente)

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela vrpex.users: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela vrpex.user_data
CREATE TABLE IF NOT EXISTS `user_data` (
  `user_id` int(11) NOT NULL,
  `dkey` varchar(50) NOT NULL DEFAULT '',
  `dvalue` longtext NOT NULL,
  UNIQUE KEY `user_id_dkey` (`user_id`,`dkey`),
  CONSTRAINT `FK__user_data_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela vrpex.user_data: ~1 rows (aproximadamente)

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
	#VRPEX CORE
	DELETE FROM `logs`;
	DELETE FROM users;
	DELETE FROM server_data;
	ALTER TABLE users AUTO_INCREMENT=1;
	ALTER TABLE players AUTO_INCREMENT=1;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
