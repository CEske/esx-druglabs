-- BACKEND
local ESX = nil
local Labs = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

-----

opretShell = function(object, gang, pin)
    local spillerpos = GetEntityCoords(PlayerPedId())
    local shell = CreateObject(ConfigClient.Shells[object].obj, spillerpos.x, spillerpos.y, spillerpos.z - 50.0, false, false)
    FreezeEntityPosition(shell, true)
    SetEntityHeading(shell, 0.0)
    local info = {}
    table.insert(info, {
        name = gang,
        pin = pin,
        shellpos = GetEntityCoords(shell),
        entrypos = spillerpos,
        door = (GetEntityCoords(shell)+ConfigClient.Shells[object].door),
        pak = (GetEntityCoords(shell)+ConfigClient.Shells[object].pak),
        process = (GetEntityCoords(shell)+ConfigClient.Shells[object].process),
    })
    TriggerServerEvent('eske_druglab:opretLab', object, json.encode(info), gang, pin)
    DeleteEntity(shell)
end

RegisterCommand("druglab:opret", function(src, args)
    ESX.TriggerServerCallback('eske_druglab:hasPerm', function(result)
        if result then
            if args[1] and ConfigClient.Shells[args[1]] and args[2] and args[3] then
                ESX.TriggerServerCallback('eske_druglab:doesGangHave', function(gangStatus)
                    if not gangStatus then
                        opretShell(args[1], args[2], args[3])
                    else
                        print('Gang har allerede')
                    end
                end, args[2])
            else
                print("Der skete en fejl")
            end
        else
            print('Ikke nok perms')
        end
    end, src)
end)

TriggerEvent('chat:addSuggestion', '/druglab:opret', 'Opret et nyt druglab', {
    { name="labNavn", help="Hvilket lab er det?" },
    { name="gang", help="Bandens job" },
    { name="pin", help="Kode til lab" }
})

---------
local spawnedLabs = nil
local insideLab = false

function spawnLab(obj, x, y, z)
    local ped = GetPlayerPed(-1)
    RequestModel(obj)
    while not HasModelLoaded(obj) do
        print('[ESKE DRUGLABS] Loader druglab...')
        Wait(0)
    end

    local lab = CreateObject(obj, x, y, z, false, false, false)
    PlaceObjectOnGroundProperly(lab)
    FreezeEntityPosition(lab, true)
    SetEntityHeading(lab, 0.0)
    SetEntityCollision(lab, true, true)
    SetEntityAsMissionEntity(lab, true, true)
    SetModelAsNoLongerNeeded(lab)
    spawnedLabs = lab
end

function despawnLab()
    if DoesEntityExist(spawnedLabs) then
        DeleteEntity(spawnedLabs)
    end
end

RegisterCommand('enterlab', function(src, args)
    ESX.TriggerServerCallback('eske_druglab:getLabs', function(result)
        Labs = result
        if args[1] and tonumber(args[1]) then
            for k,v in pairs(Labs) do
                local spillerpos = GetEntityCoords(PlayerPedId(-1))
                local afstand = GetDistanceBetweenCoords(spillerpos.x ,spillerpos.y, spillerpos.z, v.x, v.y, v.z, true)
                if afstand < 1.6 then
                    ESX.TriggerServerCallback('eske_druglab:canEnterLab', function(result1)
                        if result1 then
                            local gammelpos = GetEntityCoords(PlayerPedId(-1))
                            spawnLab(ConfigClient.Shells[v.type].obj, v.entryx, v.entryy, v.entryz-50.0)
                            insideLab = true
                            SetEntityCoords(PlayerPedId(-1), v.doorx, v.doory, v.doorz-26.0)


                            while insideLab do
                                Citizen.Wait(1)
                                spillerpos = GetEntityCoords(PlayerPedId(-1))
                                if #(vector3(spillerpos.x, spillerpos.y, spillerpos.z) - vector3(v.doorx, v.doory, v.doorz - 25.0)) < 3.1 then
                                    if IsControlPressed(0, 38) then
                                        SetEntityCoords(PlayerPedId(-1), gammelpos)
                                        despawnLab()
                                        insideLab = false
                                    end
                                end

                                if #(vector3(spillerpos.x, spillerpos.y, spillerpos.z) - vector3(v.pakx, v.paky, v.pakz - 25.0)) < 1.5 then
                                    DrawText3D(v.pakx, v.paky, v.pakz - 26.0, '[E] Pak')
                                    if IsControlJustPressed(0, 38) then
                                        ESX.TriggerServerCallback('eske_druglab:hasItem', function(result)
                                            if result then
                                                ESX.TriggerServerCallback('eske_druglab:packDrug', function(result1)
                                                    if result1 then
                                                        exports['eske_druglabs']:pack()
                                                    else
                                                        ESX.ShowNotification('Du har ikke plads til dette.')
                                                    end
                                                end, v.type)
                                            else
                                                ESX.ShowNotification('Du har ikke de nødvendige ressourcer.')
                                            end
                                        end, v.type, 'pak')
                                    end
                                end

                                if #(vector3(spillerpos.x, spillerpos.y, spillerpos.z) - vector3(v.processx, v.processy, v.processz - 25.0)) < 1.5 then
                                    DrawText3D(v.processx, v.processy, v.processz - 26.0, '[E] Omdan')
                                    if IsControlJustPressed(0, 38) then
                                        ESX.TriggerServerCallback('eske_druglab:hasItem', function(result)
                                            if result then
                                                ESX.TriggerServerCallback('eske_druglab:processDrug', function(result1)
                                                    if result1 then
                                                        exports['eske_druglabs']:omdan()
                                                    else
                                                        ESX.ShowNotification('Du har ikke plads til dette.')
                                                    end
                                                end, v.type)
                                            else
                                                ESX.ShowNotification('Du har ikke de nødvendige ressourcer.')
                                            end
                                        end, v.type, 'process')
                                    end
                                end

                                if v.farmx then
                                    if #(vector3(spillerpos.x, spillerpos.y, spillerpos.z) - vector3(v.farmx, v.farmy, v.farmz - 25.0)) < 1.5 then
                                        DrawText3D(v.farmx, v.farmy, v.farmz - 26.0, '[E] Farm')
                                        if IsControlJustPressed(0, 38) then
                                            ESX.TriggerServerCallback('eske_druglab:farmDrug', function(result)
                                                if result then
                                                    ESX.TriggerServerCallback('eske_druglab:processDrug', function(result1)
                                                        if result1 then
                                                            exports['eske_druglabs']:farm()
                                                        else
                                                            ESX.ShowNotification('Du har ikke plads til dette.')
                                                        end
                                                    end, v.type)
                                                else
                                                    ESX.ShowNotification('Du har ikke nok plads.')
                                                end
                                            end, v.type)
                                        end
                                    end
                                end
                            end
                        else
                            if ConfigClient.Notifikationer.Forkertkode then
                                ESX.ShowNotification('Du har ikke adgang til dette laboratorium.')
                            end
                        end
                    end, args[1], v.id)
                end
            end
        else
            ESX.ShowNotification('Koden skal være et tal.')
        end
    end)
end)

