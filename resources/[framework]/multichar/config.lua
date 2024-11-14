return {
    max_character_slots = 4,
    max_player_character = 2,
    selected_anim = {},
    deleted_anim = {},

    player_location = vec4(-1015.14, -2752.40, 0.80, 319.96),
    
    -- character_selector_cam = { pos = vec3(), rot = vec3() },

    slots = {
        [1] = {
            pos = vec4(-1015.80, -2749.26, 0.80, 357.70),
            scenario = 'WORLD_HUMAN_GUARD_STAND'
        },
        [2] = {
            pos = vec4(-1018.04, -2752.48, 0.80, 97.96),
           scenario = 'WORLD_HUMAN_GUARD_STAND_FACILITY'
        },
        [3] = {
            pos = vec4(-1015.02, -2755.25, 0.80, 193.04),
           scenario = 'WORLD_HUMAN_DRINKING'
        },
        [4] = {
            pos = vec4(-1012.29, -2752.06, 0.80, 273.79),
           scenario = 'WORLD_HUMAN_AA_COFFEE'
        }
    },

    
    -- spawn_preview = vec4(118.46, -1730.23, 30.11, 98.76),
    -- spawn_cam_top = { pos = vec3(118.46, -1730.23, 90.21), rot = vec3(7.96, -1.00, 11.93), fov = 51.00 },
    -- spawn_cam_forward = { pos = vec3(115.70, -1730.83, 30.51), rot = vec3(-8.26, 0.00, -69.60), fov = 51.00 },
    spawn_coords = {
        { title = 'Delegacia da Praça', pos = vec4(423.33, -977.89, 30.71, 86.30) },
        { title = 'Delegacia de Sandy Shore', pos = vec4(1858.03, 3680.19, 33.77, 212.71) },
        { title = 'Delegacia de Paleto', pos = vec4(-438.52, 6021.01, 31.49, 312.22) },
        { title = 'Delegacia de Vinewood', pos = vec4(-555.73, -135.47, 38.26, 218.43) },
    },
    -- spawn_preview_anims = {
    --     { dict = 'anim@amb@nightclub@dancers@crowddance_facedj@hi_intensity',  name = 'hi_dance_facedj_09_v2_female^1' },
    --     { dict = 'anim@amb@nightclub@lazlow@hi_dancefloor@',                   name = 'crowddance_hi_11_handup_laz' },
    --     { dict = 'anim@amb@nightclub@dancers@solomun_entourage@',              name = 'mi_dance_facedj_17_v1_female^1' },
    --     { dict = 'anim@amb@nightclub@lazlow@hi_podium@',                       name = 'danceidle_hi_17_smackthat_laz' },
    --     { dict = 'anim@amb@nightclub_island@dancers@crowddance_single_props@', name = 'hi_dance_prop_11_v1_female^3' }
    -- }
}
