local PlayerData = {}
local trans = {}
local societyTrans = {}
local societyIdent, societyDays
local isBankOpened = false
local canAccessSociety = false
local society = ''
local societyInfo

local playerBankMoney, playerIBAN, trsIdentifier, allDaysValues, walletMoney


local function CreateZones()
	exports.ox_target:addModel(Config.ATM, {
		label = 'Acessar ATM',
		name = 'okok_atm',
		icon = '',
		distance = Config.ATMDistance,
		offsetSize = 2.0,
		event = 'okokBanking:OpenATM',
	})

	for k, v in next, Config.BankZones or {} do
		exports.ox_target:addBoxZone({
			name = 'bank_' .. k,
			coords = v.coords,
			rotation = v.rotation,
			size = v.size,
			options = {
				{
					label = 'Acessar Banco',
					distance = 1.0,
					event = 'okokBanking:OpenBank'
				}
			}
		})
	end
end

RegisterNetEvent('vRP:SetPlayerData', function(data)
	PlayerData = data
end)

-- Citizen.CreateThread(function()
-- 	while vRP.getPlayer() == nil do Citizen.Wait(10) end
-- 	PlayerData = vRP.getPlayer()
-- 	CreateZones()
-- end)	

AddEventHandler('playerReady', function()
	Citizen.CreateThread(function()
		while vRP.getPlayer() == nil do Citizen.Wait(10) end
		PlayerData = vRP.getPlayer()
		CreateZones()
	end)	
end)

Citizen.CreateThread(function()
	if Config.ShowBankBlips then
		Citizen.Wait(2000)
		for _, v in ipairs(Config.BankLocations) do
			local blip = AddBlipForCoord(v.x, v.y, v.z)
			SetBlipSprite(blip, v.blip)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, v.blipScale)
			SetBlipColour(blip, v.blipColor)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.blipText)
			EndTextCommandSetBlipName(blip)
		end
	end
end)

local function GenerateIBAN()
	math.randomseed(GetGameTimer())
	local stringFormat = "%0" .. Config.IBANNumbers .. "d"
	local number = math.random(0, 10 ^ Config.IBANNumbers - 1)
	number = string.format(stringFormat, number)
	local iban = Config.IBANPrefix .. number:upper()
	local isIBanUsed = true
	local hasChecked = false

	while true do
		Citizen.Wait(10)
		if isIBanUsed and not hasChecked then
			isIBanUsed = false
			lib.callback("okokBanking:IsIBanUsed", false, function(isUsed)
				if isUsed ~= nil then
					isIBanUsed = true
					number = math.random(0, 10 ^ Config.IBANNumbers - 1)
					number = string.format("%03d", number)
					iban = Config.IBANPrefix .. number:upper()
				elseif isUsed == nil then
					hasChecked = true
					isIBanUsed = false
				end
				canLoop = true
			end, iban)
		elseif not isIBanUsed and hasChecked then
			break
		end
	end
	TriggerServerEvent('okokBanking:SetIBAN', iban)
end


