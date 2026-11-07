Config = Config or {}

-- Maximum distance (metres) between a player and the cityhall ped for the server
-- to accept a licence purchase or job application.
Config.PurchaseDistance = 5.0
-- Refuse a licence purchase when the player cannot carry anything more (free
-- inventory weight is 0 or less), even if the licence itself weighs nothing.
Config.RequireFreeWeight = true
-- Ask the player to confirm before a licence is bought or a job is applied for.
Config.ConfirmActions = true
-- Grant the pending starter items (ID card, licences...) once the first-character
-- outfit is confirmed, and on spawn for characters that still have them pending.
Config.GiveStarterItems = true
Config.AvailableJobs = {
    trucker = true,
    taxi = true,
    tow = true,
    reporter = true,
    garbage = true,
    bus = true,
    hotdog = true,
}

Config.Cityhalls = {
    {
        ped = 'a_m_m_hasjew_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        coords = vec4(-264.28, -966.29, 30.22, 210.0),
        blipData = {
            sprite = 487,
            display = 4,
            scale = 0.65,
            color = 0,
            title = 'City Services'
        },
        licenses = {
            id_card = {
                price = 50,
            },
            driver_license = {
                price = 100,
            },
            weaponlicense = {
                price = 200,
            }
        },
    },
}

Config = Kora.config.adopt(Config)
