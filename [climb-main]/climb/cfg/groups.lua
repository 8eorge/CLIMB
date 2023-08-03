
local cfg = {}

-- define each group with a set of permissions
-- _config property:
--- gtype (optional): used to have only one group with the same gtype per player (example: a job gtype to only have one job)
--- onspawn (optional): function(player) (called when the player spawn with the group)
--- onjoin (optional): function(player) (called when the player join the group)
--- onleave (optional): function(player) (called when the player leave the group)
--- (you have direct access to CLIMB and CLIMBclient, the tunnel to client, in the config callbacks)
--  special (optional) -- defines whether user needs special permissions to remove this group.
-- If you have a special group the prefix of the permission is player.manage_groupname An example would be: player.manage_superadmin 
--[[

	"climb.adminmenu", 
    "player.kick",
    "player.ban",
	"player.revive",
	"player.slap",
	"player.spectate", 
	"player.tpto", 
	"player.tpbring",
	"player.removeGroups",
	"player.addGroups",
	"player.manage_superadmin",
	"player.manage_saadmin",
	"player.manage_admin",
	"player.manage_mod",
	"player.manage_support",
	"player.manage_trial", 
	"player.propcleanup", 
	"player.pedcleanup", 
	"player.vehcleanup",
	"player.cleanallcleanup",
	"player.shutdownserver",
	"player.addcar",
	"player.tptowaypoint",
	"admin.spawnveh",
	"admin.removewarning",
	"player.addblacklistedprops" -- Allows live updating of blacklisted props only give to trusted staff.

	These are all the perms for the latest RageUI update, many thanks JamesUK.


]]
cfg.groups = {
  ["Founder"] = {
    _config = {special = true, onspawn = function(player) end},
    "player.group.add",
    "player.group.add.superadmin",
    "player.group.add.admin",  --- this is just a example which can be added to admin/mod group if being made
    "player.group.remove",
    "player.givemoney",
    "player.giveitem", 
	--RageUI perms below
	"climb.adminmenu", 
    "player.kick",
    "player.ban",
	"player.revive",
	"player.slap",
	"player.spectate", 
	"player.tpto", 
	"player.tpbring",
	"player.removeGroups",
	"player.addGroups",
	"player.manage_superadmin",
	"player.manage_saadmin",
	"player.manage_admin",
	"player.manage_mod",
	"player.manage_support",
	"admin.removewarning",
	"player.manage_trial", 
	"player.propcleanup", 
	"player.pedcleanup", 
	"player.vehcleanup",
	"player.cleanallcleanup",
	"player.shutdownserver",
	"player.addcar",
	"player.noclip",
	--RageUI Perms above
	"player.tptowaypoint", 
	"player.addblacklistedprops"
  },
  ["Management"] = {
	_config = {special = true},
		--RageUI perms
	"player.group.add",
	"admin.removewarning",
	"climb.adminmenu", 
    "player.kick",
    "player.ban",
	"player.revive",
	"player.slap",
	"player.spectate", 
	"player.tpto", 
	"player.tpbring",
	"player.removeGroups",
	"player.addGroups",
	"player.manage_admin",
	"player.manage_mod",
	"player.manage_support",
	"player.manage_trial",
	"player.propcleanup", 
	"player.pedcleanup", 
	"player.vehcleanup",
	"player.cleanallcleanup",
	"player.unban",
    "player.noclip",
	"admin.tickets",
	"player.coords",
	"player.tptowaypoint",
	"admin.menu",
		--RageUI Perms 
  },
  ["Staff"] = {
	_config = {special = true},
	"player.manage_support",
	"player.manage_trial",
	"climb.adminmenu", 
	"player.group.add",
	"player.kick",
	"player.ban",
	"player.revive",
	"player.slap",
	"player.spectate", 
	"player.tpto", 
	"player.tpbring",
	"player.removeGroups",
	"player.addGroups",
	"player.unban",
    "player.noclip",
	"admin.tickets",
	"admin.menu",
	"player.coords",
	"player.tptowaypoint",
		--RageUI Perms 
  },
  -- the group user is auto added to all logged players
  ["user"] = {
    "player.phone",
    "player.calladmin",
	"player.fix_haircut",
	"player.check",
	--"mugger.mug",
    "police.askid",
    "police.store_weapons",
	"player.skip_coma",
	"player.store_money",
	"player.check",
	"player.loot",
	"player.player_menu",
	"player.userlist",
    "police.seizable",	-- can be seized
	"user.paycheck"
  },
  ["Unemployed"] = {
    _config = { gtype = "job",
	onspawn = function(player) CLIMBclient.notify(player,{"You are Unemployed, go to Department of Jobs."}) end
	},
	"citizen.paycheck"
  },
}

-- groups are added dynamically using the API or the menu, but you can add group when an user join here
cfg.users = {
  [1] = {
    "Founder",
  }
}
return cfg
