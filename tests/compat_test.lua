local sourceFile = debug.getinfo(1, 'S').source:sub(2)
local resourceDirectory = (sourceFile:match('^(.*[/\\])') or './') .. '../'

local events, exportsDefined, added, notified, bought = {}, {}, {}, {}, {}
local near, freeWeight, money = {}, 10, {}
RegisterNetEvent = function(name, handler) events[name] = handler end
vec4 = function(x, y, z, w) return { x = x, y = y, z = z, w = w } end
Config = {
    PurchaseDistance = 5.0, RequireFreeWeight = true, GiveStarterItems = true,
    AvailableJobs = { taxi = true },
    Cityhalls = { { coords = vec4(1, 2, 3, 0), licenses = { id_card = { price = 50 } } } },
}
Kora = {
    lang = function(key) return key end,
    distance = { player = function(src, coords) return near[src] == coords end },
    notify = { send = function(src, data) notified[#notified + 1] = data end },
}
exports = setmetatable({
    kora_multijob = { addJob = function(_, src, job, grade) added[#added + 1] = { src, job, grade } return true end },
    kora_core = {
        getPlayerData = function() return { citizenid = 'C', charinfo = {} } end,
        removeMoney = function(_, _, _, amount) money[#money + 1] = -amount return true end,
        addMoney = function(_, _, _, amount) money[#money + 1] = amount return true end,
    },
    ['qb-inventory'] = {
        CanAddItem = function() return true end,
        GetFreeWeight = function() return freeWeight end,
        AddItem = function(_, src, item) bought[#bought + 1] = item return true end,
    },
}, { __call = function(_, name, fn) exportsDefined[name] = fn end })
dofile(resourceDirectory .. 'server/server.lua')

local hall = Config.Cityhalls[1].coords
near[1] = hall
source = 1
events['qb-cityhall:server:ApplyJob']('taxi', { x = 9999, y = 0, z = 0 })
assert(#added == 1 and added[1][2] == 'taxi', 'stock-shaped ApplyJob resolves the hall server-side')
events['qb-cityhall:server:ApplyJob'](1, 'taxi')
assert(#added == 2, 'kora-shaped ApplyJob still works')
near[1] = nil
events['qb-cityhall:server:ApplyJob']('taxi', hall)
assert(#added == 2, 'stock ApplyJob away from every hall is refused despite client coords')
near[1] = hall
assert(not pcall(events['qb-cityhall:server:ApplyJob'], 'police', hall))
assert(not pcall(events['qb-cityhall:server:ApplyJob'], 1, 'police'), 'unlisted jobs are refused')
assert(#added == 2)

events['qb-cityhall:server:requestId']('id_card', 1)
assert(bought[1] == 'id_card', 'requestId aliases purchaseID')
near[1] = nil
events['qb-cityhall:server:requestId']('id_card', 1)
assert(#bought == 1 and #money == 1, 'too-far purchases are refused without charging')
assert(notified[#notified].message == 'notify.too_far', 'too-far purchases tell the player')
near[1] = hall
freeWeight = 0
events['qb-cityhall:server:purchaseID'](1, 'id_card')
assert(#bought == 1 and #money == 1, 'a weight-full inventory blocks the purchase before charging')
assert(notified[#notified].message == 'notify.inventory_full')
Config.RequireFreeWeight = false
events['qb-cityhall:server:purchaseID'](1, 'id_card')
assert(#bought == 2, 'RequireFreeWeight = false restores the capacity-only check')
Config.RequireFreeWeight = true
freeWeight = 10
near[1] = nil

local addCityJob = exportsDefined.AddCityJob
assert(addCityJob, 'AddCityJob export')
assert(select(2, addCityJob('taxi', {})) == 'already added')
assert(addCityJob('bus', { label = 'Bus', isManaged = false}) == true and Config.AvailableJobs.bus.label == 'Bus')
assert(addCityJob('bus', {}) == false)
print('cityhall compat tests passed')
