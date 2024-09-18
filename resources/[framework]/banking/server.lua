
lib.callback.register("okokBanking:GetPlayerInfo", function(source)
	local xPlayer = vRP.getPlayerInfo(source)
	if not xPlayer then return false end
	local result = MySQL.single.await('SELECT * FROM vplayers WHERE id = ?', { xPlayer.id })
	if not result then return false end
	local data = {
		playerName = xPlayer.firstname .. ' ' .. xPlayer.lastname,
		playerBankMoney = xPlayer.money.bank,
		playerIBAN = result.iban,
		walletMoney = xPlayer.money.cash,
		sex = xPlayer.gender,
	}
	return data
end)

lib.callback.register("okokBanking:IsIBanUsed", function(_, iban)
	local result = MySQL.scalar.await("SELECT * FROM vplayers WHERE iban = ?", { iban })
	if result then
		return result, true, ("%s %s"):format(result.firstname, result.lastname)
	else
		result = MySQL.single.await('SELECT * FROM okokBanking_societies WHERE iban = ?', { iban })
		return result, false
	end
end)

lib.callback.register("okokBanking:GetPIN", function(source)
	local xPlayer = vRP.getPlayerInfo(source)	
	return MySQL.scalar.await('SELECT pincode FROM vplayers WHERE id = ?', { xPlayer.id })
end)

lib.callback.register("okokBanking:SocietyInfo", function(source, society)
	return MySQL.single.await('SELECT * FROM okokBanking_societies WHERE society = ?', { society })
end)

RegisterNetEvent("okokBanking:CreateSocietyAccount",function(society, society_name, value, iban)
	MySQL.insert.await(
		'INSERT INTO okokBanking_societies (society, society_name, value, iban) VALUES (?,?,?,?)',
		{
			society,
			society_name,
			value,
			iban:upper(),
		})
end)

RegisterNetEvent("okokBanking:SetIBAN", function(iban)
	local xPlayer = vRP.getPlayerInfo(source)
	MySQL.update.await('UPDATE players SET iban = ? WHERE id = ?', {
		iban:upper(),
		xPlayer.id,
	})
end)

RegisterNetEvent("okokBanking:DepositMoney", function(amount)
	local _source = source
	local xPlayer = vRP.getPlayerInfo(_source)
	local playerMoney = xPlayer.money.cash
	

	if amount <= playerMoney then
		vRP.removeMoney(xPlayer.user_id, amount, 'cash')
		vRP.giveBankMoney(xPlayer.user_id, amount)
		xPlayer = vRP.getPlayerInfo(_source)
		TriggerEvent('okokBanking:AddDepositTransaction', amount, _source)
		TriggerClientEvent('okokBanking:updateTransactions', _source, xPlayer.money.bank, xPlayer.money.cash)
		vRP.notify(_source, "BANK", "Você depositou " .. amount .. "$", 5000, 'success')
	else
		vRP.notify(_source, "BANK", "Você não tem tanto dinheiro com você", 5000, 'error')
	end
end)

RegisterNetEvent("okokBanking:WithdrawMoney", function(amount)
	local _source = source
	local xPlayer = vRP.getPlayerInfo(_source)
	local playerMoney = xPlayer.money.bank

	if amount <= playerMoney then
		vRP.removeBankMoney(xPlayer.user_id, amount)
		vRP.giveMoney(xPlayer.user_id, amount)
		
		xPlayer = vRP.getPlayerInfo(_source)

		TriggerEvent('okokBanking:AddWithdrawTransaction', amount, _source)
		TriggerClientEvent('okokBanking:updateTransactions', _source, xPlayer.money.bank,
			xPlayer.money.cash)
		vRP.notify(_source, "BANK", "Você sacou " .. amount .. "€", 5000, 'success')
	else
		vRP.notify(_source, "BANK", "Você não tem tanto dinheiro no banco", 5000,
			'error')
	end
end)

