local cfg = {}

--vamos mudar depois para coloca cargos

-- define each group with a set of permissions
-- _config property:
--- title (optional): group display name
--- gtype (optional): used to have only one group with the same gtype per player (example: a job gtype to only have one job)
--- onspawn (optional): function(player) (called when the player spawn with the group)
--- onjoin (optional): function(player) (called when the player join the group)
--- onleave (optional): function(player) (called when the player leave the group)
--- (you have direct access to vRP and vRPclient, the tunnel to client, in the config callbacks)

cfg.groups = {
  ["superadmin"] = {
    _config = { onspawn = function(player) vRP.notify(player, "You are superadmin.", nil, 5000, 'inform') end },
    "player.group.add",
    "player.group.remove",
    "player.givemoney",
    "player.giveitem"
  },
  ["admin"] = {
    "admin.tickets",
    "admin.announce",
    "player.list",
    "player.whitelist",
    "player.unwhitelist",
    "player.kick",
    "player.ban",
    "player.unban",
    "player.noclip",
    "player.custom_emote",
    "player.custom_sound",
    "player.display_custom",
    "player.coords",
    "player.tptome",
    "player.tpto"
  },
  ["god"] = {
    "admin.god" -- reset survivals/health periodically
  },
  -- the group user is auto added to all logged players
  ["user"] = {
    "player.phone",
    "player.calladmin",
    "police.askid",
    "police.store_weapons",
    "police.seizable" -- can be seized
  },
  ["police"] = {
    _config = {
      title = "Police",
      gtype = "job",
      jobtype = 'leo',
      -- onjoin = function(player) vRPclient._setCop(player, true) end,
      -- onspawn = function(player) vRPclient._setCop(player, true) end,
      -- onleave = function(player) vRPclient._setCop(player, false) end,
      grades = {
        [1] = { name = 'Recruta', salary = 1600},
        [2] = { name = 'Capitão', salary = 2400},
        [3] = { name = 'Major', salary = 3800},
        [4] = { name = 'Sargento', salary = 4500 },
        [5] = { name = 'Comando', salary = 8000, isboss = true },
      }
    },
    "police.menu",
    "police.cloakroom",
    "police.pc",
    "police.handcuff",
    "police.drag",
    "police.putinveh",
    "police.getoutveh",
    "police.check",
    "police.service",
    "police.wanted",
    "police.seize.weapons",
    "police.seize.items",
    "police.jail",
    "police.fine",
    "police.announce",
    "-police.store_weapons",
    "-police.seizable" -- negative permission, police can't seize itself, even if another group add the permission
  },
  ["emergency"] = {
    _config = {
      title = "Emergency",
      gtype = "job",
      jobtype = 'ems',
      grades = {
        [1] = { name = 'Enfermeiro', salary = 1580 },
        [2] = { name = 'Médico', salary = 2500 },
        [3] = { name = 'Médico Especialista', salary = 3500 },
        [4] = { name = 'Diretor', salary = 4500, isboss = true },
      }
    },
    "emergency.revive",
    "emergency.shop",
    "emergency.service"
  },
  ["repair"] = {
    _config = {
      title = "Repair",
      gtype = "job"
    },
    "vehicle.repair",
    "vehicle.replace",
    "repair.service"
  },
  ['realestate'] = {
    _config = {
      title = 'Imobiliária',
      gtype = 'job',
      grades = {
        [1] = { name = 'Junior', salary = 100 },
        [2] = { name = 'Vendedor I', salary = 150 },
        [3] = { name = 'Vendedor II', salary = 200 },
        [4] = { name = 'Gerente', salary = 250 },
        [5] = { name = 'Diretor', salary = 300, isboss = true },
      }
    }
  },
  ["taxi"] = {
    _config = {
      title = "Taxi",
      gtype = "job"
    },
    "taxi.service"
  },
}

-- groups are added dynamically using the API or the menu, but you can add group when an user join here
cfg.users = {
  [1] = { -- give superadmin and admin group to the first created user on the database
    "superadmin",
    "admin"
  }
}

return cfg
