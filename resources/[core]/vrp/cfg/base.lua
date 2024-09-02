local cfg = {
    pause_menu_text = '~g~~h~SU\'EL~h~ ~b~VRPEX~y~ 3.1',
    loggin_system = '', --discord, print or database
    fristspawn = vec3(0, 0, 0),
    save_interval = GetConvarInt('vrp:save_interval', 60),
    enable_allowlist = GetConvarInt('vrp:enable_allowlist', 1) == 1, -- enable/disable whitelist
    lang = GetConvar('locale', 'en-US'),
    debug = GetConvarInt('vrp:debug', 0) == 1,
    debug_async_time = 2,
    inventory_weight_per_strength = GetConvarInt('vrp:inventory_weight', 10),
    thirst_per_minute = tonumber(GetConvar('vrp:thirst_per_minute', '2.5')) or 2.5,
    hunger_per_minute = tonumber(GetConvar('vrp:hunger_per_minute', '1.25')) or 1.25,
    overflow_damage_factor = GetConvarInt('vrp:overflow_damage_factor', 2),
    allow_audio_player_from_client = GetConvarInt('vrp:allow_audio_player_from_client', 1) == 1,
    sound_default_distance = GetConvarInt('vrp:sound_default_distance', 100),
    pvp = GetConvarInt('vrp:pvp', 1) == 1,
    phone_format = "DDD-DDD",
    registration_format = 'DDAALAAL',
    coma_duration = 0.2,
    load_duration = 30,
    load_delay = 60,
    global_delay = 0,
    ping_timeout = 5,
    clear_inventory_on_death = GetConvarInt('vrp:clear_inventory', 1) == 1,
    -- illegal items (seize)
    -- specify list of "idname" or "*idname" to seize all parametric items
    money_type = {
        wallet = 5000,
        bank = 15000
    },
    seizable_items = {
        "dirty_money",
        "weed",
        "*wbody",
        "*wammo"
    },
    discord = {
        enabled = false,
        showPlayerCount = true,
        appId = "",
        iconLarge = "",
        iconLargeHoverText = "",
        iconSmall = "",
        iconSmallHoverText = "",
        buttons = {
            { text = "BUTTON 1", url = "" },
            { text = "BUTTON 2", url = "" },
        },
        updateRate = 15000 -- 15 segundos
    },
    disables = {
        driverby = true,
        idlecam = true,
        disable_auto_swap_weapon = GetConvarInt('vrp:disable_auto_swap_weapon', 0) == 1,
        disable_auto_reload = GetConvarInt('vrp:disable_auto_reload', 0) == 1,
    },
    initial_items = {
        ['phone'] = 1,        
        ['bandage'] = 3,
        ['burger'] = 10,
        ['water'] = 10,
    }
}

return cfg