RegisterNetEvent("okokBanking:TransferMoney", function(amount, ibanNumber, targetIdentifier, acc, targetName)
	local _source  = source
	local xPlayer = vRP.getPlayerInfo(_source)
	local xTarget = vRP.getPlayerInfo( vRP.getSourceByCharacterId( targetIdentifier )  )
	local playerMoney = xPlayer.money.bank
	ibanNumber = ibanNumber:upper()

	if xPlayer.id == targetIdentifier then
		return vRP.notify(_source, "BANK", "Você não pode transferir dinheiro para si mesmo.", 5000, 'error')
	end

	if amount > playerMoney then
		return vRP.notify(_source, "BANK", "Você não tem dinheiro suficiente no banco.", 5000, 'error')
	end

	if not xTarget then
		xTarget = vRP.getPlayerInfoOffLine( targetIdentifier )
		if xTarget then
			vRP.removeBankMoney(xPlayer.user_id, amount)
			xPlayer = vRP.getPlayerInfo(_source)
			xTarget.money.bank = xTarget.money.bank + amount
			MySQL.update.await('UPDATE players SET money = ? WHERE id = ?', { json.encode(xTarget.money), xTarget.id })
			TriggerEvent('okokBanking:AddTransferTransaction', amount, 1, _source, targetName, targetIdentifier)
			TriggerClientEvent('okokBanking:updateTransactions', _source, xPlayer.money.bank, xPlayer.money.cash)
			return vRP.notify(_source, "BANK", 'You have transferred '..amount..' € to '..targetName, 5000, 'success')
		else 
			return vRP.notify(_source, "BANK", "Nenhuma conta localizada com o ID especificado.", 5000, 'error')
		end
	end

	vRP.removeBankMoney(xPlayer.user_id, amount)
	vRP.giveBankMoney(xTarget.user_id, amount)
	TriggerClientEvent('okokBanking:updateTransactions', xTarget.source, xTarget.money.bank, xTarget.money.cash)
	vRP.notify( xTarget.source, "BANK", "Você recebeu "..amount.."€ de "..xPlayer.firstname..' '..xPlayer.lastname, 5000, 'success')
	TriggerEvent('okokBanking:AddTransferTransaction', amount, xTarget, _source)
	TriggerClientEvent('okokBanking:updateTransactions', _source, xPlayer.money.bank, xPlayer.money.cash)
	vRP.notify(_source, "BANK", "Você transferiu "..amount.."€ para ".. xTarget.firstname..' '..xTarget.lastname, 5000, 'success')

end)

RegisterNetEvent("okokBanking:DepositMoneyToSociety", function(amount, society, societyName)
	local _source = source
	local xPlayer = vRP.getPlayerInfo(_source)
	local playerMoney = xPlayer.money.cash
	if amount <= playerMoney then
		MySQL.update.await(
			'UPDATE okokBanking_societies SET value = value + ? WHERE society = ? AND society_name = ?',
			{
				amount,
				society,
				societyName,
			})
		vRP.removeMoney(xPlayer.user_id, amount)			
		xPlayer = vRP.getPlayerInfo(_source)
		TriggerEvent('okokBanking:AddDepositTransactionToSociety', amount, _source, society, societyName)
		TriggerClientEvent('okokBanking:updateTransactionsSociety', _source, xPlayer.money.cash)		
		vRP.notify(_source, "BANK", "Você depositou " .. amount .. "€ to " .. societyName, 5000, 'success')
	else		
		vRP.notify(_source, "BANK", "Você não tem tanto dinheiro com você", 5000, 'error')
	end
end)

RegisterNetEvent("okokBanking:WithdrawMoneyToSociety", function(amount, society, societyName, societyMoney)
	local _source = source
	local xPlayer = vRP.getPlayerInfo(_source)

	local db = MySQL.single.await('SELECT * FROM okokBanking_societies WHERE society = ?', {society})
	MySQL.update.await('UPDATE okokBanking_societies SET is_withdrawing = 1 WHERE society = ? AND society_name = ?')		
	if amount <= db.value then
		if db.is_withdrawing == 1 then
			vRP.notify(_source, "BANK", "Alguém já está sacando.", 5000, 'error')			
		else
			MySQL.update.await(
				'UPDATE okokBanking_societies SET value = value - ? WHERE society = ? AND society_name = ?',
				{
					amount,
					 society,
					societyName,
				})

			-- xPlayer.Functions.AddMoney('cash', amount)
			vRP.giveMoney(xPlayer.user_id, amount)
			xPlayer = vRP.getPlayerInfo(_source)
			TriggerEvent('okokBanking:AddWithdrawTransactionToSociety', amount, _source, society, societyName)
			TriggerClientEvent('okokBanking:updateTransactionsSociety', _source, xPlayer.money.cash)
			vRP.notify(_source, "BANK", "Você sacou " .. amount .. "€ de " .. societyName, 5000, 'success')
		end
	else
		vRP.notify(_source, "BANK", "A sua sociedade não tem tanto dinheiro no banco",
			5000, 'error')
	end

	MySQL.update.await(
		'UPDATE okokBanking_societies SET is_withdrawing = 0 WHERE society = ? AND society_name = ?',
		{			
			society,
			societyName,
		})
end)

