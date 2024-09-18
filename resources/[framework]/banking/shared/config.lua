Config = {}

Config.IBANPrefix = "SW"             -- the prefix of the IBAN
Config.IBANNumbers = 6               -- How many characters the IBAN has by default
Config.CustomIBANMaxChars = 10       -- How many characters the IBAN can have when changing it to a custom one (on Settings tab)
Config.CustomIBANAllowLetters = true -- If the custom IBAN can have letters or only numbers (on Settings tab)
Config.IBANChangeCost = 5000         -- How much it costs to change the IBAN to a custom one (on Settings tab)
Config.PINChangeCost = 1000          -- How much it costs to change the PIN (on Settings tab)
Config.AnimTime = 2 * 1000           -- 2 * 1000 = 2 seconds (ATM animation)
Config.Societies = {                 -- Which societies have bank accounts
	["police"] = 4,
	["ambulance"] = 3,
}

Config.ShowBankBlips = true -- true = show bank blips on the map | false = don't show blips

Config.BankLocations = {    -- to get blips and colors check this: https://wiki.gtanet.work/index.php?title=Blips
	{ blip = 108, blipColor = 2, blipScale = 0.9, x = 150.266,   y = -1040.203, z = 29.374, blipText = "Bank", BankDistance = 3 },
	{ blip = 108, blipColor = 2, blipScale = 0.9, x = -1212.980, y = -330.841,  z = 37.787, blipText = "Bank", BankDistance = 3 },
	{ blip = 108, blipColor = 2, blipScale = 0.9, x = -2962.582, y = 482.627,   z = 15.703, blipText = "Bank", BankDistance = 3 },
	{ blip = 108, blipColor = 2, blipScale = 0.9, x = -112.202,  y = 6469.295,  z = 31.626, blipText = "Bank", BankDistance = 3 },
	{ blip = 108, blipColor = 2, blipScale = 0.9, x = 314.187,   y = -278.621,  z = 54.170, blipText = "Bank", BankDistance = 3 },
	{ blip = 108, blipColor = 2, blipScale = 0.9, x = -351.534,  y = -49.529,   z = 49.042, blipText = "Bank", BankDistance = 3 },
	{ blip = 108, blipColor = 2, blipScale = 0.9, x = 1175.064,  y = 2706.643,  z = 38.094, blipText = "Bank", BankDistance = 3 },
}

Config.BankZones = {
	{
		coords = vec3(149.61, -1040.2, 29.75),
		size = vec3(5.5, 2.25, 2.5),
		rotation = 161.0,
	},
	{
		coords = vec3(-1212.95, -330.85, 38.05),
		size = vec3(6, 1, 2.75),
		rotation = 205.0,
	},
	{
		coords = vec3(-2962.07, 482.67, 16.0),
		size = vec3(5.25, 1.25, 2.75),
		rotation = 268.0,
	},
	{
		coords = vec3(-113.35, 6470.35, 32.0),
		size = vec3(4.0, 0.5, 2.5),
		rotation = 313.0,
	},
	{
		coords = vec3(313.84, -279.19, 54.0),
		size = vec3(5.0, 1.0, 3.5),
		rotation = 160.0,
	},
	{
		coords = vec3(-351.41, -49.99, 49.5),
		size = vec3(5.0, 1.0, 3.0),
		rotation = 162.0,
	},
	{
		coords = vec3(1175.69, 2706.97, 38.0),
		size = vec3(5.0, 1, 3),
		rotation = 0.0,
	}
}

Config.ATMDistance = 1.5 -- How close you need to be in order to access the ATM

Config.ATM = { -870868698, -1126237515, -1364697528, 506770882 }
