local spawnedDog = nil
local following = false
local attacking = false
local attacked_player = 0
local inVehicle = false
local carrying = false

local tracking = false
local tracking_player = 0

local TrackSettings = {
    outstandingRequest = false,
    requestingPlayer = -1
}

local dogs = {
    {
        name = 'German Shepherd (GP)',
        spawn = 'a_c_shepherd'
    },
    {
        name = 'Husky (Searching)',
        spawn = 'a_c_husky'
    }
}

local animations = {
    sit = {
        dict = "creatures@rottweiler@amb@world_dog_sitting@idle_a",
        anim = "idle_b"
    },
    laydown = {
        dict = "creatures@rottweiler@amb@sleep_in_kennel@",
        anim = "sleep_in_kennel"
    },
    searchhit = {
        dict = "creatures@rottweiler@indication@",
        anim = "indicate_high"
    },
    bark = {
        dict = 'creatures@retriever@amb@world_dog_barking@base',
        anim = 'base'
    }
}

_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Dog Script", "Main Menu")
_menuPool:Add(mainMenu)

Citizen.CreateThread(function()
    local createMenu = _menuPool:AddSubMenu(mainMenu, 'Dog Options')

    local spawnShepherd = NativeUI.CreateItem('Spawn Shepherd', 'Spawns a German Shepherd')
    createMenu:AddItem(spawnShepherd)

    local spawnHusky = NativeUI.CreateItem('Spawn Husky', 'Spawns a Husky - Search Dog')
    createMenu:AddItem(spawnHusky)

    local spawnRetriever = NativeUI.CreateItem('Spawn Retriever', 'Spawns a Retriever')
    createMenu:AddItem(spawnRetriever)

    local deleteDog = NativeUI.CreateItem('Delete Dog', 'Deletes the Current Spawned Dog')
    createMenu:AddItem(deleteDog)

    createMenu.OnItemSelect = function(sender, item, index)
        if item == spawnShepherd then
            TriggerEvent('Dwoof:spawnDog', 'a_c_shepherd')
        end
        
        if item == spawnHusky then
            TriggerEvent('Dwoof:spawnDog', 'a_c_husky')
        end

        if item == spawnRetriever then
            TriggerEvent('Dwoof:spawnDog', 'a_c_retriever')
        end

        if item == deleteDog then
            TriggerEvent('Dwoof:deleteDog')
        end
    end

    local actionMenu = _menuPool:AddSubMenu(mainMenu, 'Actions')
    
    local followDog = NativeUI.CreateItem('Follow', 'Tells your spawned dog to follow you.')
    actionMenu:AddItem(followDog)
    
    local sitDog = NativeUI.CreateItem('Sit', 'Tells your spawned dog to sit.')
    actionMenu:AddItem(sitDog)
    
    local layDog = NativeUI.CreateItem('Lay Down', 'Tells your spawned dog to lay down.')
    actionMenu:AddItem(layDog)
    
    local barkDog = NativeUI.CreateItem('Bark', 'Tells your spawned dog to wooof.')
    actionMenu:AddItem(barkDog)
    
    local enterVehicle = NativeUI.CreateItem('Enter Vehicle', 'Enters the vehicle you are in/looking at.')
    actionMenu:AddItem(enterVehicle)
    
    local teleportDog = NativeUI.CreateItem('Teleport Dog', 'Teleports dog to the player.')
    actionMenu:AddItem(teleportDog)
    
    local carryDog = NativeUI.CreateItem('Carry Dog', 'Carry and Drop the Dog')
    actionMenu:AddItem(carryDog)
    
    local standDog = NativeUI.CreateItem('Stand Up', 'Tells the dog to stand up.')
    actionMenu:AddItem(standDog)
    
    local vehicleSearch = NativeUI.CreateItem('Search Vehicle', 'Tells the dog to search the vehicle.')
    actionMenu:AddItem(vehicleSearch)

    actionMenu.OnItemSelect = function(sender, item, index)
        if item == followDog then
            TriggerEvent('Dwoof:followDog')
        end

        if item == sitDog then
            TriggerEvent('Dwoof:sitDog')
        end

        if item == enterVehicle then
            TriggerEvent('Dwoof:enterVehicle')
        end

        if item == teleportDog then
            TriggerEvent('Dwoof:teleportDog')
        end

        if item == carryDog then
            TriggerEvent('Dwoof:carryDog')
        end

        if item == layDog then
            TriggerEvent('Dwoof:layDog')
        end

        if item == barkDog then
            TriggerEvent('Dwoof:barkDog')
        end

        if item == standDog then
            TriggerEvent('Dwoof:standDog')
        end

        if item == vehicleSearch then
            TriggerEvent('Dwoof:searchVehicle')
        end
    end

    _menuPool:MouseControlsEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
    _menuPool:RefreshIndex()
end)

