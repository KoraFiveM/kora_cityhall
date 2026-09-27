
local APP_ID = 'qb-cityhall:kiosk'

local function buildIdentityItems(key)
    local tbl = nil
    if not Config or not Config.Cityhalls[key] or not Config.Cityhalls[key].licenses then 
        tbl = {
            id_card = {label = 'id_card', price = 100, image = 'default'}
        }
    else
        tbl = Config.Cityhalls[key].licenses
    end

    local items = {}
    for license, data in pairs(tbl) do
        local item = exports.qbcore:getShared('items', license)
        table.insert(items, {
            id = license,
            label = item and item.label or data.label,
            description = QB.lang('menus.license_cost', data.price),
            image = 'nui://qbinventory/images/' .. (item and item.image or data.image),
            action = {
                id = 'purchase:' .. license,
                label = QB.lang('menus.purchase') or 'Purchase',
                variant = 'primary',
            },
        })
    end
    return items
end

local function buildJobItems()
    local items = {}
    for jobName, jobData in pairs(Config.Jobs) do
        table.insert(items, {
            id = jobName,
            label = jobData.label,
            description = QB.lang('menus.apply_job'),
            icon = 'Briefcase' or nil,
            action = {
                id = 'apply:' .. jobName,
                label = QB.lang('menus.apply') or 'Apply',
                variant = 'primary',
            },
        })
    end
    return items
end

local function buildNavigation(key)
    return {
        {
            id = 'identity',
            label = QB.lang('menus.id_card'),
            icon = 'IdCard',
            content = {
                title = QB.lang('menus.id_card'),
                description = QB.lang('menus.id_card_desc'),
                blocks = {
                    { type = 'list', layout = 'cards', items = buildIdentityItems(key) },
                },
            },
        },
        {
            id = 'jobs',
            label = QB.lang('menus.job_center'),
            icon = 'Briefcase',
            content = {
                title = QB.lang('menus.job_center'),
                description = QB.lang('menus.job_center_desc'),
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
    QB.nui.registerApp({
        id = APP_ID,
        title = QB.lang('menus.city_hall'),
        icon = 'Landmark',
        layout = 'compact',
        defaultView = 'identity',
        placement = 'right',
        navigation = buildNavigation(initialKey),
        onAction = onAppAction,
    })
end

local function openCityhallMenu(key)
    QB.nui.updateApp(APP_ID, { navigation = buildNavigation(key) })
    QB.nui.openApp(APP_ID, { data = { key = key } })
end

local function init()
    local initialKey = next(Config.Cityhalls)
    if not initialKey then return end
    registerCityhallApp(initialKey)

    for key, cityhall in pairs(Config.Cityhalls) do
        local ped = QB.entities.create(cityhall.ped or 'a_m_m_hasjew_01', cityhall.coords, {freeze = true, invincible = true})
        SetEntityHeading(ped, cityhall.coords.w)
        TaskStartScenarioInPlace(ped, cityhall.scenario or 'WORLD_HUMAN_STAND_MOBILE', 0, true)
        if cityhall.blipData then
            QB.blips.create(cityhall.coords, {
                sprite = cityhall.blipData.sprite,
                scale = cityhall.blipData.scale,
                color = cityhall.blipData.color,
                label = cityhall.blipData.title
            })
        end
        exports.qbtarget:addEntity(ped, {
            {
                icon = QB.lang('menus.city_hall_icon'),
                label = QB.lang('menus.city_hall'),
                onSelect = function()
                    openCityhallMenu(key)
                end
            }
        })
    end
end

init()
