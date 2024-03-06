

local TPZ = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

-- @GetTableLength returns the length of a table.
local function GetTableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:rServerAPI().addNewCallBack("tpz_mailbox:getTelegrams", function(source, cb)
	local _source = source

	local xPlayer        = TPZ.GetPlayer(_source)
	local identifier     = xPlayer.getIdentifier()
	local charidentifier = xPlayer.getCharacterIdentifier()

	exports.ghmattimysql:execute("SELECT * FROM mailbox ORDER BY id DESC", {}, function(result)

		if GetTableLength(result) <= 0 then
			return cb( {} )
		end

		exports["ghmattimysql"]:execute("SELECT * FROM `mailbox_registrations` WHERE `charidentifier` = @charidentifier AND `identifier` = @identifier", { 
			["@charidentifier"] = charidentifier, ['@identifier'] = identifier }, function(userData)

				if userData[1] == nil then
					return cb ( {} )
				end

				return cb(result)

		end)

	end)

end)

exports.tpz_core:rServerAPI().addNewCallBack("tpz_mailbox:doesTelegramIdExists", function(source, cb, data)
	local _source = source

	exports["ghmattimysql"]:execute("SELECT * FROM `mailbox_registrations` WHERE `uniqueId` = @uniqueId", { ["@uniqueId"] = data.uniqueId }, function(result)

		if result[1] == nil then
			TriggerClientEvent("tpz_mailbox:sendNotification", _source, Locales['TELEGRAM_ID_DOES_NOT_EXIST'], "error")
			return cb(false)
		end

		return cb(true)

	end)

end)