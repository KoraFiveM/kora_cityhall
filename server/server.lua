local function getLicenseInfo(Player, license)
    local charinfo = Player.charinfo
    if license == 'id_card' then
        return {
            citizenid = Player.citizenid,
            firstname = charinfo.firstname,
            lastname = charinfo.lastname,
            birthdate = charinfo.birthdate,
            gender = charinfo.gender,
            nationality = charinfo.nationality
        }

    elseif license == 'driver_license' then
        return {
            firstname = charinfo.firstname,
            lastname = charinfo.lastname,
            birthdate = charinfo.birthdate,
            type = 'Class C Driver License'
        }

    elseif license == 'weaponlicense' then
        return {
            firstname = charinfo.firstname,
            lastname = charinfo.lastname,
            birthdate = charinfo.birthdate
        }
    end

    return {}
end


local starterClaims = {}

local function isCurrentCharacter(src, citizenid)
    local current = exports.kora_core:getPlayerData(src)
    return current and current.citizenid == citizenid
end

local function giveStarterItems()
    local src = source
    if not Config.GiveStarterItems then return end
    if starterClaims[src] then return end
    local Player = exports.kora_core:getPlayerData(src)
    if not Player then return end
    local remaining = exports.kora_core:getMetaData(src, 'starterItems')
    if type(remaining) ~= 'table' then return end
    local citizenid = Player.citizenid

    starterClaims[src] = true
    local changed = false
    local ok, err = pcall(function()
        for _, starterItem in pairs(exports.kora_core:getStarterItems()) do
            local item = starterItem.item
            if remaining[item] == true then
                if not isCurrentCharacter(src, citizenid) then return end
                -- Inventory hooks can re-enter this event or save player data.
                -- Consume this item first so neither can observe it as unclaimed.
                remaining[item] = false
                if not exports.kora_core:setMetaData(src, 'starterItems', remaining) then
                    error('Unable to reserve starter item entitlement')
                end
                changed = true
                if not isCurrentCharacter(src, citizenid) then return end
                local info = getLicenseInfo(Player, item)
                local added = exports['qb-inventory']:AddItem(src, item, 1, false, info, 'qb-cityhall:giveStarterItems')
                if added == false then
                    if not isCurrentCharacter(src, citizenid) then return end
                    remaining[item] = true
                    if not exports.kora_core:setMetaData(src, 'starterItems', remaining) then
                        error('Unable to restore failed starter item entitlement')
                    end
                end
            end
        end
    end)
    local saved, saveErr = pcall(function()
        if changed and isCurrentCharacter(src, citizenid) then exports.kora_core:savePlayer(src) end
    end)
    starterClaims[src] = nil
    if not ok or not saved then
        print(('[qb-cityhall] Starter item claim failed for %s: %s'):format(src, tostring(err or saveErr)))
    end
end


local function tooFar(src)
    Kora.notify.send(src, { title = 'qb-cityhall', message = Kora.lang('notify.too_far'), type = 'error' })
end

local function hasCarryRoom(src, item)
    if not exports['qb-inventory']:CanAddItem(src, item, 1) then return false end
    if Config.RequireFreeWeight then
        local ok, free = pcall(function() return exports['qb-inventory']:GetFreeWeight(src) end)
        if ok and type(free) == 'number' and free <= 0 then return false end
    end
    return true
end

local function purchaseID(src, key, license)
    assert(src, Kora.lang('asserts.src'))
    assert(key, Kora.lang('asserts.key', src))
    assert(license, Kora.lang('asserts.license', src))
    local cityhall = Config.Cityhalls[key]
    assert(cityhall, Kora.lang('asserts.cityhall', src))
    assert(cityhall.licenses, Kora.lang('asserts.no_licenses', src))
    assert(cityhall.licenses[license], Kora.lang('asserts.license_config_missing', src, license))
    if not Kora.distance.player(src, cityhall.coords, Config.PurchaseDistance) then return tooFar(src) end

    local Player = exports.kora_core:getPlayerData(src)
    if not Player then return end

    local itemInfo = cityhall.licenses[license]
    local info = getLicenseInfo(Player, license)

    local price = tonumber(itemInfo.price) or 0
    if price <= 0 then
        return Kora.notify.send(src, { title = 'qb-cityhall', message = 'This licence is unavailable.', type = 'error' })
    end
    if not hasCarryRoom(src, license) then
        return Kora.notify.send(src, { title = 'qb-cityhall', message = Kora.lang('notify.inventory_full'), type = 'error' })
    end
    if not exports.kora_core:removeMoney(src, 'cash', price, 'cityhall id') then
        return Kora.notify.send(src, {
            title = 'qb-cityhall',
            message = Kora.lang('notify.no_cash', price),
            type = 'error'
        })
    end
    if not exports['qb-inventory']:AddItem(src, license, 1, false, info, 'qb-cityhall:purchaseID') then
        exports.kora_core:addMoney(src, 'cash', price, 'cityhall id refund')
        return Kora.notify.send(src, { title = 'qb-cityhall', message = Kora.lang('notify.inventory_full'), type = 'error' })
    end
end

RegisterNetEvent('qb-cityhall:server:purchaseID', function(key, license)
    purchaseID(source, key, license)
end)

RegisterNetEvent('qb-cityhall:server:requestId', function(item, hall)
    purchaseID(source, hall, item)
end)


local function findNearbyCityhall(src)
    for key, cityhall in pairs(Config.Cityhalls) do
        if Kora.distance.player(src, cityhall.coords, Config.PurchaseDistance) then return key end
    end
end

RegisterNetEvent('qb-cityhall:server:ApplyJob', function(key, job)
    local src = source
    assert(src, Kora.lang('asserts.src'))
    if type(key) == 'string' and not Config.Cityhalls[key] then
        key, job = findNearbyCityhall(src), key
        if not key then return end
    end
    assert(type(job) == 'string' and Config.AvailableJobs[job], Kora.lang('asserts.job_doesnt_exist', src, job))
    assert(Config.Cityhalls[key], Kora.lang('asserts.cityhall', src))
    if not Kora.distance.player(src, Config.Cityhalls[key].coords, Config.PurchaseDistance) then return tooFar(src) end
    if exports.kora_multijob:addJob(src, job, 1) then
        Kora.notify.send(src, { title = 'qb-cityhall', message = 'You have successfully applied for the job.', type = 'success' })
    end
end)

exports('AddCityJob', function(jobName, toCH)
    if type(jobName) ~= 'string' or Config.AvailableJobs[jobName] then return false, 'already added' end
    toCH = type(toCH) == 'table' and toCH or {}
    Config.AvailableJobs[jobName] = { label = toCH.label, isManaged = toCH.isManaged }
    return true, 'success'
end)

RegisterNetEvent('qb-cityhall:server:getIDs', giveStarterItems)
