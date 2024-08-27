local cfg = module('cfg/base')

---@type { enabled: boolean, showPlayerCount: true, appId: string, iconLarge: string, iconLargeHoverText: string, iconSmall: string, iconSmallHoverText: string, buttons: { text: string, url: string}[], updateRate: number }
local discord = cfg?.discord

CreateThread(function()
    while discord.enabled do
        SetDiscordAppId(discord.appId)
        SetDiscordRichPresenceAsset(discord.iconLarge)
        SetDiscordRichPresenceAssetText(discord.iconLargeHoverText)
        SetDiscordRichPresenceAssetSmall(discord.iconSmall)
        SetDiscordRichPresenceAssetSmallText(discord.iconSmallHoverText)

        if discord.showPlayerCount then
            local players = #tvRP.getPlayers() or 1
            SetRichPresence(locale('players') .. ': ' .. players .. '/' .. GetConvarInt('sv_maxclients', 48))
        end

        if discord?.buttons and type(discord?.buttons) == "table" and table.type(discord?.buttons) == 'array' then
            for i = 1, 2 do
                SetDiscordRichPresenceAction(i - 1, discord?.buttons[i].text, discord?.buttons[i].url)
            end
        end

        Wait(discord?.updateRate or 15000)
    end
end)
