lib.print.info('Initializing queries register')

vRP.prepare('vRP/create_user', 'INSERT INTO users (license, discord, fivem_id)	VALUES (?, ?, ?)')
vRP.prepare('vRP/getUser', 'SELECT * FROM users WHERE license = ?')

vRP.prepare('vRP/setUData', 'REPLACE INTO user_data (user_id, dkey, dvalue) VALUES (?, ?, ?)')
vRP.prepare('vRP/getUData', 'SELECT dvalue FROM user_data WHERE user_id = ? AND dkey = ?')

vRP.prepare('vRP/setPlayerData', 'REPLACE INTO player_data (player_id, dkey, dvalue) VALUES (?, ?, ?)')
vRP.prepare('vRP/getPlayerData', 'SELECT dvalue FROM player_data WHERE player_id = ? AND dkey = ?')


vRP.prepare('vRP/setServerData', 'REPLACE INTO server_data (dkey, dvalue) VALUES (?, ?)')
vRP.prepare('vRP/getServerData', 'SELECT dvalue FROM server_data WHERE dkey = ?')

vRP.prepare('vRP/setUserAllowed', 'UPDATE users	SET allowed=? WHERE id = ?')
vRP.prepare('vRP/setUserBanned', 'REPLACE INTO banned (user_id, reason) VALUES (?, ?)')
vRP.prepare('vRP/removeUserBan', 'DELETE FROM banned WHERE user_id = ?')
vRP.prepare('vRP/getUserBanned', 'SELECT * FROM banned WHERE user_id = ?')
vRP.prepare('vRP/isUserAllowed', 'SELECT allowed FROM users WHERE id = ?')

vRP.prepare('vRP/addPlayerVehicle', 'CALL `add_player_vehicle`(?, ?, ?)')
vRP.prepare('vRP/removeVehicleFromPlayer', 'DELETE FROM player_vehicles WHERE vehicle = ? AND player_id = ?')
vRP.prepare('vRP/updatePlayerVehicleProperties', 'UPDATE player_vehicles SET properties = ? WHERE vehicle = ? AND player_id = ?')
vRP.prepare('vRP/transferPlayerVehicle', 'CALL `transfer_player_vehicle(?, ?, ?)`')
vRP.prepare('vRP/getPlayerVehicleBy', 'SELECT vehicle, seized, plate, garage, created_at FROM player_vehicles WHERE ?? = ? and player_id = ?')
vRP.prepare('vRP/isPlayerVehicleSeized', 'SELECT seized FROM player_vehicles WHERE player_id = ? and vehicle = ?')
vRP.prepare('vRP/getPlayerVehicleByPlate', 'SELECT vehicle, seized, plate, garage, created_at FROM player_vehicles WHERE plate = ?')
vRP.prepare('vRP/getPlayerVehicleProps', 'SELECT properties	FROM player_vehicles WHERE player_id = ? AND vehicle = ?')
vRP.prepare('vRP/getPlayerVehiclePropsByPlate', 'SELECT properties	FROM player_vehicles WHERE plate = ?')
vRP.prepare('vRP/removeVehicleFromPlayerByPlate', 'DELETE FROM player_vehicles WHERE plate = ?')


vRP.prepare('vRP/addPlayer',
[[
INSERT INTO players (user_id, firstname, lastname, `registration`, phone, birth_date, money, inventory, datatable)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
]])

vRP.prepare('vRP/deletePlayer', 'UPDATE players SET deleted_at = CURRENT_TIMESTAMP() WHERE id = ?')
vRP.prepare('vRP/getPlayer', 'SELECT *, (SELECT license FROM `users` WHERE `users`.id = `players`.user_id) AS `license`  FROM players WHERE id = ? AND deleted_at IS NULL')
vRP.prepare('vRP/getPlayerIncludeDeleted', 'SELECT *, (SELECT license FROM `users` WHERE `users`.id = `players`.user_id) AS `license`  FROM players WHERE id = ?')
vRP.prepare('vRP/getAllPlayerFromUser', 'SELECT *, (SELECT license FROM `users` WHERE `users`.id = `players`.user_id) AS `license`  FROM players WHERE user_id = ? AND deleted_at IS NULL')
vRP.prepare('vRP/getAllPlayerFromUserIncludeDeleted', 'SELECT *, (SELECT license FROM `users` WHERE `users`.id = `players`.user_id) AS `license`  FROM players WHERE user_id = ?')
vRP.prepare('vRP/getPlayersBy', 'SELECT *, (SELECT license FROM `users` WHERE `users`.id = `players`.user_id) AS `license`  FROM players WHERE ?? = ?')
vRP.prepare('vRP/addlog', 'INSERT INTO `logs` (log_type, `data`) VALUES (?, ?)')

lib.print.info('Queries register finalized.')
