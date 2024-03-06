Config = {}

Config.DevMode    = false

Config.PromptKey  = { key = 0x760A9C6F, label = 'Mailbox Office' } -- G

Config.NotificationColors = { -- The following is only when a notification sent while Mailbox is open (It has its own notification system).
    ['error']   = "rgba(255, 0, 0, 0.79)",
    ['success'] = "rgba(0, 255, 0, 0.79)",
    ['info']    = "rgba(102, 178, 255, 0.79)"
}

---------------------------------------------------------------
--[[ General Settings ]]--
---------------------------------------------------------------

Config.Year = 1899

-- NPC Rendering Distance which is deleting the npc when being away from the mailbox location.
Config.NPCRenderingDistance = 30.0

-- What letters should it randomly select for generating a mailbox id?
-- For example, AH-XXXXX, BP-XXXXX.
Config.RandomGeneratedLetters = {
    'GRC',
}

---------------------------------------------------------------
--[[ Discord Webhooking ]]--
---------------------------------------------------------------

Config.DiscordWebhooking = {

    ['SENT_TELEGRAM'] = {
        Enable = false, 
        Url    = "", 
        Color  = 10038562
    },

}

---------------------------------------------------------------
--[[ Mailbox Locations ]]--
---------------------------------------------------------------

Config.Locations = {

    ['Valentine'] = {
        Name = "MailBox Office",

        Coords = {x = -178.83, y = 626.60, z = 114.08},

        City = "Valentine",

        Hours = { Enabled = false, Duration = {am = 7, pm = 21} },

        BlipData = {
            Enabled = true,
            Sprite = 1861010125,
        },

        NPCData = {
            Enabled = true,
            Model = "A_F_M_SDObeseWomen_01",
            Coords = {x = -177.94, y = 628.15, z = 113.08, h = 148.26},
        },

        ActionDistance = 1.5,
    },

    ['Rhodes'] = {
        Name = "MailBox Office",

        Coords = {x = 1226.770, y = -1295.02, z = 76.905},

        City = "Rhodes",

        Hours = { Enabled = false, Duration = {am = 7, pm = 21} },

        BlipData = {
            Enabled = true,
            Sprite = 1861010125,
        },

        NPCData = {
            Enabled = true,
            Model = "A_F_M_SDObeseWomen_01",
            Coords = { x = 1226.770, y = -1295.02, z = 75.905, h = 52.37},
        },

        ActionDistance = 2.5,
    },

    ['STDenis'] = {
        Name = "MailBox Office",

        Coords = {x = 2747.934, y = -1396.33, z = 46.183},

        City = "Saint Denis",

        Hours = { Enabled = false, Duration = {am = 7, pm = 21} },

        BlipData = {
            Enabled = true,
            Sprite = 1861010125,
        },

        NPCData = {
            Enabled = true,
            Model = "A_F_M_SDObeseWomen_01",
            Coords = {x = 2747.934, y = -1396.33, z = 45.183, h = 32.84},
        },

        ActionDistance = 2.5,
    },

    ['Annesburg'] = {
        Name = "MailBox Office",

        Coords = {x = 2933.195, y = 1282.619, z = 44.652},

        City = "Annesburg",

        Hours = { Enabled = false, Duration = {am = 7, pm = 21} },

        BlipData = {
            Enabled = true,
            Sprite = 1861010125,
        },

        NPCData = {
            Enabled = true,
            Model = "A_F_M_SDObeseWomen_01",
            Coords = { x = 2933.195, y = 1282.619, z = 43.652, h = 76.66 },
        },

        ActionDistance = 2.5,
    },

    ['Blackwater'] = {
        Name = "MailBox Office",

        Coords = {x = -875.114, y = -1328.75, z = 43.958},

        City = "Blackwater",

        Hours = { Enabled = false, Duration = {am = 7, pm = 21} },

        BlipData = {
            Enabled = true,
            Sprite = 1861010125,
        },

        NPCData = {
            Enabled = true,
            Model = "A_F_M_SDObeseWomen_01",
            Coords = {x = -875.092, y = -1327.06, z = 42.968, h = 181.11},

        },

        ActionDistance = 2.5,
    },


}