RegisterNetEvent("okokBanking:TransferMoneyToSociety", function(amount, ibanNumber, societyName, society)
	local _source = source
	local xPlayer = vRP.getPlayerInfo(_source)
	local playerMoney = xPlayer.money.bank

	if amount <= playerMoney then
		MySQL.update.await('UPDATE okokBanking_societies SET value = value + ? WHERE iban = ?', {
			amount,
			ibanNumber
		})
		vRP.removeBankMoney(xPlayer.user_id, amount)		
		xPlayer = vRP.getPlayerInfo(_source)

		TriggerEvent('okokBanking:AddTransferTransactionToSociety', amount, _source, society, societyName)
		TriggerClientEvent('okokBanking:updateTransactionsSociety', _source, xPlayer.money.cash)
		vRP.notify(_source, "BANK", "Você transferiu " .. amount .. "€ para " ..	societyName, 5000, 'success')
	else
		vRP.notify(_source, "BANK", "Você não tem tanto dinheiro no banco", 5000,	'error')
	end
end)

RegisterNetEvent("okokBanking:TransferMoneyToSocietyFromSociety", function(amount, _, societyNameTarget, societyTarget, society, societyName, societyMoney)
	local _source = source
	local xPlayer = vRP.getPlayerInfo(_source)
		
	if amount <= societyMoney then

		local queries = {
			{ query = 'UPDATE okokBanking_societies SET value = value - ? WHERE society = ? AND society_name = ?', value = { amount, society, societyName }},
			{ query = 'UPDATE okokBanking_societies SET value = value + ? WHERE society = ? AND society_name = ?', value = { amount, societyTarget, societyNameTarget}}
		}

		if MySQL.transaction.await(queries) then
			TriggerEvent('okokBanking:AddTransferTransactionFromSociety', amount, society, societyName, societyTarget, societyNameTarget)
			TriggerClientEvent('okokBanking:updateTransactionsSociety', _source, xPlayer.money.cash)
			vRP.notify(_source, "BANK", "Você transferiu "..amount.."€ para "..societyNameTarget, 5000, 'success')
		else
			vRP.notify(_source, "BANK", "Problema na transação, tente novamente em alguns minutos.", 5000, 'error')	
		end		
	else
		vRP.notify(_source, "BANK", "A sua sociedade não tem tanto dinheiro no banco", 5000, 'error')
	end
end)