RegisterCommand("dog", function(source, args, raw)
    if (_menuPool:IsAnyMenuOpen()) then
        _menuPool:CloseAllMenus()
    else
        mainMenu:Visible(true)

        while _menuPool:IsAnyMenuOpen() do
            _menuPool:ProcessMenus()
            Citizen.Wait(0)
        end
    end
end)

RegisterKeyMapping("dog", "Dog Menu", "KEYBOARD", "F2")

RegisterCommand("dogAttack", function(source, args, raw)
    if IsPlayerFreeAiming(PlayerId()) then
        local bool, target = GetEntityPlayerIsFreeAimingAt(PlayerId())

        if bool then
            ClearPedTasks(spawnedDog)

            if IsEntityAPed(target) then
                if inVehicle then
                    local vehicle = GetEntityAttachedTo(spawnedDog)
                    local vehPos = GetEntityCoords(vehicle)
                    local forwardX = GetEntityForwardVector(vehicle).x * 3.7
                    local forwardY = GetEntityForwardVector(vehicle).y * 3.7
                    local _, groundZ = GetGroundZFor_3dCoord(vehPos.x, vehPos.y, vehPos.z, 0)

                    ClearPedTasks(spawnedDog)
                    DetachEntity(spawnedDog)
                    
                    SetEntityCoords(spawnedDog, vehPos.x - forwardX, vehPos.y - forwardY, groundZ)

                    inVehicle = false
                end

                TaskCombatPed(spawnedDog, target, 0, 16)

                attacking = true
                following = false
                tracking = false

                while not IsPedDeadOrDying(target, true) do
                    SetPedMoveRateOverride(spawnedDog, 1.75)
                    Citizen.Wait(0)
                end
            end
        end
    end
end, false)

RegisterKeyMapping("dogAttack", "Dog Attack", "KEYBOARD", "R")

RegisterCommand("dogFollow", function(source, args, raw)
    if spawnedDog ~= nil then
        TriggerEvent('Dwoof:followDog')
    end
end, false)

RegisterKeyMapping("dogFollow", "Dog Follow", "KEYBOARD", "")

RegisterCommand("dogSit", function(source, args, raw)
    if spawnedDog ~= nil then
        TriggerEvent('Dwoof:sitDog')
    end
end, false)

RegisterKeyMapping("dogSit", "Dog Sit", "KEYBOARD", "")

RegisterCommand("dogLay", function(source, args, raw)
    if spawnedDog ~= nil then
        TriggerEvent('Dwoof:layDog')
    end
end, false)

RegisterKeyMapping("dogLay", "Dog Lay", "KEYBOARD", "")

RegisterCommand("dogBark", function(source, args, raw)
    if spawnedDog ~= nil then
        TriggerEvent('Dwoof:barkDog')
    end
end, false)

RegisterKeyMapping("dogBark", "Dog Bark", "KEYBOARD", "")

RegisterCommand("dogVehicle", function(source, args, raw)
    if spawnedDog ~= nil then
        TriggerEvent('Dwoof:enterVehicle')
    end
end, false)

RegisterKeyMapping("dogVehicle", "Dog Enter Vehicle", "KEYBOARD", "")

RegisterCommand("dogCarry", function(source, args, raw)
    if spawnedDog ~= nil then
        TriggerEvent('Dwoof:carryDog')
    end
end, false)

RegisterKeyMapping("dogCarry", "Dog Carry", "KEYBOARD", "")

RegisterNetEvent("Dwoof:cannabisDetected")