local function openBank()
	print('OPEN BANK')
	local hasJob = false
	local playeJob = PlayerData.job
	local playerJobName = ''
	local playerJobGrade = ''
	local jobLabel = ''
	local onDuty = false
	isBankOpened = true

	canAccessSociety = false

	if playeJob ~= nil then
		hasJob = true
		playerJobName = playeJob.name
		playerJobGrade = playeJob?.rank or 0
		jobLabel = playeJob.label
		onDuty = playeJob?.onduty
		society = 'society_' .. playerJobName
	end

	lib.callback("okokBanking:GetPlayerInfo", false, function(data)
		lib.callback("okokBanking:GetOverviewTransactions", false, function(cb, identifier, allDays)
			canAccessSociety = onDuty and playerJobName and Config.Societies[playerJobName] ~= nil and Config.Societies[playerJobName] >= playerJobGrade

			if canAccessSociety then
				lib.callback("okokBanking:SocietyInfo", false, function(cb)
					if cb ~= nil then
						societyInfo = cb
					else
						local societyIban = Config.IBANPrefix .. jobLabel
						TriggerServerEvent("okokBanking:CreateSocietyAccount", society, jobLabel, 0, societyIban)
						Citizen.Wait(200)
						lib.callback("okokBanking:SocietyInfo", false, function(cb)
							societyInfo = cb
						end, society)
					end
				end, society)
			end

			isBankOpened = true
			trans = cb
			playerName, playerBankMoney, playerIBAN, trsIdentifier, allDaysValues, walletMoney = data.playerName,
				data.playerBankMoney, data.playerIBAN, identifier, allDays, data.walletMoney
			lib.callback("okokBanking:GetSocietyTransactions", false, function(societyTranscb, societyID, societyAllDays)
				societyIdent = societyID
				societyDays = societyAllDays
				societyTrans = societyTranscb

				if data.playerIBAN ~= nil then
					SetNuiFocus(true, true)
					SendNUIMessage({
						action = 'bankmenu',
						playerName = data.playerName,
						playerSex = data.sex,
						playerBankMoney = data.playerBankMoney,
						walletMoney = walletMoney,
						playerIBAN = data.playerIBAN,
						db = trans,
						identifier = trsIdentifier,
						graphDays = allDaysValues,
						isInSociety = canAccessSociety,
					})
				else
					GenerateIBAN()
					Citizen.Wait(1000)
					lib.callback("okokBanking:GetPlayerInfo", false, function(data)
						SetNuiFocus(true, true)
						SendNUIMessage({
							action = 'bankmenu',
							playerName = data.playerName,
							playerSex = data.sex,
							playerBankMoney = data.playerBankMoney,
							walletMoney = walletMoney,
							playerIBAN = data.playerIBAN,
							db = trans,
							identifier = trsIdentifier,
							graphDays = allDaysValues,
							isInSociety = canAccessSociety,
						})
					end)
				end
			end, society)
		end)
	end)
end

RegisterNetEvent("okokBanking:OpenATM", function()
	local dict = 'anim@amb@prop_human_atm@interior@male@enter'
	local anim = 'enter'
	local ped = PlayerPedId()

	lib.callback("okokBanking:GetPIN", false, function(pin)
		if pin then
			if not isBankOpened then
				isBankOpened = true
				lib.requestAnimDict(dict)

				TaskPlayAnim(ped, dict, anim, 8.0, 8.0, -1, 0, 0, false, false, false)
				Citizen.Wait(Config.AnimTime)
				ClearPedTasks(ped)
				RemoveAnimDict(dict)

				SetNuiFocus(true, true)
				SendNUIMessage({
					action = 'atm',
					pin = pin,
				})
			end
		else
			vRP.notify("BANK", "Vá até um banco para definir um código PIN", 5000, 'inform')
		end
	end)
end)

RegisterNetEvent('okokBanking:OpenBank', function(data)
	lib.print.info(data)
	if not data then return end
	if data?.distance > 1.0 then return end
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'loading_data',
	})
	Citizen.Wait(500)
	openBank()
end)





