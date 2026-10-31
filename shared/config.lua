Config = Config or {}
Config.Jobs = {}
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
