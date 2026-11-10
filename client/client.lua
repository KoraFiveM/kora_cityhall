
local APP_ID = 'qb-cityhall:kiosk'

local function buildIdentityItems(key)
    local tbl
    if not Config or not Config.Cityhalls[key] or not Config.Cityhalls[key].licenses then 
        tbl = {
            id_card = {label = 'id_card', price = 100, image = 'default'}
        }
    else
        tbl = Config.Cityhalls[key].licenses
    end

    local items = {}
    for license, data in pairs(tbl) do
        local item = exports.kora_core:getShared('items', license)
        items[#items + 1] = {
            id = license,
            label = item and item.label or license,
            description = Kora.lang('menus.license_cost', data.price),
            image = 'nui://kora_inventory/images/' .. (item and item.image or 'default'),
            action = {
                id = 'purchase:' .. license,
                label = Kora.lang('menus.purchase') or 'Purchase',
                variant = 'primary',
                confirm = Config.ConfirmActions and Kora.lang('menus.confirm_purchase', item and item.label or license, data.price) or nil,
            },
        }
    end
    return items
end

local function buildJobItems()
    local items = {}
    for jobName in pairs(Config.AvailableJobs) do
        local job = exports.kora_core:getShared('jobs', jobName)
        items[#items + 1] = {
            id = jobName,
            label = job and job.label or jobName,
            description = Kora.lang('menus.apply_job'),
            icon = 'Briefcase',
            action = {
                id = 'apply:' .. jobName,
                label = Kora.lang('menus.apply') or 'Apply',
                variant = 'primary',
                confirm = Config.ConfirmActions and Kora.lang('menus.confirm_apply', job and job.label or jobName) or nil,
            },
        }
    end
    return items
end

local function buildNavigation(key)
    return {
        {
            id = 'identity',
            label = Kora.lang('menus.id_card'),
            icon = 'IdCard',
            content = {
                title = Kora.lang('menus.id_card'),
                description = Kora.lang('menus.id_card_desc'),
                blocks = {
                    { type = 'list', layout = 'cards', items = buildIdentityItems(key) },
                },
            },
        },
        {
            id = 'jobs',
            label = Kora.lang('menus.job_center'),
            icon = 'Briefcase',
            content = {
                title = Kora.lang('menus.job_center'),
                description = Kora.lang('menus.job_center_desc'),
                blocks = {
                    { type = 'list', layout = 'cards', items = buildJobItems() },
                },
            },
        },
    }
end

local function onAppAction(actionId, context)
    local key = context.data and context.data.key
    if not key then return end

    local license = actionId:match('^purchase:(.+)$')
    if license then
        TriggerServerEvent('qb-cityhall:server:purchaseID', key, license)
        return
    end

    local jobName = actionId:match('^apply:(.+)$')
    if jobName then
        TriggerServerEvent('qb-cityhall:server:ApplyJob', key, jobName)
    end
end

local function registerCityhallApp(initialKey)
    Kora.nui.registerApp({
        id = APP_ID,
        title = Kora.lang('menus.city_hall'),
        icon = 'Landmark',
        layout = 'compact',
        defaultView = 'identity',
        placement = 'right',
        navigation = buildNavigation(initialKey),
        onAction = onAppAction,
    })
end

local function openCityhallMenu(key)
    Kora.nui.updateApp(APP_ID, { navigation = buildNavigation(key) })
    Kora.nui.openApp(APP_ID, { data = { key = key } })
end

local function init()
    local initialKey = next(Config.Cityhalls)
    if not initialKey then return end
    registerCityhallApp(initialKey)

    for key, cityhall in pairs(Config.Cityhalls) do
        local ped = Kora.entities.create(cityhall.ped or 'a_m_m_hasjew_01', cityhall.coords, {freeze = true, invincible = true, blockNonTempEvents = true})
        SetEntityHeading(ped, cityhall.coords.w)
        SetPedCanRagdoll(ped, false)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 17, true)
        TaskStartScenarioInPlace(ped, cityhall.scenario or 'WORLD_HUMAN_STAND_MOBILE', 0, true)
        if cityhall.blipData then
            Kora.blips.create(cityhall.coords, {
                sprite = cityhall.blipData.sprite,
                scale = cityhall.blipData.scale,
                color = cityhall.blipData.color,
                label = cityhall.blipData.title
            })
        end
        exports.kora_target:addEntity(ped, {
            {
                icon = Kora.lang('menus.city_hall_icon'),
                label = Kora.lang('menus.city_hall'),
                onSelect = function()
                    openCityhallMenu(key)
                end
            }
        })
    end
end

init()

local function nearestCityhallKey()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local best, bestDist
    for key, cityhall in pairs(Config.Cityhalls) do
        local dist = #(pos - vec3(cityhall.coords.x, cityhall.coords.y, cityhall.coords.z))
        if not bestDist or dist < bestDist then best, bestDist = key, dist end
    end
    return best
end

for _, name in ipairs({ 'openCityhallMenu', 'openIdentityMenu', 'openJobMenu' }) do
    RegisterNetEvent('qb-cityhall:client:' .. name, function()
        local key = nearestCityhallKey()
        if key then openCityhallMenu(key) end
    end)
end

RegisterNetEvent('qb-cityhall:client:getIds', function()
    TriggerServerEvent('qb-cityhall:server:getIDs')
end)

-- kora_clothing opens the mandatory first-character fitting room for new
-- characters; once it closes the server hands over the pending starter items.
-- Characters that still have them pending (disconnected mid-creation) get them
-- on their next spawn.
local awaitingFirstOutfit = false

AddEventHandler('qb-clothing:client:CreateFirstCharacter', function()
    awaitingFirstOutfit = Config.GiveStarterItems == true
end)

AddEventHandler('qb-clothing:client:onMenuClose', function()
    if not awaitingFirstOutfit then return end
    awaitingFirstOutfit = false
    TriggerServerEvent('qb-cityhall:server:getIDs')
end)

AddEventHandler('kora_multichar:client:spawnComplete', function(isNew)
    if isNew ~= true and Config.GiveStarterItems then TriggerServerEvent('qb-cityhall:server:getIDs') end
end)
