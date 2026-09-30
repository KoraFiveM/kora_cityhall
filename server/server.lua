local QBCore = exports['qb-core']:GetCoreObject({'Shared'})

local function getLicenseInfo(Player, license)
    local charinfo = Player.PlayerData.charinfo
    if license == 'id_card' then
        return {
            citizenid = Player.PlayerData.citizenid,
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
    local current = exports['qb-core']:GetPlayer(src)
    return current and current.PlayerData.citizenid == citizenid
end

local function giveStarterItems()
    local src = source
    if starterClaims[src] then return end
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end
    local remaining = Player.GetMetaData('starterItems')
    if type(remaining) ~= 'table' then return end
    local citizenid = Player.PlayerData.citizenid

    starterClaims[src] = true
    local changed = false
    local ok, err = pcall(function()
        for _, starterItem in pairs(QBCore.Shared.StarterItems) do
            local item = starterItem.item
            if remaining[item] == true then
                if not isCurrentCharacter(src, citizenid) then return end
                -- Inventory hooks can re-enter this event or save player data.
                -- Consume this item first so neither can observe it as unclaimed.
                remaining[item] = false
                if not Player.SetMetaData('starterItems', remaining) then
                    error('Unable to reserve starter item entitlement')
                end
                changed = true
                if not isCurrentCharacter(src, citizenid) then return end
                local info = getLicenseInfo(Player, item)
                local added = exports['qb-inventory']:AddItem(src, item, 1, false, info, 'qb-cityhall:giveStarterItems')
                if added == false then
                    if not isCurrentCharacter(src, citizenid) then return end
                    remaining[item] = true
                    if not Player.SetMetaData('starterItems', remaining) then
                        error('Unable to restore failed starter item entitlement')
                    end
                end
            end
        end
    end)
    local saved, saveErr = pcall(function()
        if changed and isCurrentCharacter(src, citizenid) then Player.Save() end
    end)
    starterClaims[src] = nil
    if not ok or not saved then
        print(('[qb-cityhall] Starter item claim failed for %s: %s'):format(src, tostring(err or saveErr)))
    end
end


RegisterNetEvent('qb-cityhall:server:purchaseID', function(key, license)
    local src = source
    assert(src, QB.lang('asserts.src'))
    assert(key, QB.lang('asserts.key', src))
    assert(license, QB.lang('asserts.license', src))
    local cityhall = Config.Cityhalls[key]
    assert(cityhall, QB.lang('asserts.cityhall', src))
    assert(cityhall.licenses, QB.lang('asserts.no_licenses', src))
    assert(cityhall.licenses[license], QB.lang('asserts.license_config_missing', src, license))
    assert(QB.distance.player(src, cityhall.coords, 5.0), QB.lang('asserts.cityhall_too_far', src))

    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end

    local itemInfo = cityhall.licenses[license]
    local info = getLicenseInfo(Player, license)

    local price = tonumber(itemInfo.price) or 0
    if price <= 0 then
        return QB.notify.send(src, { title = 'qb-cityhall', message = 'This licence is unavailable.', type = 'error' })
    end
    if not exports['qb-inventory']:CanAddItem(src, license, 1) then
        return QB.notify.send(src, { title = 'qb-cityhall', message = 'Your inventory is full.', type = 'error' })
    end
    if not Player.RemoveMoney('cash', price, 'cityhall id') then
        return QB.notify.send(src, {
            title = 'qb-cityhall',
            message = QB.lang('notify.no_cash', price),
            type = 'error'
        })
    end
    if not exports['qb-inventory']:AddItem(src, license, 1, false, info, 'qb-cityhall:purchaseID') then
        Player.AddMoney('cash', price, 'cityhall id refund')
        return QB.notify.send(src, { title = 'qb-cityhall', message = 'Your inventory is full.', type = 'error' })
    end
end)


RegisterNetEvent('qb-cityhall:server:ApplyJob', function(key, job)
    assert(source, QB.lang('asserts.src'))
    assert(type(job) == 'string' and Config.Jobs[job], QB.lang('asserts.job_doesnt_exist', source, job))
    assert(Config.Cityhalls[key], QB.lang('asserts.cityhall', source))
    assert(QB.distance.player(source, Config.Cityhalls[key].coords, 5.0), QB.lang('asserts.cityhall_too_far', source))
    exports.qbmultijob:addJob(source, job, 1)
end)

RegisterNetEvent('qb-cityhall:server:getIDs', giveStarterItems)
