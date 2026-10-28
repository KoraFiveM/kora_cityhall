local sourceFile = debug.getinfo(1, 'S').source:sub(2)
local resourceDirectory = (sourceFile:match('^(.*[/\\])') or './') .. '../'

local function clone(value)
    if type(value) ~= 'table' then return value end
    local copy = {}
    for key, item in pairs(value) do copy[key] = clone(item) end
    return copy
end

local events, players, attempts, failures, saved = {}, {}, {}, {}, {}
local onAdd, onSet, failSet, failSave
local warnings = 0
local saves = 0
local realPrint = print
print = function(message)
    if tostring(message):find('Starter item claim failed', 1, true) then warnings = warnings + 1
    else realPrint(message) end
end
RegisterNetEvent = function(name, handler) events[name] = handler end
local starters = {
    phone = { item = 'phone', amount = 9 },
    id_card = { item = 'id_card', amount = 1 },
    driver_license = { item = 'driver_license', amount = 1 },
}
exports = {
    kora_core = {
        getStarterItems = function() return starters end,
        getPlayerData = function(_, src) return clone(players[src]) end,
        getMetaData = function(_, src, key) return clone(players[src].metadata[key]) end,
        setMetaData = function(_, src, key, value)
            if failSet then return false end
            players[src].metadata[key] = clone(value)
            if onSet then onSet(src, key) end
            return true
        end,
        savePlayer = function(_, src)
            saves = saves + 1
            if failSave then error('save export failed') end
            saved[src] = clone(players[src])
            return true
        end,
    },
    ['qb-inventory'] = {
        AddItem = function(_, src, item, amount, slot, info, reason)
            attempts[item] = (attempts[item] or 0) + 1
            assert(amount == 1 and slot == false and reason == 'qb-cityhall:giveStarterItems')
            local pending = players[src].metadata.starterItems
            assert(type(pending) == 'table' and pending[item] == false, 'reserve entitlement through the setter before granting')
            if onAdd then onAdd(src, item) end
            if failures[item] == 'error' then error('inventory export failed') end
            if failures[item] == 'nil' then return nil end
            if failures[item] then return false end
            local data = players[src]
            data.items[item] = (data.items[item] or 0) + amount
            data.info = data.info or {}
            data.info[item] = clone(info)
            return true
        end,
    },
}
dofile(resourceDirectory .. 'server/server.lua')
local claim = assert(events['qb-cityhall:server:getIDs'], 'legacy network event must stay registered')

local function reset(pending, citizenid)
    players = { [1] = {
        citizenid = citizenid or 'NEW',
        charinfo = { firstname = 'Test', lastname = 'Player', birthdate = '1990-01-01', gender = 0, nationality = 'USA' },
        metadata = { starterItems = clone(pending) }, items = {},
    } }
    attempts, failures, saved = {}, {}, {}
    onAdd, onSet, failSet, failSave = nil, nil, nil, nil
    warnings = 0
    saves = 0
    source = 1
end

reset(nil, 'OLD')
claim(99, { starterItems = { phone = true }, items = { phone = 100 } })
assert(next(attempts) == nil and players[1].metadata.starterItems == nil and saves == 0, 'old characters and forged payloads must fail closed')
players[1] = nil
claim()
assert(next(attempts) == nil, 'unloaded players cannot claim')
realPrint('ok 1 - old and unloaded characters cannot claim, including forged payloads')

reset({ phone = true, id_card = true, driver_license = true, unconfigured = true })
onAdd = function() claim() end
claim()
onAdd = nil
claim()
assert(saves == 1, 'consumed replay and reentrant calls must not save again')
for item in pairs(starters) do
    assert(players[1].items[item] == 1 and attempts[item] == 1, 'duplicate or reentrant grant: ' .. item)
    assert(saved[1].metadata.starterItems[item] == false)
end
assert(players[1].items.unconfigured == nil, 'unconfigured entitlement names must not grant items')
assert(players[1].info.id_card.citizenid == 'NEW' and players[1].info.driver_license.type == 'Class C Driver License')
players[1] = clone(saved[1])
claim()
assert(attempts.phone == 1 and attempts.id_card == 1 and attempts.driver_license == 1, 'saved consumed state must survive re-login')
assert(saves == 1, 're-login with consumed state must not save again')
realPrint('ok 2 - snapshot setters reserve once, preserve licence data and quantity, and survive replay/re-login')

reset({ phone = true, id_card = true, driver_license = true })
failures.id_card = true
claim()
assert(players[1].items.phone == 1 and players[1].items.driver_license == 1 and players[1].items.id_card == nil)
assert(saved[1].metadata.starterItems.id_card == true and saved[1].metadata.starterItems.phone == false)
failures.id_card = nil
players[1] = clone(saved[1])
claim()
assert(players[1].items.phone == 1 and players[1].items.driver_license == 1 and players[1].items.id_card == 1)
assert(attempts.phone == 1 and attempts.driver_license == 1 and attempts.id_card == 2)
realPrint('ok 3 - partial capacity failures restore only the failed item for a later retry')

reset({ phone = true })
failSet = true
claim()
assert(next(attempts) == nil and players[1].metadata.starterItems.phone == true, 'failed entitlement setter must block grants')
failSet = nil
claim()
assert(players[1].items.phone == 1, 'setter errors must release the in-flight guard')
reset({ phone = true })
failures.phone = 'error'
claim()
assert(players[1].metadata.starterItems.phone == false and warnings == 1, 'ambiguous export errors must not reopen a token')
players[1].metadata.starterItems.id_card = true
failures.phone = nil
claim()
assert(attempts.phone == 1 and players[1].items.id_card == 1, 'inventory errors must release the in-flight guard')
reset({ phone = true })
failures.phone = 'nil'
claim()
claim()
assert(players[1].metadata.starterItems.phone == false and attempts.phone == 1, 'only an explicit false result may reopen the token')
reset({ phone = true })
failSave = true
claim()
failSave = nil
players[1].metadata.starterItems.id_card = true
claim()
assert(players[1].items.phone == 1 and players[1].items.id_card == 1, 'save errors must release the in-flight guard')
realPrint('ok 4 - setter, inventory and save errors release guards without duplicate grants')

reset({ phone = true })
onSet = function()
    onSet = nil
    players[1] = {
        citizenid = 'OTHER', charinfo = {}, metadata = {}, items = {},
    }
end
claim()
assert(next(attempts) == nil and players[1].metadata.starterItems == nil, 'character change during an export must abort further grants')
onSet = nil
players[1].charinfo = { firstname = 'Other', lastname = 'Character' }
players[1].metadata.starterItems = { id_card = true }
claim()
assert(players[1].items.id_card == 1, 'aborted claims must not lock the next character')
realPrint('ok 5 - a character change during an export stops stale claims')
print = realPrint
print('5 starter-item tests passed')
