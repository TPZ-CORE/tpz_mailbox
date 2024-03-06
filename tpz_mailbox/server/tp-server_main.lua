

local TPZ    = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

GetSourceFromParameters = function(telegramId)

  local returnedValue = 0
  local finished      = false

  exports["ghmattimysql"]:execute("SELECT * FROM `mailbox_registrations` WHERE `uniqueId` = @uniqueId", { ["@uniqueId"] = telegramId }, function(result)
    
    if result[1] == nil then
      return 0
    end

    local charidentifier = result[1].charidentifier
    local identifier     = result[1].identifier

    local playerList = GetPlayers()

		for index, player in pairs(playerList) do

      player = tonumber(player)

      local xPlayer = TPZ.GetPlayer(player)

      if xPlayer.loaded() then

        local _charidentifier = xPlayer.getCharacterIdentifier()
        local _identifier     = xPlayer.getIdentifier()

        if tonumber(charidentifier) == _charidentifier and identifier == _identifier then
          returnedValue = player
          finished = true
        end
      
      end

      if next(playerList, index) == nil then
        finished = true
      end

    end

  end)

  while not finished do
    Wait(100)
  end

  return returnedValue

end

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_mailbox:requestMailboxInformation')
AddEventHandler('tpz_mailbox:requestMailboxInformation', function()
  local _source = source
  local xPlayer = TPZ.GetPlayer(_source)

  if (xPlayer == nil) or (xPlayer and not xPlayer.loaded()) then
    return
  end

	local charidentifier      = xPlayer.getCharacterIdentifier()
  local identifier          = xPlayer.getIdentifier()
  local firstname, lastname = xPlayer.getFirstName(), xPlayer.getLastName()

  -- We check if the connected players has uniqueId available before sending the Mailbox data
  -- If the player does not have uniqueId, we generate it.
  exports["ghmattimysql"]:execute("SELECT * FROM `mailbox_registrations` WHERE `charidentifier` = @charidentifier", { 
    ["@charidentifier"] = charidentifier }, function(result)

      local uniqueId = nil

      if result[1] == nil then

        local randomLetters = Config.RandomGeneratedLetters[ math.random( #Config.RandomGeneratedLetters )]
        local randomNumbers = charidentifier .. math.random(1, 9) .. math.random(1, 9) .. math.random(1, 9) .. math.random(1, 9)
        
        uniqueId = randomLetters .. "-" .. randomNumbers

        local Parameters = { 
          ['identifier']     = identifier,
          ['charidentifier'] = charidentifier,
          ['firstname']      = firstname,
          ['lastname']       = lastname,
          ['uniqueId']       = uniqueId,
        }
    
        exports.ghmattimysql:execute("INSERT INTO `mailbox_registrations` ( `identifier`, `charidentifier`, `firstname`, `lastname`, `uniqueId`) VALUES ( @identifier, @charidentifier, @firstname, @lastname, @uniqueId)", Parameters)

      else

        uniqueId = result[1].uniqueId
      end

    -- Sending Telegrams Data & User Mailbox ID (Generated / Not).
    TriggerClientEvent("tpz_mailbox:getMailboxInformation", _source, uniqueId)

  end)

end)

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_mailbox:sendTelegram')
AddEventHandler('tpz_mailbox:sendTelegram', function(personalTelegramId, selectedTelegramId, title, content, location) 
  local _source             = source
  local xPlayer             = TPZ.GetPlayer(_source)

  local charidentifier      = xPlayer.getCharacterIdentifier()
  local identifier          = xPlayer.getIdentifier()
  local firstname, lastname = xPlayer.getFirstName(), xPlayer.getLastName()
  
  local timeStamp = os.date('%d').. '/' ..os.date('%m').. '/' .. Config.Year .. " " .. os.date('%H') .. ":" .. os.date('%M')

  local Parameters = { 

    ['sender_username']    = firstname .. " " .. lastname, 
    ['sender_uniqueId']    = personalTelegramId,

    ['receiver_uniqueId']  = selectedTelegramId,

    ['title']              = title,
    ['message']            = content,
    ['city']               = location, 
    ['timestamp']          = timeStamp,
  }

  exports.ghmattimysql:execute("INSERT INTO `mailbox` (`sender_username`, `sender_uniqueId`, `receiver_uniqueId`, `title`, `message`, `city`, `timestamp`) VALUES ( @sender_username, @sender_uniqueId, @receiver_uniqueId, @title, @message, @city, @timestamp)", Parameters)
  
  TriggerClientEvent("tpz_mailbox:sendNotification", _source, Locales['TELEGRAM_HAS_BEEN_SENT'], "success")


  local targetSource = GetSourceFromParameters(selectedTelegramId)

  if targetSource and targetSource ~= 0 then
    
    local notifyData = Locales['RECEIVED_MAIL']
    TriggerClientEvent("tpz_notify:sendNotification", targetSource, notifyData.title, notifyData.message, notifyData.icon, "info", notifyData.duration)

  end

  local webhookData = Config.DiscordWebhooking['SENT_TELEGRAM']
    
  if webhookData.Enable then
    local webhookTitle   = "📬` " .. firstname .. " " .. lastname .. " (Steam Identifier: " .. identifier .. " | Char Id: " .. charIdentifier .. ") sent a telegram.`"
      
    local message = "**Username: **`" .. firstname .. " " .. lastname .. "`**\nSteam Identifier: **`" .. identifier .. "`**\nChar Identifier: **`" .. charidentifier .. "`**\nTitle: **`" .. title .. "`**\nContent: **`" .. content .. ". `"
    TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, webhookTitle, message, webhookData.Color)
  end

  TriggerClientEvent("tpz_mailbox:refresh", _source)

end)

RegisterServerEvent("tpz_mailbox:setTelegramStateAsViewed")
AddEventHandler("tpz_mailbox:setTelegramStateAsViewed", function(telegramId)
  exports.ghmattimysql:execute("UPDATE `mailbox` SET `viewed` = @viewed WHERE id = @id", { ['id'] = tonumber(telegramId), ['viewed'] = 1})
end)

RegisterServerEvent('tpz_mailbox:deleteSelectedTelegram')
AddEventHandler('tpz_mailbox:deleteSelectedTelegram', function(telegramId)
  local _source = source

  exports.ghmattimysql:execute("DELETE FROM `mailbox` WHERE `id` = @id", {["@id"] = telegramId}) 

  TriggerClientEvent("tpz_mailbox:sendNotification", _source, Locales['TELEGRAM_HAS_BEEN_DELETED'], "info")
  TriggerClientEvent("tpz_mailbox:refresh", _source)
end)