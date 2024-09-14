lib.locale()

BeatyConfig = {}

BeatyConfig.stores = {
    --#region CLOTHE STORES
    {
        location = vec3(1693.5, 4826.5, 42.25),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(1693.5, 4827.55, 42.0),
            heading = 185.0,
            size = vec3(1.75, 2.25, 2.25),
        }
    },
    {
        location = vec3(1198.0, 2701.64, 38.16),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(1192.69, 2710.17, 38.22),
            heading = 271.46,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(84.15, -1391.58, 29.42),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(75.37, -1396.85, 29.38),
            heading = 358.02,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(416.17, -807.46, 29.37),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(425.59, -802.17, 29.49),
            heading = 178.09,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(-1203.53, -779.68, 17.33),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(-1189.07, -769.17, 17.32),
            heading = 117.76,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(-2.59, 6518.31, 31.49),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec(8.30, 6515.15, 31.88),
            heading = 133.36,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(127.91, -209.31, 54.55),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(121.33, -224.83, 54.56),
            heading = 336.63,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(-1094.94, 2705.02, 19.08),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(-1104.25, 2708.23, 19.11),
            heading = 307.37,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(-3167.02, 1059.33, 20.86),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(-3174.99, 1042.71, 20.86),
            heading = 337.07,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(-816.74, -1080.8, 11.13),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(-825.73, -1075.67, 11.33),
            heading = 299.18,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(-155.0, -306.12, 38.74),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(-159.08, -298.03, 39.73),
            heading = 249.07,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    {
        location = vec3(-717.77, -157.39, 36.99),
        label = locale('clothe_shop_title'),
        type = 1,
        blip = {
            icon = 73,
            color = 0,
            size = 1.0
        },
        zone = {
            coord = vec3(-708.69, -159.72, 37.42),
            heading = 113.88,
            size = vec3(2.5, 2.5, 3.0),
        }
    },
    --#endregion
    --#region TATTOO
    {
        location = vec3(1320.7, -1648.84, 52.15),
        label = locale('tattoo_shop_title'),
        type = 3,
        blip = {
            icon = 75,
            color = 0,
            size = 1.0
        },
        ped = {
            model = `u_m_y_tattoo_01`,
            pos = vec4(1322.34, -1652.84, 52.28, 305.71),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vec3(-1155.8, -1422.3, 4.78),
        label = locale('tattoo_shop_title'),
        type = 3,
        blip = {
            icon = 75,
            color = 0,
            size = 1.0
        },
        ped = {
            model = `u_m_y_tattoo_01`,
            pos = vec4(-1154.5, -1426.14, 4.9, 305.71),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vec3(320.28, 176.13, 103.67),
        label = locale('tattoo_shop_title'),
        type = 3,
        blip = {
            icon = 75,
            color = 0,
            size = 1.0
        },
        ped = {
            model = `u_m_y_tattoo_01`,
            pos = vec4(323.16, 180.14, 103.59, 66.63),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vec3(-3166.37, 1073.4, 20.85),
        label = locale('tattoo_shop_title'),
        type = 3,
        blip = {
            icon = 75,
            color = 0,
            size = 1.0
        },
        ped = {
            model = `u_m_y_tattoo_01`,
            pos = vec4(-3169.35, 1076.1, 20.83, 150.94),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vec3(1858.86, 3748.58, 33.07),
        label = locale('tattoo_shop_title'),
        type = 3,
        blip = {
            icon = 75,
            color = 0,
            size = 1.0
        },
        ped = {
            model = `u_m_y_tattoo_01`,
            pos = vec4(1865.32, 3748.97, 33.05, 119.37),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vec3(-288.7, 6200.66, 31.47),
        label = locale('tattoo_shop_title'),
        type = 3,
        blip = {
            icon = 75,
            color = 0,
            size = 1.0
        },
        ped = {
            model = `u_m_y_tattoo_01`,
            pos = vec4(-294.56, 6198.44, 31.5, 319.27),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    --#endregion
    --#region BARBER
    {
        location = vec3(-282.58, 6233.62, 31.49),
        label = locale('barber_shop_title'),
        type = 2,
        blip = {
            icon = 71,
            color = 0,
            size = 1.0,
        },
        ped = {
            model = `s_f_m_fembarber`,
            pos = vec4(-276.75, 6226.79, 31.70, 41.94),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vector3(1935.82, 3721.73, 32.87),
        label = locale('barber_shop_title'),
        type = 2,
        blip = {
            icon = 71,
            color = 0,
            size = 1.0,
        },
        ped = {
            model = `s_f_m_fembarber`,
            pos = vec4(1930.63, 3732.35, 32.84, 205.91),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vector3(-29.63, -144.96, 57.03),
        label = locale('barber_shop_title'),
        type = 2,
        blip = {
            icon = 71,
            color = 0,
            size = 1.0,
        },
        ped = {
            model = `s_f_m_fembarber`,
            pos = vec4(-33.53, -154.15, 57.08, 340.30),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vector3(-824.49, -188.58, 37.62),
        label = locale('barber_shop_title'),
        type = 2,
        blip = {
            icon = 71,
            color = 0,
            size = 1.0,
        },
        ped = {
            model = `s_f_m_fembarber`,
            pos = vec4(-813.01, -183.68, 37.57, 116.28),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vector3(-1290.28, -1116.52, 6.64),
        label = locale('barber_shop_title'),
        type = 2,
        blip = {
            icon = 71,
            color = 0,
            size = 1.0,
        },
        ped = {
            model = `s_f_m_fembarber`,
            pos = vec4(-1280.51, -1117.30, 6.99, 87.81),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vector3(1204.3, -469.89, 66.27),
        label = locale('barber_shop_title'),
        type = 2,
        blip = {
            icon = 71,
            color = 0,
            size = 1.0,
        },
        ped = {
            model = `s_f_m_fembarber`,
            pos = vec4(1214.26, -473.32, 66.21, 70.11),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    },
    {
        location = vec3(131.51, -1713.55, 29.27),
        label = locale('barber_shop_title'),
        type = 2,
        blip = {
            icon = 71,
            color = 0,
            size = 1.0,
        },
        ped = {
            model = `s_f_m_fembarber`,
            pos = vec4(138.28, -1706.91, 29.29, 135.90),
            anim = {
                dict = 'anim@heists@heist_corona@team_idles@male_a',
                name = 'idle'
            }
        }
    }
    --#endregion
}
