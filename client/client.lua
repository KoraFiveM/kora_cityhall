
local function openIdentityMenu(key)
    local identityMenu = {
        {header = 'Identity', isMenuHeader = true},
    }
    for license, data in pairs(Config.Cityhalls[key].licenses) do
        table.insert(identityMenu, {
            header = data.label,
            txt = QB.lang('menus.license_cost', data.price),
            action = function()
               TriggerServerEvent('qb-cityhall:server:purchaseID', key, license)
           end
        })
    end
    exports['qb-menu']:openMenu(identityMenu)
end

local function openJobMenu(key)
    local jobMenu = {
        { header = QB.lang('menus.job_center'), isMenuHeader = true }
    }
    for jobName, jobData in pairs(Config.Jobs) do
        table.insert(jobMenu, {
            header = jobData.label,
            txt = QB.lang('menus.apply_job'),
            action = function()
                TriggerServerEvent('qb-cityhall:server:ApplyJob', key, jobName)
            end
        })
    end
    exports['qb-menu']:openMenu(jobMenu)
end

local function openCityhallMenu(key)
    exports['qb-menu']:openMenu({
        { header = QB.lang('menus.city_hall'), isMenuHeader = true},
        {
            header = QB.lang('menus.id_card'),
            txt = QB.lang('menus.id_card_desc'),
            action = function()
                openIdentityMenu(key)
            end
        },
        {
            header = QB.lang('menus.job_center'),
            txt = QB.lang('menus.job_center_desc'),
            action = function()
                openJobMenu(key)
            end
        },
    })
end

local function init()
    for key, cityhall in pairs(Config.Cityhalls) do
        local ped = QB.entities.create(cityhall.ped or 'a_m_m_hasjew_01', cityhall.coords, {freeze = true, invincible = true})
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
