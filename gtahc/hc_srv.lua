local playerCount = 0
local playerList = {}
local runnersDead = 0
local copsDead = 0
local playerReady = 0
local runningInProgress = false
local placing = 0
local runnersTeam = 0
local copsTeam = 0
local runnerWon = 0
local cops = {}
local runners = {}
local timer = 0
local placing = 0
local placingCop = 0
local placingRunner = 0
local selectcar = false

local function SetTeam()
    --team = math.random(1,4)
    --print("Random Team is: "..team)
    --if team == 1 or team == 3 then
    --elseif team == 2 then
    if runnersTeam == copsTeam then 
        TriggerClientEvent('hc:setTeam', source, 1)
        copsTeam = copsTeam + 1
        print("nombre de flics: "..copsTeam)
        print("nombre de runners: "..runnersTeam)
        TriggerClientEvent("chatMessage", source, '', { 0, 0, 0 }, "^0* You are Cop!")
        if not cops[source] then
            cops[source] = true 
        end
        if runners[source] then
            runners[source] = nil
        end
    --elseif team == 2 or team == 4 then
    elseif runnersTeam ~= copsTeam then
        TriggerClientEvent('hc:setTeam', source, 2)
        runnersTeam = runnersTeam + 1
        print("nombre de flics: "..copsTeam)
        print("nombre de runners: "..runnersTeam)
        TriggerClientEvent("chatMessage", source, '', { 0, 0, 0 }, "^0* You are ^1Runner!")
        if not runners[source] then
            runners[source] = true 
        end
        if cops[source] then
            cops[source] = nil
        end
    end
    TriggerClientEvent('hc:numTeam', -1, runnersTeam, copsTeam)
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "Cops: "..copsTeam.." and Runners: "..runnersTeam)
end

RegisterServerEvent('hc:newTeam')
AddEventHandler('hc:newTeam', function()
    runnersDead = 0
    copsDead = 0
    playerReady = 0
    runningInProgress = false
    copsTeam = 0
    runnersTeam = 0
    runnerWon = 0
    timer = 0
    placing = 0
    placingCop = 0
    placingRunner = 0
    SetTeam()
    if not selectcar then
        selectcar = true
        TriggerClientEvent('hc:selectCar', -1)
    end
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^0* New ^1Team!")
end)

RegisterServerEvent('hc:changeTeam')
AddEventHandler('hc:changeTeam', function(team)
    if team == 1 then
        if not cops[source] then
            cops[source] = true
            copsTeam = copsTeam + 1
        end
        if runners[source] then
            runners[source] = nil
            runnersTeam = runnersTeam - 1
        end
    elseif team == 2 then
        if not runners[source] then
            runners[source] = true 
            runnersTeam = runnersTeam + 1
        end
        if cops[source] then
            cops[source] = nil
            copsTeam = copsTeam - 1
        end
    end
    print("nombre de flics: "..copsTeam)
    print("nombre de runners: "..runnersTeam)
    TriggerClientEvent('hc:numTeam', -1, runnersTeam, copsTeam)
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "Cops: "..copsTeam.." and Runners: "..runnersTeam)
end)

RegisterServerEvent('hc:firstJoin')
AddEventHandler('hc:firstJoin', function()
    playerCount = playerCount + 1
    print("Number of players: "..playerCount)
    TriggerClientEvent('hc:numOfPlayers', -1, playerCount)
    SetTeam()
    if not playerList[source] then
        playerList[source] = true
    end
    if runningInProgress then
        TriggerClientEvent('hc:joinSpectate', source)
    else
        TriggerClientEvent('hc:selectCar', source)
    end
    TriggerClientEvent('hc:numTeam', -1, runnersTeam, copsTeam)
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "Cops: "..copsTeam.." and Runners: "..runnersTeam)
end)


RegisterServerEvent('hc:carSelected')
AddEventHandler('hc:carSelected', function()
--  Wait(500)

    if runners[source] then
        placingRunner = placingRunner + 1
        TriggerClientEvent('hc:startingBlock', source, placingRunner)
    elseif cops[source] then
        placingCop = placingCop + 1
        TriggerClientEvent('hc:startingBlock', source, placingCop)
    end
    selectcar = false
end)

RegisterServerEvent('hc:plyReady')
AddEventHandler('hc:plyReady', function()
    playerReady = playerReady + 1
    print("PLayer Ready: "..playerReady)
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* "..playerReady.."/^2"..playerCount.."^1 ready")
    if playerReady == playerCount then
        print("Go Go Go")
        TriggerClientEvent('hc:startRun', -1)
        runningInProgress = true
        playerReady = 0
    end
end)

RegisterServerEvent('hc:damageRunner')
AddEventHandler('hc:damageRunner', function(n)
    TriggerClientEvent('hc:runnerTouched', n)
    local name = GetPlayerName(source)
    TriggerClientEvent("chatMessage", n, '', { 0, 0, 0 }, "^0* You have been ^1touch ^0by "..name)
end)