RegisterNetEvent("okokBanking:TransferMoneyToPlayerFromSociety", function(amount, ibanNumber, targetIdentifier, acc, targetName, society, societyName, societyMoney, toMyself)
	local _source  = source
	local xPlayer = vRP.getPlayerInfo(_source)
	local xTarget = vRP.getPlayerInfo( vRP.getSourceByCharacterId( targetIdentifier )  )
	
	if amount > societyMoney then
		return vRP.notify(_source,  "BANK", "A sua sociedade não tem tanto dinheiro no banco", 5000, 'error')
	end

	if not xTarget then
		xTarget = vRP.getPlayerInfoOffLine( targetIdentifier )
		if not xTarget then
			return vRP.notify(_source, 'BANK', 'Conta de destino não encontrada.', 5000, 'error')
		end
		MySQL.update.await('UPDATE okokBanking_societies SET value = value - ? WHERE society = ? AND society_name = ?',
		{
			amount,
			society,
			societyName
		})
		xTarget.money.bank = xTarget.money.bank + amount
		MySQL.update.await('UPDATE players SET money = ? WHERE id = ?', { json.encode(xTarget.money), xTarget.id })
		TriggerEvent('okokBanking:AddTransferTransactionFromSocietyToP', amount, society, societyName, targetIdentifier, targetName)
		TriggerClientEvent('okokBanking:updateTransactionsSociety', _source, xPlayer.money.cash)
		return vRP.notify( _source, "BANK", "Você transferiu "..amount.."€ to "..targetName, 5000, 'success')
	end

	MySQL.update.await('UPDATE okokBanking_societies SET value = value - ? WHERE society = ? AND society_name = ?',
	{
		amount,
		society,
		societyName
	})
	vRP.giveBankMoney(xTarget.user_id, amount)
	if not toMyself then
		TriggerClientEvent('okokBanking:updateTransactions', xTarget.source, xTarget.money.bank, xTarget.money.cash)
		vRP.notify( xTarget.source, "BANK", "Você recebeu "..amount.."€ de "..xPlayer.firstname..' '..xPlayer.lastname, 5000, 'success')
	end

	TriggerEvent('okokBanking:AddTransferTransactionFromSocietyToP', amount, society, societyName, targetIdentifier, targetName)
	TriggerClientEvent('okokBanking:updateTransactionsSociety', _source, xPlayer.money.cash)
	vRP.notify( _source, "BANK", "Você transferiu "..amount.."€ para"..xTarget.firstname..' '..xTarget.lastname, 5000, 'success')

end)

lib.callback.register("okokBanking:GetOverviewTransactions", function(source)
	local xPlayer = vRP.getPlayerInfo(source)
	local playerIdentifier = xPlayer.id
	local allDays = {}
	local income = 0
	local outcome = 0
	local totalIncome = 0
	local day1_total, day2_total, day3_total, day4_total, day5_total, day6_total, day7_total = 0, 0, 0, 0, 0, 0, 0

	local result = MySQL.query.await('SELECT * FROM okokBanking_transactions WHERE receiver_identifier = :identifier OR sender_identifier = :identifier ORDER BY id DESC',
		{
			identifier = playerIdentifier
		})
	
	local result2 = MySQL.query.await('SELECT *, DATE(date) = CURDATE() AS "day1", DATE(date) = CURDATE() - INTERVAL 1 DAY AS "day2", DATE(date) = CURDATE() - INTERVAL 2 DAY AS "day3", DATE(date) = CURDATE() - INTERVAL 3 DAY AS "day4", DATE(date) = CURDATE() - INTERVAL 4 DAY AS "day5", DATE(date) = CURDATE() - INTERVAL 5 DAY AS "day6", DATE(date) = CURDATE() - INTERVAL 6 DAY AS "day7" FROM `okokBanking_transactions` WHERE DATE(date) >= CURDATE() - INTERVAL 7 DAY', {})
	
	for k, v in pairs(result2) do
		local type = v.type
		local receiver_identifier = v.receiver_identifier
		local sender_identifier = v.sender_identifier
		local value = tonumber(v.value)

		if v.day1 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day1_total = day1_total + value
					income = income + value
				elseif type == "withdraw" then
					day1_total = day1_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day1_total = day1_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day1_total = day1_total - value
					outcome = outcome - value
				end
			end
		elseif v.day2 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day2_total = day2_total + value
					income = income + value
				elseif type == "withdraw" then
					day2_total = day2_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day2_total = day2_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day2_total = day2_total - value
					outcome = outcome - value
				end
			end
		elseif v.day3 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day3_total = day3_total + value
					income = income + value
				elseif type == "withdraw" then
					day3_total = day3_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day3_total = day3_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day3_total = day3_total - value
					outcome = outcome - value
				end
			end
		elseif v.day4 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day4_total = day4_total + value
					income = income + value
				elseif type == "withdraw" then
					day4_total = day4_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day4_total = day4_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day4_total = day4_total - value
					outcome = outcome - value
				end
			end
		elseif v.day5 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day5_total = day5_total + value
					income = income + value
				elseif type == "withdraw" then
					day5_total = day5_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day5_total = day5_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day5_total = day5_total - value
					outcome = outcome - value
				end
			end
		elseif v.day6 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day6_total = day6_total + value
					income = income + value
				elseif type == "withdraw" then
					day6_total = day6_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day6_total = day6_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day6_total = day6_total - value
					outcome = outcome - value
				end
			end
		elseif v.day7 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day7_total = day7_total + value
					income = income + value
				elseif type == "withdraw" then
					day7_total = day7_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day7_total = day7_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day7_total = day7_total - value
					outcome = outcome - value
				end
			end
		end
	end

	totalIncome = day1_total + day2_total + day3_total + day4_total + day5_total + day6_total +
		day7_total

	table.remove(allDays)
	table.insert(allDays, day1_total)
	table.insert(allDays, day2_total)
	table.insert(allDays, day3_total)
	table.insert(allDays, day4_total)
	table.insert(allDays, day5_total)
	table.insert(allDays, day6_total)
	table.insert(allDays, day7_total)
	table.insert(allDays, income)
	table.insert(allDays, outcome)
	table.insert(allDays, totalIncome)

	return result, playerIdentifier, allDays

end)

