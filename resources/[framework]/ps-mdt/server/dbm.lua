-- Get CitizenIDs from Player License
function GetCitizenID(license)
    local result = MySQL.query.await("SELECT id FROM vplayers WHERE license = ?", { license, })
    if result ~= nil then
        return result
    else
        print("Cannot find a CitizenID for License: " .. license)        
    end
    return {}
end

-- (Start) Opening the MDT and sending data
function AddLog(text)
    return MySQL.insert.await('INSERT INTO `mdt_logs` (`text`, `time`) VALUES (?,?)', { text, os.time() * 1000 })
end

function GetNameFromId(cid)
    return MySQL.scalar.await('SELECT CONCAT(firstname, " ", lastname) as fullname FROM vplayers WHERE id = ?', { cid })
end

function GetPersonInformation(cid, jobtype)
    MySQL.single.await('SELECT information, tags, gallery, pfp, fingerprint FROM mdt_data WHERE cid = ? and jobtype = ?',
        { cid, jobtype })
end

function GetIncidentName(id)
    return MySQL.scalar.await('SELECT title FROM `mdt_incidents` WHERE id = :id LIMIT 1', { id = id })
end

function GetConvictions(cids)
    return MySQL.query.await('SELECT * FROM `mdt_convictions` WHERE `cid` IN(?)', { cids })
end

function GetLicenseInfo(cid)
    return MySQL.query.await('SELECT * FROM `licenses` WHERE `cid` = ?', { cid })
end

function CreateUser(cid, tableName)
    AddLog("A user was created with the CID: " .. cid)
    return MySQL.insert.await("INSERT INTO `" .. tableName .. "` (cid) VALUES (:cid)", { cid = cid })
end

function GetPlayerVehicles(cid)
    return MySQL.query.await('SELECT id, plate, vehicle FROM player_vehicles WHERE player_id=:cid', { cid = cid })
end

function GetBulletins(JobType)
    return MySQL.query.await('SELECT * FROM `mdt_bulletin` WHERE `jobtype` = ? LIMIT 10', { JobType })
end

function GetPlayerProperties(cid)
    -- local result =  MySQL.query.await('SELECT houselocations.label, houselocations.coords FROM player_houses INNER JOIN houselocations ON player_houses.house = houselocations.name where player_houses.citizenid = ?', {cid})
    -- return result
end

function GetPlayerDataById(id)
    local src = vRP.getSourceByCharacterId( id )
    if src then
        local xPlayer = vRP.getPlayerInfo(src)
        if xPlayer ~= nil then
            return xPlayer
        end
    end
    return MySQL.single.await('SELECT * FROM vplayers WHERE id = ? LIMIT 1', { id })
end

function GetBoloStatus(plate)
    local result = MySQL.scalar.await('SELECT id FROM `mdt_bolos` WHERE LOWER(`plate`)=:plate',
        { plate = string.lower(plate) })
    return result
end

function GetOwnerName(cid)    
    return MySQL.scalar.await('SELECT CONCAT(firstname, " ", lastname) FROM `players` WHERE `id` = ? LIMIT 1', { cid })
end

function GetVehicleInformation(plate, cb)
    local result = MySQL.query.await('SELECT id, information FROM `mdt_vehicleinfo` WHERE plate=:plate',
        { plate = plate })
    cb(result)
end

function GetPlayerApartment(cid)
    -- local result = MySQL.query.await('SELECT name, type, label FROM apartments where citizenid = ?', { cid })
    -- return result
end

function GetPlayerLicenses(identifier)
    -- local response = false
    -- local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    -- if Player ~= nil then
    --     return Player.PlayerData.metadata.licences
    -- else
    --     local result = MySQL.scalar.await('SELECT metadata FROM players WHERE citizenid = @identifier',
    --         { ['@identifier'] = identifier })
    --     if result ~= nil then
    --         local metadata = json.decode(result)
    --         if metadata["licences"] ~= nil and metadata["licences"] then
    --             return metadata["licences"]
    --         else
    --             return {
    --                 ['driver'] = false,
    --                 ['business'] = false,
    --                 ['weapon'] = false,
    --                 ['pilot'] = false
    --             }
    --         end
    --     end
    -- end
    return false
end

function ManageLicense(identifier, type, status)
    -- local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    -- local licenseStatus = nil
    -- if status == "give" then licenseStatus = true elseif status == "revoke" then licenseStatus = false end
    -- if Player ~= nil then
    --     local licences = Player.PlayerData.metadata["licences"]
    --     local newLicenses = {}
    --     for k, v in pairs(licences) do
    --         local status = v
    --         if k == type then
    --             status = licenseStatus
    --         end
    --         newLicenses[k] = status
    --     end
    --     Player.Functions.SetMetaData("licences", newLicenses)
    -- else
    --     local licenseType = '$.licences.' .. type
    --     local result = MySQL.query.await(
    --         'UPDATE `players` SET `metadata` = JSON_REPLACE(`metadata`, ?, ?) WHERE `citizenid` = ?',
    --         { licenseType, licenseStatus, identifier }) --seems to not work on older MYSQL versions, think about alternative
    -- end
end

function UpdateAllLicenses(identifier, incomingLicenses)
    -- local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    -- if Player ~= nil then
    --     Player.Functions.SetMetaData("licences", incomingLicenses)
    -- else
    --     local result = MySQL.scalar.await('SELECT metadata FROM players WHERE citizenid = @identifier',
    --         { ['@identifier'] = identifier })
    --     result = json.decode(result)

    --     result.licences = result.licences or {
    --         ['driver'] = true,
    --         ['business'] = false,
    --         ['weapon'] = false,
    --         ['pilot'] = false
    --     }

    --     for k, _ in pairs(incomingLicenses) do
    --         result.licences[k] = incomingLicenses[k]
    --     end
    --     MySQL.query.await('UPDATE `players` SET `metadata` = @metadata WHERE citizenid = @citizenid',
    --         { ['@metadata'] = json.encode(result), ['@citizenid'] = identifier })
    -- end
end