RegisterNUICallback("action", function(data, cb)
	if data.action == "close" then
		isBankOpened = false
		SetNuiFocus(false, false)
	elseif data.action == "deposit" then
		if tonumber(data.value) ~= nil then
			if tonumber(data.value) > 0 then
				if data.window == 'bankmenu' then
					TriggerServerEvent('okokBanking:DepositMoney', tonumber(data.value))
				elseif data.window == 'societies' then
					TriggerServerEvent('okokBanking:DepositMoneyToSociety', tonumber(data.value), societyInfo.society,
						societyInfo.society_name)
				end
			else
				vRP.notify("BANK", "Quantia inválida.", 5000, 'error')
			end
		else
			vRP.notify("BANK", "Entrada inválida.", 5000, 'error')
		end
	elseif data.action == "withdraw" then
		if tonumber(data.value) ~= nil then
			if tonumber(data.value) > 0 then
				if data.window == 'bankmenu' then
					TriggerServerEvent('okokBanking:WithdrawMoney', tonumber(data.value))
				elseif data.window == 'societies' then
					TriggerServerEvent('okokBanking:WithdrawMoneyToSociety', tonumber(data.value), societyInfo.society,
						societyInfo.society_name, societyInfo.value)
				end
			else
				vRP.notify("BANK", "Quantia inválida.", 5000, 'error')
			end
		else
			vRP.notify("BANK", "Entrada inválida.", 5000, 'error')
		end
	elseif data.action == "transfer" then
		if tonumber(data.value) ~= nil then
			if tonumber(data.value) > 0 then
				lib.callback("okokBanking:IsIBanUsed", false, function(isUsed, isPlayer, name)
					if isUsed ~= nil then
						if data.window == 'bankmenu' then
							if isPlayer then
								TriggerServerEvent('okokBanking:TransferMoney', tonumber(data.value), data.iban:upper(), isUsed.citizenid, isUsed.money, name)
							elseif not isPlayer then
								TriggerServerEvent('okokBanking:TransferMoneyToSociety', tonumber(data.value),	isUsed.iban:upper(), isUsed.society_name, isUsed.society)
							end
						elseif data.window == 'societies' then
							local toMyself = false
							if data.iban:upper() == playerIBAN then
								toMyself = true
							end

							if isPlayer then
								TriggerServerEvent('okokBanking:TransferMoneyToPlayerFromSociety', tonumber(data.value),
									data.iban:upper(), isUsed.citizenid, isUsed.money, name, societyInfo.society,
									societyInfo.society_name, societyInfo.value, toMyself)
							elseif not isPlayer then
								TriggerServerEvent('okokBanking:TransferMoneyToSocietyFromSociety', tonumber(data.value),
									isUsed.iban:upper(), isUsed.society_name, isUsed.society, societyInfo.society,
									societyInfo.society_name, societyInfo.value)
							end
						end
					elseif isUsed == nil then
						vRP.notify("BANK", "Este IBAN não existe", 5000, 'error')
					end
				end, data.iban:upper())
			else
				vRP.notify("BANK", "Quantia inválida.", 5000, 'error')
			end
		else
			vRP.notify("BANK", "Entrada inválida.", 5000, 'error')
		end
	elseif data.action == "overview_page" then
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'overview_page',
			playerBankMoney = playerBankMoney,
			walletMoney = walletMoney,
			playerIBAN = playerIBAN,
			db = trans,
			identifier = trsIdentifier,
			graphDays = allDaysValues,
			isInSociety = canAccessSociety,
		})
	elseif data.action == "transactions_page" then
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'transactions_page',
			db = trans,
			identifier = trsIdentifier,
			graph_values = allDaysValues,
			isInSociety = canAccessSociety,
		})
	elseif data.action == "society_transactions" then
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'society_transactions',
			db = societyTrans,
			identifier = societyIdent,
			graph_values = societyDays,
			isInSociety = canAccessSociety,
			societyInfo = societyInfo,
		})
	elseif data.action == "society_page" then
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'society_page',
			playerBankMoney = playerBankMoney,
			walletMoney = walletMoney,
			playerIBAN = playerIBAN,
			db = societyTrans,
			identifier = societyIdent,
			graphDays = societyDays,
			isInSociety = canAccessSociety,
			societyInfo = societyInfo,
		})
	elseif data.action == "settings_page" then
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'settings_page',
			isInSociety = canAccessSociety,
			ibanCost = Config.IBANChangeCost,
			ibanPrefix = Config.IBANPrefix,
			ibanCharNum = Config.CustomIBANMaxChars,
			pinCost = Config.PINChangeCost,
			pinCharNum = 4,
		})
	elseif data.action == "atm" then
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'loading_data',
		})
		Citizen.Wait(500)
		openBank()
	elseif data.action == "change_iban" then
		if Config.CustomIBANAllowLetters then
			local iban = Config.IBANPrefix .. data.iban:upper()

			lib.callback("okokBanking:IsIBanUsed", false, function(isUsed)
				if isUsed == nil then
					TriggerServerEvent('okokBanking:UpdateIbanDB', iban, Config.IBANChangeCost)
				elseif isUsed ~= nil then
					vRP.notify("BANK", "This IBAN is already in use", 5000, 'error')
				end
			end, iban)
		elseif not Config.CustomIBANAllowLetters then
			if tonumber(data.iban) ~= nil then
				local iban = Config.IBANPrefix .. data.iban:upper()

				lib.callback("okokBanking:IsIBanUsed", false, function(isUsed)
					if isUsed == nil then
						TriggerServerEvent('okokBanking:UpdateIbanDB', iban, Config.IBANChangeCost)
					elseif isUsed ~= nil then
						vRP.notify("BANK", "Este IBAN está em uso.", 5000, 'error')
					end
				end, iban)
			else
				vRP.notify("BANK", "Você só pode usar números no seu IBAN", 5000, 'error')
			end
		end
	elseif data.action == "change_pin" then
		if tonumber(data.pin) ~= nil then
			if string.len(data.pin) == 4 then
				lib.callback("okokBanking:GetPIN", false, function(pin)
					if pin then
						TriggerServerEvent('okokBanking:UpdatePINDB', data.pin, Config.PINChangeCost)
					else
						TriggerServerEvent('okokBanking:UpdatePINDB', data.pin, 0)
					end
				end)
			else
				vRP.notify("BANK", "Seu PIN precisa ter 4 dígitos", 5000, 'inform')
			end
		else
			vRP.notify("BANK", "Você só pode usar números", 5000, 'inform')
		end
	end