lib.callback.register("okokBanking:GetSocietyTransactions", function(source, society)
	local playerIdentifier = society
	local allDays = {}
	local income = 0
	local outcome = 0
	local totalIncome = 0
	local day1_total, day2_total, day3_total, day4_total, day5_total, day6_total, day7_total = 0, 0, 0, 0, 0, 0, 0

	local result = MySQL.query.await('SELECT * FROM okokBanking_transactions WHERE receiver_identifier = :identifier OR sender_identifier = :identifier ORDER BY id DESC',
		{
			identifier = society
		})
	local result2 = MySQL.query.await('SELECT *, DATE(date) = CURDATE() AS "day1", DATE(date) = CURDATE() - INTERVAL 1 DAY AS "day2", DATE(date) = CURDATE() - INTERVAL 2 DAY AS "day3", DATE(date) = CURDATE() - INTERVAL 3 DAY AS "day4", DATE(date) = CURDATE() - INTERVAL 4 DAY AS "day5", DATE(date) = CURDATE() - INTERVAL 5 DAY AS "day6", DATE(date) = CURDATE() - INTERVAL 6 DAY AS "day7" FROM `okokBanking_transactions` WHERE DATE(date) >= CURDATE() - INTERVAL 7 DAY AND receiver_identifier = :identifier OR sender_identifier = :identifier ORDER BY id DESC',
				{
					identifier = society
				})
	for _, v in pairs(result2) do
		local type = v.type
		local receiver_identifier = v.receiver_identifier
		local sender_identifier = v.sender_identifier
		local value = tonumber(v.value)

		if v.day1 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day1_total = day1_total + value
					income = income + value
				elseif type == "withdraw" then
					day1_total = day1_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day1_total = day1_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day1_total = day1_total - value
					outcome = outcome - value
				end
			end
		elseif v.day2 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day2_total = day2_total + value
					income = income + value
				elseif type == "withdraw" then
					day2_total = day2_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day2_total = day2_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day2_total = day2_total - value
					outcome = outcome - value
				end
			end
		elseif v.day3 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day3_total = day3_total + value
					income = income + value
				elseif type == "withdraw" then
					day3_total = day3_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day3_total = day3_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day3_total = day3_total - value
					outcome = outcome - value
				end
			end
		elseif v.day4 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day4_total = day4_total + value
					income = income + value
				elseif type == "withdraw" then
					day4_total = day4_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day4_total = day4_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day4_total = day4_total - value
					outcome = outcome - value
				end
			end
		elseif v.day5 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day5_total = day5_total + value
					income = income + value
				elseif type == "withdraw" then
					day5_total = day5_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day5_total = day5_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day5_total = day5_total - value
					outcome = outcome - value
				end
			end
		elseif v.day6 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day6_total = day6_total + value
					income = income + value
				elseif type == "withdraw" then
					day6_total = day6_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day6_total = day6_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day6_total = day6_total - value
					outcome = outcome - value
				end
			end
		elseif v.day7 == 1 then
			if value ~= nil then
				if type == "deposit" then
					day7_total = day7_total + value
					income = income + value
				elseif type == "withdraw" then
					day7_total = day7_total - value
					outcome = outcome - value
				elseif type == "transfer" and receiver_identifier == playerIdentifier then
					day7_total = day7_total + value
					income = income + value
				elseif type == "transfer" and sender_identifier == playerIdentifier then
					day7_total = day7_total - value
					outcome = outcome - value
				end
			end
		end
	end

	totalIncome = day1_total + day2_total + day3_total + day4_total + day5_total + day6_total +
		day7_total

	table.remove(allDays)
	table.insert(allDays, day1_total)
	table.insert(allDays, day2_total)
	table.insert(allDays, day3_total)
	table.insert(allDays, day4_total)
	table.insert(allDays, day5_total)
	table.insert(allDays, day6_total)
	table.insert(allDays, day7_total)
	table.insert(allDays, income)
	table.insert(allDays, outcome)
	table.insert(allDays, totalIncome)

	return result, playerIdentifier, allDays
					
end)


