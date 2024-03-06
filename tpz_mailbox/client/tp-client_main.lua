ClientData = { IsBusy = false, Job = nil, CurrentLocation = nil, UniqueId = nil, Username = nil, Loaded = false }

-----------------------------------------------------------
--[[ Base Events & Threads ]]--
-----------------------------------------------------------

-- Requests when devmode set to false and character is selected.
AddEventHandler("tpz_core:isPlayerReady", function()
    TriggerServerEvent('tpz_mailbox:requestMailboxInformation')
end)

-- Requests when devmode set to true.
if Config.DevMode then
    Citizen.CreateThread(function ()

        Wait(2000)
        TriggerServerEvent('tpz_mailbox:requestMailboxInformation')
    end)
end

-- Updates the player job.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    ClientData.Job = data.job
end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_mailbox:getMailboxInformation")
AddEventHandler("tpz_mailbox:getMailboxInformation", function(id)

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_core:getPlayerData", function(data)

        ClientData.Job       = data.job
        ClientData.UniqueId  = id

        ClientData.Username  = data.firstname .. ' ' .. data.lastname

        ClientData.Loaded    = true

    end)

end)

---------------------------------------------------------------
-- Threads
---------------------------------------------------------------

Citizen.CreateThread(function()
    RegisterActionPrompt()

    while true do
        Citizen.Wait(0)

        local sleep  = true

        local player = PlayerPedId()

        local coords = GetEntityCoords(PlayerPedId())
        local hour   = GetClockHours()
        local isDead = IsEntityDead(player)

        if not isDead and not ClientData.IsBusy and ClientData.Loaded then

            for index, officeConfig in pairs(Config.Locations) do

                local coordsDist  = vector3(coords.x, coords.y, coords.z)
                local coordsStore = vector3(officeConfig.Coords.x, officeConfig.Coords.y, officeConfig.Coords.z)
                local distance    = #(coordsDist - coordsStore)

                local invalidHour = (hour >= officeConfig.Hours.Duration.pm or hour < officeConfig.Hours.Duration.am)

                if ( distance > Config.NPCRenderingDistance ) or (officeConfig.Hours.Enabled and invalidHour) then
                    
                    if Config.Locations[index].NPC then
                        RemoveEntityProperly(Config.Locations[index].NPC, joaat(Config.Locations[index].NPCData.Model))
                        Config.Locations[index].NPC = nil
                    end

                end

                local isMailboxAvailable = true

                if officeConfig.Hours.Enabled and invalidHour then
                    isMailboxAvailable = false
                end

                if isMailboxAvailable then

                    if distance <= Config.NPCRenderingDistance and not Config.Locations[index].NPC and officeConfig.NPCData.Enabled  then
                        SpawnNPC(index)
                    end

                    if distance <= officeConfig.ActionDistance then
                        sleep = false

                        local label = CreateVarString(10, 'LITERAL_STRING', Config.PromptKey.label)
        
                        PromptSetActiveGroupThisFrame(Prompts, label)
    
                        if PromptHasHoldModeCompleted(PromptsList) then

                            ClientData.CurrentLocation = index

                            OpenMailBoxOffice()

                            Wait(1000)
                        end
                    end

                end
            end
        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)