RegisterCommand('policeraid', function(src, args)
    ESX.TriggerServerCallback('eske_druglab:getLabs', function(result)
        Labs = result
        for k,v in pairs(Labs) do
            local spillerpos = GetEntityCoords(PlayerPedId(-1))
            local afstand = GetDistanceBetweenCoords(spillerpos.x ,spillerpos.y, spillerpos.z, v.x, v.y, v.z, true)
            if afstand < 1.6 then
                ESX.TriggerServerCallback('eske_druglab:canPoliceRaid', function(result1)
                    if result1 then
                        local gammelpos = GetEntityCoords(PlayerPedId(-1))
                        spawnLab(ConfigClient.Shells[v.type].obj, v.entryx, v.entryy, v.entryz-50.0)
                        insideLab = true
                        SetEntityCoords(PlayerPedId(-1), v.doorx, v.doory, v.doorz-25.0)

                        while insideLab do
                            Citizen.Wait(1)
                            spillerpos = GetEntityCoords(PlayerPedId(-1))
                            if #(vector3(spillerpos.x, spillerpos.y, spillerpos.z) - vector3(v.doorx, v.doory, v.doorz - 25.0)) < 1.5 then
                                if IsControlPressed(0, 38) then
                                    SetEntityCoords(PlayerPedId(-1), gammelpos)
                                    despawnLab()
                                    insideLab = false
                                end
                            end
                        end
                    else
                        if ConfigClient.Notifikationer.IkkePoliti then
                            ESX.ShowNotification('Dette har du ikke adgang til.')
                        end
                    end
                end)
            end
        end
    end)
end)

RegisterCommand('raidlab', function(src, args)
    ESX.TriggerServerCallback('eske_druglab:getLabs', function(result)
        Labs = result
        for k,v in pairs(Labs) do
            local spillerpos = GetEntityCoords(PlayerPedId(-1))
            local afstand = GetDistanceBetweenCoords(spillerpos.x ,spillerpos.y, spillerpos.z, v.x, v.y, v.z, true)
            if afstand < 1.6 then
                ESX.TriggerServerCallback('eske_druglab:canRaidLab', function(result1)
                    if result1 then
                        local gammelpos = GetEntityCoords(PlayerPedId(-1))
                        spawnLab(ConfigClient.Shells[v.type].obj, v.entryx, v.entryy, v.entryz-50.0)
                        insideLab = true
                        SetEntityCoords(PlayerPedId(-1), v.doorx, v.doory, v.doorz-25.0)

                        while insideLab do
                            Citizen.Wait(1)
                            spillerpos = GetEntityCoords(PlayerPedId(-1))
                            if #(vector3(spillerpos.x, spillerpos.y, spillerpos.z) - vector3(v.doorx, v.doory, v.doorz - 25.0)) < 1.5 then
                                if IsControlPressed(0, 38) then
                                    SetEntityCoords(PlayerPedId(-1), gammelpos)
                                    despawnLab()
                                    insideLab = false
                                end
                            end
                        end
                    else
                        if ConfigClient.Notifikationer.IkkeBande then
                            ESX.ShowNotification('Dette har du ikke adgang til.')
                        end
                    end
                end)
            end
        end
    end)
end)

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end