RegisterServerEvent('hc:runnerWon')
AddEventHandler('hc:runnerWon', function()
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* Runner Win!!")
    runnerWon = runnerWon + 1
    if runnerWon == runnersTeam then
        TriggerClientEvent('hc:endRun', -1)
        runnersDead = 0
        copsDead = 0
        playerReady = 0
        runningInProgress = false
        runnerWon = 0
        timer = 0
        placing = 0
        placingCop = 0
        placingRunner = 0
        if not selectcar then
            selectcar = true
            TriggerClientEvent('hc:selectCar', -1)
        end
    end
end)

RegisterServerEvent('hc:addTime')
AddEventHandler('hc:addTime', function()
    timer = timer + 1
    if timer == 60 then
        TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* 2 minutes remaining!!")
    end
    if timer == 120 then
        TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* 1 minute Left!!")
    end
    if timer == 180 then
        TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* Runner Win!!")
        TriggerClientEvent('hc:endRun', -1)
        runnersDead = 0
        copsDead = 0
        playerReady = 0
        runningInProgress = false
        runnerWon = 0
        timer = 0
        placing = 0
        placingCop = 0
        placingRunner = 0
        if not selectcar then
            selectcar = true
            TriggerClientEvent('hc:selectCar', -1)
        end
    end
end)

RegisterServerEvent('hc:runnerDead')
AddEventHandler('hc:runnerDead', function()
	runnersDead = runnersDead + 1
    local name = GetPlayerName(source)
	TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* "..name.." owned!!!")
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* Only "..runnersTeam.." runners left!!")
	print(source.." is dead")
    if runnersTeam == runnersDead then
        TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* Cop Win!!")
        TriggerClientEvent('hc:endRun', -1)
        runnersDead = 0
        copsDead = 0
        playerReady = 0
        runningInProgress = false
        runnerWon = 0
        timer = 0
        placing = 0
        placingCop = 0
        placingRunner = 0
		if not selectcar then
            selectcar = true
            TriggerClientEvent('hc:selectCar', -1)
        end
		TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* Number of dead runner: "..runnersDead)
	else
		TriggerClientEvent('hc:joinSpectate', source)
	end
end)

RegisterServerEvent('hc:copDead')
AddEventHandler('hc:copDead', function()
    copsDead = copsDead + 1
    local name = GetPlayerName(source)
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* "..name.." is dead!!!")
    print(source.." is dead")
    if copsTeam == copsDead then
        TriggerClientEvent('hc:endRun', -1)
        runnersDead = 0
        copsDead = 0
        playerReady = 0
        runningInProgress = false
        runnerWon = 0
        timer = 0
        placing = 0
        placingCop = 0
        placingRunner = 0
        if not selectcar then
            selectcar = true
            TriggerClientEvent('hc:selectCar', -1)
        end
        TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* Number of dead cops: "..copsDead)
    else
        TriggerClientEvent('hc:joinSpectate', source)
    end
end)

RegisterServerEvent('hc:plyQuit')
AddEventHandler('hc:plyQuit', function()
    if runners[source] then
        runners[source] = nil
        runnersTeam = runnersTeam - 1
        print("Number of runners: "..runnersTeam)
    elseif cops[source] then
        cops[source] = nil
        copsTeam = copsTeam - 1
        print("Number of cops: "..copsTeam)
    end
    if playerList[source] then
        playerList[source] = nil
        playerCount = playerCount - 1
    end
    runningInProgress = false
    runnersDead = 0
    copsDead = 0
    playerReady = 0
    runningInProgress = false
    runnerWon = 0
    timer = 0
    placing = 0
    placingCop = 0
    placingRunner = 0
    TriggerClientEvent('hc:numOfPlayers', -1, playerCount)
    TriggerClientEvent('hc:numTeam', -1, runnersTeam, copsTeam)
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "Cops: "..copsTeam.." and Runners: "..runnersTeam)
end)


AddEventHandler('playerDropped', function()
    if playerList[source] then
        playerCount = playerCount - 1
        playerList[source] = nil
        print("Nomber of players: "..playerCount)
    end
    if playerReady ~= 0 then
        playerReady = playerReady - 1
    end
    if runners[source] then
        runners[source] = nil
        runnersTeam = runnersTeam - 1
        print("Number of runners: "..runnersTeam)
    elseif cops[source] then
        cops[source] = nil
        copsTeam = copsTeam - 1
        print("Number of cops: "..copsTeam)
    end
    if runnersTeam == 0 then
        runningInProgress = false
        TriggerClientEvent('hc:endRun', -1)
        runnersDead = 0
        copsDead = 0
        playerReady = 0
        runningInProgress = false
        runnerWon = 0
        timer = 0
        placing = 0
        placingCop = 0
        placingRunner = 0
        if not selectcar then
            selectcar = true
            TriggerClientEvent('hc:selectCar', -1)
        end
    end
    TriggerClientEvent('hc:numOfPlayers', -1, playerCount)
    TriggerClientEvent('hc:numTeam', -1, runnersTeam, copsTeam)
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "Cops: "..copsTeam.." and Runners: "..runnersTeam)
end)


--Mettre un message quand le joueur est au marqueur pour lui dire quoi faire
--Menu qui affiche les joueurs et leur team (Bleu Police et Rouge Runner)
--Empecher le jeux de se lancer s'il y a plus de runner que de policer