RegisterNetEvent("okokBanking:AddDepositTransaction", function(amount, source_)
	local _source = nil
	if source_ ~= nil then
		_source = source_
	else
		_source = source
	end

	local xPlayer = vRP.getPlayerInfo(_source)

	MySQL.insert.await(
		'INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
		{
			receiver_identifier = 'bank',
			receiver_name = 'Bank Account',
			sender_identifier = xPlayer.id,
			sender_name = xPlayer.firstname ..' ' .. xPlayer.lastname,
			value = tonumber(amount),
			type = 'deposit'
		})
end)

RegisterNetEvent("okokBanking:AddWithdrawTransaction", function(amount, source_)
	local _source = nil
	if source_ ~= nil then
		_source = source_
	else
		_source = source
	end

	local xPlayer = vRP.getPlayerInfo(_source)

	MySQL.insert.await('INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
		{						
			receiver_identifier = xPlayer.id,
			receiver_name = xPlayer.firstname ..' ' .. xPlayer.lastname,
			sender_identifier = 'bank',
			sender_name = 'Bank Account',
			value = tonumber(amount),
			type = 'withdraw'
		})
end)

RegisterNetEvent("okokBanking:AddTransferTransaction", function(amount, xTarget, source_, targetName, targetIdentifier)
	local _source = nil
	if source_ ~= nil then
		_source = source_
	else
		_source = source
	end

	local xPlayer = vRP.getPlayerInfo(_source)
	if targetName == nil then
		MySQL.insert.await(
			'INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
			{
				receiver_identifier = xPlayer.id,
				receiver_name = xTarget.firstname ..' ' .. xTarget.lastname,
				sender_identifier = xPlayer.id,
				sender_name = xPlayer.firstname .. ' ' .. xPlayer.lastname,
				value = tonumber(amount),
				type = 'transfer'
			})
	elseif targetName ~= nil and targetIdentifier ~= nil then
		MySQL.insert.await('INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
			{
				receiver_identifier = targetIdentifier,
				receiver_name = targetName,
				sender_identifier = xPlayer.id,
				sender_name = xPlayer.firstname .. ' ' .. xPlayer.lastname,
				value = tonumber(amount),
				type = 'transfer'
			})
	end
end)

RegisterNetEvent("okokBanking:AddTransferTransactionToSociety", function(amount, source_, society, societyName)
	local _source = nil
	if source_ ~= nil then
		_source = source_
	else
		_source = source
	end

	local xPlayer = vRP.getPlayerInfo(_source)
	MySQL.insert.await(
		'INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
		{
			receiver_identifier = society,
			receiver_name = societyName,
			sender_identifier = xPlayer.id,
			sender_name = xPlayer.firstname ..	' ' .. xPlayer.lastname,
			value = tonumber(amount),
			type = 'transfer'
		})
end)

RegisterNetEvent("okokBanking:AddTransferTransactionFromSocietyToP",
	function(amount, society, societyName, identifier, name)
		MySQL.insert.await(
			'INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
			{
				receiver_identifier = identifier,
				receiver_name = name,
				sender_identifier = society,
				sender_name = societyName,
				value = tonumber(amount),
				type = 'transfer'
			})
	end)