end)

RegisterNetEvent("okokBanking:updateTransactions", function(money, wallet)
	Citizen.Wait(100)
	if isBankOpened then
		lib.callback("okokBanking:GetOverviewTransactions", false, function(cb, _, allDays)
			trans = cb
			walletMoney = wallet
			playerBankMoney = money
			allDaysValues = allDays
			SetNuiFocus(true, true)
			SendNUIMessage({
				action = 'overview_page',
				playerBankMoney = playerBankMoney,
				walletMoney = walletMoney,
				playerIBAN = playerIBAN,
				db = trans,
				identifier = trsIdentifier,
				graphDays = allDaysValues,
				isInSociety = canAccessSociety,
			})
			TriggerEvent('okokBanking:updateMoney', money, wallet)
		end)
	end
end)

RegisterNetEvent("okokBanking:updateMoney", function(money, wallet)
	if isBankOpened then
		playerBankMoney = money
		walletMoney = wallet
		SendNUIMessage({
			action = 'updatevalue',
			playerBankMoney = money,
			walletMoney = wallet,
		})
	end
end)

RegisterNetEvent("okokBanking:updateIban")
AddEventHandler("okokBanking:updateIban", function(iban)
	playerIBAN = iban
	SendNUIMessage({
		action = 'updateiban',
		iban = playerIBAN,
	})
end)

RegisterNetEvent("okokBanking:updateIbanPinChange", function()
	Citizen.Wait(100)
	lib.callback("okokBanking:GetOverviewTransactions", false, function(cbs)
		trans = cbs
	end)
end)

RegisterNetEvent("okokBanking:updateTransactionsSociety", function(wallet)
	Citizen.Wait(100)
	lib.callback("okokBanking:SocietyInfo", false, function(cb)
		lib.callback("okokBanking:GetSocietyTransactions", false, function(societyTranscb, societyID, societyAllDays)
			lib.callback("okokBanking:GetOverviewTransactions", false, function(cbs)
				trans = cbs
				walletMoney = wallet
				societyDays = societyAllDays
				societyIdent = societyID
				societyTrans = societyTranscb
				societyInfo = cb
				if cb ~= nil then
					SetNuiFocus(true, true)
					SendNUIMessage({
						action = 'society_page',
						walletMoney = wallet,
						db = societyTrans,
						graphDays = societyDays,
						isInSociety = canAccessSociety,
						societyInfo = societyInfo,
					})
				end
			end)
		end, society)
	end, society)
end)
