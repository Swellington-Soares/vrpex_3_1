require '@vrp.lib.utils'
local Proxy = require '@vrp.lib.Proxy'
vRP = Proxy.getInterface('vRP')

--config
Config = {
    Stress = {
        Enable = true,
        AnimFxEffect = "",
        CameraShake = "",
        DamageTime = 3000, 
        ApplyDamageAbove = 80, -- aplicar dano acima da porcentagem
        DamageInfo = {
                BlackScreen = true,
                BlackScreenTime = 2000,
                Damage = 0.05                        
        },
        ByPassJobs = {}
    }
}
