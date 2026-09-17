Config = Config or {}
local Jobs, Items = exports['qb-core']:GetShared('Jobs'), exports['qb-core']:GetShared('Items')
Config.Jobs = {}
Config.AvailableJobs = {
    'trucker',
    'taxi',
    'tow',
    'reporter',
    'garbage',
    'bus',
    'hotdog'
}

for _, jobName in ipairs(Config.AvailableJobs) do
    if Jobs[jobName] then
        Config.Jobs[jobName] = {
            job = jobName,
            label = Jobs[jobName].label,
        }
    end
end

local function returnItemData(itemName, price, meta)
    local item = {'id_card', 'driver_license', 'weaponlicense'}
    local array = {}
    for _, v in ipairs(item) do
        array[v] = {
            label = Items[v] and Items[v].label or 'Missing item',
            price = price,
            metadata = meta or nil
        }
        if array[v].label == 'Missing item' then
            array[v] = nil
        end
    end
    return array
end

Config.Cityhalls = {
    {
        ped = 'a_m_m_hasjew_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        coords = vec3(-265.0, -963.6, 31.2),
        blipData = {
            sprite = 487,
            display = 4,
            scale = 0.65,
            color = 0,
            title = 'City Services'
        },
        licenses = returnItemData('id_card', 50),
    },
}

-- Registers this resource-owned configuration with qblib.
Config = QB.config.adopt(Config)