AddEventHandler("Dwoof:cannabisDetected", function()
    if spawnedDog ~= nil then
        if not attacking and not carrying and not inVehicle then
            TriggerEvent('Dwoof:barkDog')
        end
    end
end)

RegisterNetEvent('Dwoof:deleteDog')

AddEventHandler('DwoofDwoof:deleteDog', function()
    if spawnedDog ~= nil then
        if DoesEntityExist(spawnedDog) then
            SetEntityAsMissionEntity(spawnedDog, true, true)
            DeleteEntity(spawnedDog)
        end

        spawnedDog = nil
        following = false
        attacking = false
        attacked_player = 0
        inVehicle = false
        carrying = false
        tracking = false
        tracking_player = 0
    end
end)

RegisterNetEvent("Dwoof:followDog")

AddEventHandler("Dwoof:followDog", function()
    if spawnedDog ~= nil then
        if not following then
            local has_control = false

            RequestNetworkControl(function(cb)
                has_control = cb
            end)

            if has_control then
                if inVehicle then
                    local vehicle = GetEntityAttachedTo(spawnedDog)
                    local vehPos = GetEntityCoords(vehicle)
                    local forwardX = GetEntityForwardVector(vehicle).x * 3.7
                    local forwardY = GetEntityForwardVector(vehicle).y * 3.7
                    local _, groundZ = GetGroundZFor_3dCoord(vehPos.x, vehPos.y, vehPos.z, 0)

                    ClearPedTasks(spawnedDog)
                    DetachEntity(spawnedDog)
                    
                    SetEntityCoords(spawnedDog, vehPos.x - forwardX, vehPos.y - forwardY, groundZ)

                    inVehicle = false
                end

                TaskFollowToOffsetOfEntity(spawnedDog, PlayerPedId(), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
                SetPedKeepTask(spawnedDog, true)
                following = true
                attacking = false
                tracking = false
                Notification('Dog following.')
            end
        else
            local has_control = false
            RequestNetworkControl(function(cb)
                has_control = cb
            end)
            if has_control then
                SetPedKeepTask(spawnedDog, false)
                ClearPedTasks(spawnedDog)
                following = false
                attacking = false
                tracking = false
                Notification('Dog no longer following.')
            end
        end
    end
end)

RegisterNetEvent("Dwoof:searchVehicle")

AddEventHandler("Dwoof:searchVehicle", function()
    if spawnedDog ~= nil and not inVehicle then
        local Player = PlayerPedId()

        if not IsPedInAnyVehicle(Player, false) then
            local plyCoords = GetEntityCoords(Player, false)
            local vehicle = GetVehicleAheadOfPlayer()

            SetVehicleDoorOpen(vehicle, 0, 0, 0)
            SetVehicleDoorOpen(vehicle, 1, 0, 0)
            SetVehicleDoorOpen(vehicle, 2, 0, 0)
            SetVehicleDoorOpen(vehicle, 3, 0, 0)
            SetVehicleDoorOpen(vehicle, 4, 0, 0)
            SetVehicleDoorOpen(vehicle, 5, 0, 0)
            SetVehicleDoorOpen(vehicle, 6, 0, 0)
            SetVehicleDoorOpen(vehicle, 7, 0, 0)

            -- Back Right
            local offsetOne = GetOffsetFromEntityInWorldCoords(vehicle, 2.0, -2.0, 0.0)
            TaskGoToCoordAnyMeans(spawnedDog, offsetOne.x, offsetOne.y, offsetOne.z, 5.0, 0, 0, 1, 10.0)

            Citizen.Wait(7000)

            -- Front Right
            local offsetTwo = GetOffsetFromEntityInWorldCoords(vehicle, 2.0, 2.0, 0.0)
            TaskGoToCoordAnyMeans(spawnedDog, offsetTwo.x, offsetTwo.y, offsetTwo.z, 5.0, 0, 0, 1, 10.0)

            Citizen.Wait(7000)

            -- Front Left
            local offsetThree = GetOffsetFromEntityInWorldCoords(vehicle, -2.0, 2.0, 0.0)
            TaskGoToCoordAnyMeans(spawnedDog, offsetThree.x, offsetThree.y, offsetThree.z, 5.0, 0, 0, 1, 10.0)

            Citizen.Wait(7000)

            -- Front Right
            local offsetFour = GetOffsetFromEntityInWorldCoords(vehicle, -2.0, -2.0, 0.0)
            TaskGoToCoordAnyMeans(spawnedDog, offsetFour.x, offsetFour.y, offsetFour.z, 5.0, 0, 0, 1, 10.0)

            Citizen.Wait(7000)

            SetVehicleDoorsShut(vehicle, 0)
        end
    end
end)

RegisterNetEvent("Dwoof:enterVehicle")

AddEventHandler("Dwoof:enterVehicle", function()
    if spawnedDog ~= nil and not inVehicle then
        local Player = PlayerPedId()

        if not IsPedInAnyVehicle(Player, false) then
            local plyCoords = GetEntityCoords(Player, false)
            local vehicle = GetVehicleAheadOfPlayer()
            local vehHeading = GetEntityHeading(vehicle)

            inVehicle = true
            following = false
            attacking = false
            tracking = false

            ClearPedTasks(spawnedDog)

            TaskGoToEntity(spawnedDog, vehicle, -1, 0.5, 100, 1073741824, 0)
            TaskAchieveHeading(spawnedDog, vehHeading, -1)

            RequestAnimDict("creatures@rottweiler@in_vehicle@van")
            RequestAnimDict("creatures@rottweiler@amb@world_dog_sitting@base")

            while not HasAnimDictLoaded("creatures@rottweiler@in_vehicle@van") or not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_sitting@base") do
                Citizen.Wait(1)
            end

            TaskPlayAnim(spawnedDog, "creatures@rottweiler@in_vehicle@van", "get_in", 8.0, -4.0, -1, 2, 0.0)
            Citizen.Wait(700)
            ClearPedTasks(spawnedDog)

            if GetEntityBoneIndexByName(vehicle, 'seat_pside_r') ~= -1 then
                AttachEntityToEntity(spawnedDog, vehicle, GetEntityBoneIndexByName(vehicle, 'seat_pside_r'), 0.0, 0.0, 0.25)
                TaskPlayAnim(spawnedDog, "creatures@rottweiler@amb@world_dog_sitting@base", "base", 8.0, -4.0, -1, 2, 0.0)
            else
                AttachEntityToEntity(spawnedDog, vehicle, GetEntityBoneIndexByName(vehicle, 'seat_pside_f'), 0.0, 0.0, 0.25)
                TaskPlayAnim(spawnedDog, "creatures@rottweiler@amb@world_dog_sitting@base", "base", 8.0, -4.0, -1, 2, 0.0)
            end
        else
            local vehicle = GetVehiclePedIsIn(Player, false)
            local vehHeading = GetEntityHeading(vehicle)

            TaskGoToEntity(spawnedDog, vehicle, -1, 0.5, 100, 1073741824, 0)
            TaskAchieveHeading(spawnedDog, vehHeading, -1)

            RequestAnimDict("creatures@rottweiler@in_vehicle@van")
            RequestAnimDict("creatures@rottweiler@amb@world_dog_sitting@base")

            while not HasAnimDictLoaded("creatures@rottweiler@in_vehicle@van") or not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_sitting@base") do
                Citizen.Wait(1)
            end

            TaskPlayAnim(spawnedDog, "creatures@rottweiler@in_vehicle@van", "get_in", 8.0, -4.0, -1, 2, 0.0)
            Citizen.Wait(700)
            ClearPedTasks(spawnedDog)

            AttachEntityToEntity(spawnedDog, vehicle, GetEntityBoneIndexByName(vehicle, 'seat_pside_r'), 0.0, 0.0, 0.25)
            TaskPlayAnim(spawnedDog, "creatures@rottweiler@amb@world_dog_sitting@base", "base", 8.0, -4.0, -1, 2, 0.0)

            inVehicle = true
            following = false
            attacking = false
            tracking = false
        end
    end
end)

RegisterNetEvent("Dwoof:sitDog")

AddEventHandler("Dwoof:sitDog", function()
    if spawnedDog ~= nil then
        RequestAnimDict(animations.sit.dict)

        while not HasAnimDictLoaded(animations.sit.dict) do
            Citizen.Wait(0)
        end

        TaskPlayAnim(spawnedDog, animations.sit.dict, animations.sit.anim, 8.0, -8.0, -1, 2, 0.0, 0, 0, 0)
    end
end)

RegisterNetEvent("Dwoof:layDog")

AddEventHandler("Dwoof:layDog", function()
    if spawnedDog ~= nil then
        RequestAnimDict(animations.laydown.dict)

        while not HasAnimDictLoaded(animations.laydown.dict) do
            Citizen.Wait(0)
        end

        TaskPlayAnim(spawnedDog, animations.laydown.dict, animations.laydown.anim, 8.0, -8.0, -1, 2, 0.0, 0, 0, 0)
    end
end)

RegisterNetEvent("Dwoof:barkDog")

AddEventHandler("Dwoof:barkDog", function()
    if spawnedDog ~= nil then
        RequestAnimDict(animations.searchhit.dict)

        while not HasAnimDictLoaded(animations.searchhit.dict) do
            Citizen.Wait(0)
        end

        TaskPlayAnim(spawnedDog, animations.searchhit.dict, animations.searchhit.anim, 8.0, -8.0, -1, 1, 0.0, 0, 0, 0)
    end
end)

RegisterNetEvent("Dwoof:standDog")

AddEventHandler("Dwoof:standDog", function()
    if spawnedDog ~= nil then
        ClearPedTasks(spawnedDog)
    end
end)

RegisterNetEvent("Dwoof:carryDog")

AddEventHandler("Dwoof:carryDog", function()
    if spawnedDog ~= nil then
        if inVehicle then
            local vehicle = GetEntityAttachedTo(spawnedDog)
            local vehPos = GetEntityCoords(vehicle)
            local forwardX = GetEntityForwardVector(vehicle).x * 3.7
            local forwardY = GetEntityForwardVector(vehicle).y * 3.7
            local _, groundZ = GetGroundZFor_3dCoord(vehPos.x, vehPos.y, vehPos.z, 0)

            ClearPedTasks(spawnedDog)
            DetachEntity(spawnedDog)
            
            SetEntityCoords(spawnedDog, vehPos.x - forwardX, vehPos.y - forwardY, groundZ)

            inVehicle = false
        end

        tracking = false

        if carrying then
            ClearPedTasks(spawnedDog)
            DetachEntity(spawnedDog)

            carrying = false
        else
            local playerPed = PlayerPedId()

            AttachEntityToEntity(spawnedDog, playerPed, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

            carrying = true
        end
    end
end)

RegisterNetEvent("Dwoof:teleportDog")

AddEventHandler("Dwoof:teleportDog", function()
    if spawnedDog ~= nil then
        if inVehicle then
            local vehicle = GetEntityAttachedTo(spawnedDog)
            local vehPos = GetEntityCoords(vehicle)
            local forwardX = GetEntityForwardVector(vehicle).x * 3.7
            local forwardY = GetEntityForwardVector(vehicle).y * 3.7
            local _, groundZ = GetGroundZFor_3dCoord(vehPos.x, vehPos.y, vehPos.z, 0)

            ClearPedTasks(spawnedDog)
            DetachEntity(spawnedDog)
            
            SetEntityCoords(spawnedDog, vehPos.x - forwardX, vehPos.y - forwardY, groundZ)

            inVehicle = false
        end

        local plyCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)

        SetEntityCoords(spawnedDog, plyCoords.x, plyCoords.y, plyCoords.z, GetEntityHeading(PlayerPedId()), 0)
    end
end)

RegisterNetEvent("Dwoof:spawnDog")

AddEventHandler("Dwoof:spawnDog", function(model)
    if spawnedDog == nil then
        local localPed = PlayerPedId()
        local ped = GetHashKey(model)

        RequestModel(ped)
        while not HasModelLoaded(ped) do
            Citizen.Wait(1)
            RequestModel(ped)
        end

        local plyCoords = GetOffsetFromEntityInWorldCoords(localPed, 0.0, 2.0, 0.0)
        local dog = CreatePed(28, ped, plyCoords.x, plyCoords.y, plyCoords.z, GetEntityHeading(localPed), 0, 1)
        spawnedDog = dog

        SetPedComponentVariation(dog, 0, 0, 1, 0)
        SetPedComponentVariation(dog, 0, 0, 0, 0)

        GiveWeaponToPed(spawnedDog, GetHashKey('WEAPON_ANIMAL'), true, true)
        TaskSetBlockingOfNonTemporaryEvents(spawnedDog, true)
        SetPedFleeAttributes(spawnedDog, 0, false)
        SetPedCombatAttributes(spawnedDog, 3, true)
        SetPedCombatAttributes(spawnedDog, 5, true)
        SetPedCombatAttributes(spawnedDog, 46, true)
        SetEntityInvincible(spawnedDog, true)

        local blip = AddBlipForEntity(spawnedDog)
        SetBlipAsFriendly(blip, true)
        SetBlipSprite(blip, 442)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Dog")
        EndTextCommandSetBlipName(blip)

        NetworkRegisterEntityAsNetworked(spawnedDog)

        while not NetworkGetEntityIsNetworked(spawnedDog) do
            NetworkRegisterEntityAsNetworked(spawnedDog)
            Citizen.Wait(1)
        end
    else
        local has_control = false
        RequestNetworkControl(function(cb)
            has_control = cb
        end)
        if has_control then
            SetEntityAsMissionEntity(spawnedDog, true, true)
            DeleteEntity(spawnedDog)
            spawnedDog = nil
            if attacking then
                SetPedRelationshipGroupDefaultHash(spawnedDog, GetHashKey("CIVMALE"))
                spawnedDog = nil
                attacking = false
            end
            following = false
            searching = false
            playing_animation = false
            tracking = false
        end
    end
end)

function RequestNetworkControl(callback)
    local netId = NetworkGetNetworkIdFromEntity(spawnedDog)
    local timer = 0
    NetworkRequestControlOfNetworkId(netId)
    while not NetworkHasControlOfNetworkId(netId) do
        Citizen.Wait(1)
        NetworkRequestControlOfNetworkId(netId)
        timer = timer + 1
        if timer == 5000 then
			if DoesEntityExist(spawnedDog) then
				SetEntityAsMissionEntity(spawnedDog, true, true)
				DeleteEntity(spawnedDog)
			end

			spawnedDog = nil
			following = false
			attacking = false
			attacked_player = 0
			inVehicle = false
			carrying = false
			tracking = false
			tracking_player = 0
            Citizen.Trace("Control failed")
            callback(false)
            break
        end
    end
    callback(true)
end

function Notification(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0, 1)
end

function GetPlayerId(target_ped)
    local players = GetActivePlayers()

    for a = 1, #players do
        local ped = GetPlayerPed(players[a])
        local server_id = GetPlayerServerId(players[a])

        if target_ped == ped then
            return server_id
        end
    end

    return 0
end

-- Gets Vehicle Ahead Of Player
function GetVehicleAheadOfPlayer()
    local lPed = PlayerPedId()
    local lPedCoords = GetEntityCoords(lPed, alive)
    local lPedOffset = GetOffsetFromEntityInWorldCoords(lPed, 0.0, 3.0, 0.0)
    local rayHandle = StartShapeTestCapsule(lPedCoords.x, lPedCoords.y, lPedCoords.z, lPedOffset.x, lPedOffset.y, lPedOffset.z, 1.2, 10, lPed, 7)
    local returnValue, hit, endcoords, surface, vehicle = GetShapeTestResult(rayHandle)

    if hit then
        return vehicle
    else
        return false
    end
end

-- Gets Closest Door To Player
function GetClosestVehicleDoor(vehicle)
    local plyCoords = GetEntityCoords(PlayerPedId(), false)
	local backleft = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_dside_r"))
	local backright = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_pside_r"))
	local bldistance = GetDistanceBetweenCoords(backleft['x'], backleft['y'], backleft['z'], plyCoords.x, plyCoords.y, plyCoords.z, 1)
    local brdistance = GetDistanceBetweenCoords(backright['x'], backright['y'], backright['z'], plyCoords.x, plyCoords.y, plyCoords.z, 1)

    local found_door = false

    if (bldistance < brdistance) then
        found_door = 1
    elseif(brdistance < bldistance) then
        found_door = 2
    end

    return found_door
end
