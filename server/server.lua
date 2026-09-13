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


local function giveStarterItems()
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end
    for _, starterItem in pairs(QBCore.Shared.StarterItems) do
        local item = starterItem.item
        local info = getLicenseInfo(Player, item)
        exports['qb-inventory']:AddItem( src, item, 1, false, info, 'qb-cityhall:giveStarterItems')
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

    if not Player.RemoveMoney('cash', itemInfo.cost, 'cityhall id') then
        return QB.notify.send(src, {
            title = 'qb-cityhall',
            message = QB.lang('notify.no_cash', itemInfo.cost),
            type = 'error'
        })
    end
    exports['qb-inventory']:AddItem( src, license, 1, false, info, 'qb-cityhall:purchaseID')
end)


RegisterNetEvent('qb-cityhall:server:ApplyJob', function(key, job)
    assert(source, QB.lang('asserts.src'))
    assert(type(job) == 'string' and Config.Jobs[job], QB.lang('asserts.job_doesnt_exist', source, job))
    assert(Config.Cityhalls[key], QB.lang('asserts.cityhall', source))
    assert(QB.distance.player(source, Config.Cityhalls[key].coords, 5.0), QB.lang('asserts.cityhall_too_far', source))
    exports.qbmultijob:addJob(source, job, 1)
end)

RegisterNetEvent('qb-cityhall:server:getIDs', giveStarterItems)