RegisterNetEvent("okokBanking:AddTransferTransactionFromSociety",
	function(amount, society, societyName, societyTarget, societyNameTarget)
		MySQL.insert.await(
			'INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
			{
				receiver_identifier = societyTarget,
				receiver_name = societyNameTarget,
				sender_identifier = society,
				sender_name = societyName,
				value = tonumber(amount),
				type = 'transfer'
			})
	end)

RegisterNetEvent("okokBanking:AddDepositTransactionToSociety")
AddEventHandler("okokBanking:AddDepositTransactionToSociety", function(amount, source_, society, societyName)
	local _source = nil
	if source_ ~= nil then
		_source = source_
	else
		_source = source
	end

	local xPlayer = vRP.getPlayerInfo(_source)

	MySQL.insert.await(
		'INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
		{
			receiver_identifier = society,
			receiver_name = societyName,
			sender_identifier = xPlayer.id,
			sender_name = xPlayer.firstname ..	' ' .. xPlayer.lastname,
			value = tonumber(amount),
			type = 'deposit'
		})
end)

RegisterNetEvent("okokBanking:AddWithdrawTransactionToSociety", function(amount, source_, society, societyName)
	local _source = nil
	if source_ ~= nil then
		_source = source_
	else
		_source = source
	end

	local xPlayer = vRP.getPlayerInfo(_source)

	MySQL.insert.await(
		'INSERT INTO okokBanking_transactions (receiver_identifier, receiver_name, sender_identifier, sender_name, date, value, type) VALUES (:receiver_identifier, :receiver_name, :sender_identifier, :sender_name, CURRENT_TIMESTAMP(), :value, :type)',
		{
			receiver_identifier = xPlayer.id,
			receiver_name = xPlayer.firstname .. ' ' .. xPlayer.lastname,
			sender_identifier = society,
			sender_name = societyName,
			value = tonumber(amount),
			type = 'withdraw'
		})
end)

RegisterNetEvent("okokBanking:UpdateIbanDB")
AddEventHandler("okokBanking:UpdateIbanDB", function(iban, amount)
	local _source = source
	local xPlayer = vRP.getPlayerInfo(_source)

	if amount <= xPlayer.money.bank then
		MySQL.update.await('UPDATE players SET iban = ? WHERE id = ?', {
			iban,
			xPlayer.id,
		})

		vRP.removeBankMoney(xPlayer.user_id, amount)		
		xPlayer = vRP.getPlayerInfo(_source)
		TriggerClientEvent('okokBanking:updateMoney', _source, xPlayer.money.bank,	xPlayer.money.cash)
		TriggerEvent('okokBanking:AddTransferTransactionToSociety', amount, _source, "bank", "Bank (IBAN)")
		TriggerClientEvent('okokBanking:updateIban', _source, iban)
		TriggerClientEvent('okokBanking:updateIbanPinChange', _source)
		vRP.notify(_source, "BANK", "IBAN alterado com sucesso para " .. iban, 5000, 'success')
	else
		vRP.notify(_source, "BANK",	"Você precisa ter " .. amount .. "€ para alterar seu IBAN", 5000, 'error')
	end
end)

RegisterNetEvent("okokBanking:UpdatePINDB", function(pin, amount)
	local _source = source
	local xPlayer = vRP.getPlayerInfo(_source)

	if amount <= xPlayer.money.bank then
		MySQL.update.await('UPDATE players SET pincode = ? WHERE id = ?', {
			pin,
			xPlayer.id,
		})

		vRP.removeBankMoney(xPlayer.user_id, amount)
		xPlayer = vRP.getPlayerInfo(_source)
		TriggerClientEvent('okokBanking:updateMoney', _source, xPlayer.money.bank,	xPlayer.money.cash)
		TriggerEvent('okokBanking:AddTransferTransactionToSociety', amount, _source, "bank", "Bank (PIN)")
		TriggerClientEvent('okokBanking:updateIbanPinChange', _source)
		vRP.notify(_source, "BANK", "PIN alterado com sucesso para " .. pin, 5000, 'success')
	else
		vRP.notify(_source, "BANK",	"Você precisa ter " .. amount .. "€ para alterar seu PIN", 5000, 'error')
	end
end)
