RegisterServerEvent("DevlarWoof:sendTrackRequest")

AddEventHandler("DevlarWoof:sendTrackRequest", function(targetPlayer)
    local ownIdentifier = GetPlayerIdentifiers(source)[1]
    local ownData = exports['Devlar-Framework']:getPlayerData(ownIdentifier)

    local identifier = GetPlayerIdentifiers(targetPlayer)[1]
    local playerData = exports['Devlar-Framework']:getPlayerData(identifier)
    
    TriggerClientEvent("chatMessage", source, "DOG", {255, 0, 0}, "Your dog is trying to get a scent on " .. playerData.displayName .. ".")
    TriggerClientEvent("DevlarWoof:trackRequest", targetPlayer, source, ownData.displayName)
end)

RegisterServerEvent("DevlarWoof:sendTrackResult")

AddEventHandler("DevlarWoof:sendTrackResult", function(targetPlayer, result)
    local ownIdentifier = GetPlayerIdentifiers(source)[1]
    local ownData = exports['Devlar-Framework']:getPlayerData(ownIdentifier)

    cleanResult = false

    if string.lower(result) == 'yes' then
        cleanResult = true
        TriggerClientEvent("chatMessage", targetPlayer, "DOG", {255, 0, 0}, "Your dog has a scent on " .. ownData.displayName .. ".")
        TriggerClientEvent("chatMessage", source, "DOG", {255, 0, 0}, "The dog was able to trace you.")

        TriggerClientEvent("DevlarWoof:trackResult", targetPlayer, source, true)
    else
        cleanResult = false
        TriggerClientEvent("chatMessage", targetPlayer, "DOG", {255, 0, 0}, "Your dog was unable to locate " .. ownData.displayName .. ".")
        TriggerClientEvent("chatMessage", source, "DOG", {255, 0, 0}, "The dog was unable to trace you.")
    end
end)