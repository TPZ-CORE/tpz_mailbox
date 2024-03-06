local Cooldown = false

local Pages = {
    [1]  = 1, [2]  = 1, [3]  = 1, [4]  = 1, [5]  = 1, [6]  = 1, [7]  = 1, [8]  = 1, [9]  = 1, [10]  = 1,
    [11] = 2, [12] = 2, [13] = 2, [14] = 2, [15] = 2, [16] = 2, [17] = 2, [18] = 2, [19] = 2, [20]  = 2,
    [21] = 3, [22] = 3, [23] = 3, [24] = 3, [25] = 3, [26] = 3, [27] = 3, [28] = 3, [29] = 3, [30]  = 3,
    [31] = 4, [32] = 4, [33] = 4, [34] = 4, [35] = 4, [36] = 4, [37] = 4, [38] = 4, [39] = 4, [40]  = 4,
    [41] = 5, [42] = 5, [43] = 5, [44] = 5, [45] = 5, [46] = 5, [47] = 5, [48] = 5, [49] = 5, [50]  = 5,
    [51] = 6, [52] = 6, [53] = 6, [54] = 6, [55] = 6, [56] = 6, [57] = 6, [58] = 6, [59] = 6, [60]  = 6,
    [61] = 7, [62] = 7, [63] = 7, [64] = 7, [65] = 7, [66] = 7, [67] = 7, [68] = 7, [69] = 7, [70]  = 7,
    [71] = 8, [72] = 8, [73] = 8, [74] = 8, [75] = 8, [76] = 8, [77] = 8, [78] = 8, [79] = 8, [80]  = 8,
}

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local ToggleUI = function(display)
	SetNuiFocus(display,display)

	ClientData.IsBusy = display

    if not display then
        ClientData.IsBusy = false
        TaskStandStill(PlayerPedId(), 1)
    end

    SendNUIMessage({ type = "enable", enable = display})
end

local CloseUI = function()
    if ClientData.IsBusy then SendNUIMessage({action = 'close'}) end
end

local SendNotification = function(message, type)

    if ClientData.IsBusy then

		SendNUIMessage({ 
            action = 'sendNotification',
            notification_data = { message = message, type = type, color = Config.NotificationColors[type] },
        })

	end

end

local RefreshTelegrams = function (selectedPage)

    SendNUIMessage({ action = 'resetTelegrams' } )

    local count = 0

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_mailbox:getTelegrams", function(result)

        if GetTableLength(result) > 0 then

            for k, res in pairs (result) do

                if res.receiver_uniqueId == ClientData.UniqueId then

                    count = count + 1
                
                    if Pages[count] == selectedPage then
                        SendNUIMessage({ action = 'loadTelegrams', telegram = res } )
                    end

                end

            end

            local totalPages = Pages[count]

            SendNUIMessage({ action = 'setTotalPages', total = totalPages, selected = selectedPage } )

        end

    end)

end
-----------------------------------------------------------
--[[ Public Functions ]]--
-----------------------------------------------------------

OpenMailBoxOffice = function()

    RefreshTelegrams(1)
    
    local location  = Config.Locations[ClientData.CurrentLocation].City

    SendNUIMessage({ 
        action    = 'loadInformation',
        location  = location,
        uniqueId  = ClientData.UniqueId,
        username  = ClientData.Username,
    })

    Wait(250)
    ToggleUI(true)

end

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_mailbox:refresh")
AddEventHandler("tpz_mailbox:refresh", function()

    if not ClientData.IsBusy then
        return
    end

    RefreshTelegrams(1)

end)

RegisterNetEvent('tpz_mailbox:sendNotification')
AddEventHandler('tpz_mailbox:sendNotification', function(message, type)
    SendNotification(message, type)
end)

-----------------------------------------------------------
--[[ NUI Callbacks  ]]--
-----------------------------------------------------------

RegisterNUICallback('refresh', function(data)
    RefreshTelegrams(1)
end)

RegisterNUICallback('close', function()
	ToggleUI(false)
end)

RegisterNUICallback('selectPage', function(data)

    if Cooldown then
        return
    end

    Cooldown = true

    RefreshTelegrams(tonumber(data.value))

    Wait(1000)
    Cooldown = false
end)

-- @param telegramId : returns the selected telegram id.
-- @param title : returns the telegram title.
-- @param content : returns the telegram message content.
RegisterNUICallback('sendTelegram', function(data)
    
    local telegramId = data.telegramId
    local title      = data.title
    local content    = data.content

    if Cooldown then
        return
    end

    Cooldown = true

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_mailbox:doesTelegramIdExists", function(cb)

        if not cb then
            Cooldown = false
            return
        end

        SendNUIMessage({ action = 'onSuccessfullTelegramSent' } )

        local location = Config.Locations[ClientData.CurrentLocation].City

        TriggerServerEvent("tpz_mailbox:sendTelegram", ClientData.UniqueId, telegramId, title, content, location)

        Wait(2000)
        Cooldown = false

    end, { uniqueId = telegramId })

end)

-- The following NUI Callback is changing the state of a telegram (Viewed / Not).
RegisterNUICallback('setMailViewedById', function (data)
    TriggerServerEvent("tpz_mailbox:setTelegramStateAsViewed", data.telegramId)
end)

RegisterNUICallback('delete', function(data)

    if Cooldown then
        return
    end

    Cooldown = true

    TriggerServerEvent('tpz_mailbox:deleteSelectedTelegram', data.telegramId)

    Wait(2000)
    Cooldown = false
end)