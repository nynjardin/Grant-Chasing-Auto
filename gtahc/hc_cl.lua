local players = {}
local alive = {}
local touch = 0
local runInProgress = false
local teamCop = false
local teamRunner = false
local ready = false
local plyRun = 0
local plyToSpec = players[plyRun]
local plyInGame = 0
local inRun = false
local gameTimer = 0

local SpawnPositions = {
    {-3113.44, 1274.56, 20.2978},
    {-3113.29, 1280.34, 20.3221},
    {-3111.37, 1284.66, 20.298},
    {-3111.03, 1288.62, 20.3134},
    {-3110.05, 1295.48, 20.302},
    {-3108.96, 1301.24, 20.2312},
    {-3106.05, 1307.3, 20.088},
    {-3105.69, 13011.34, 20.1776},
    {-3105.30, 1315.94, 20.1891},
    {-3104.31, 1320.83, 20.2043},
    {-3103.61, 1325.82, 20.3397},
    {-3102.86, 1330.61, 20.2128},
    {-3101.52, 1334.14, 20.2497},
    {-3097.66, 1343.49, 20.2117},
    {-3096.21, 1346.64, 20.2259},
    {-3094.84, 1350.37, 20.2345}
}

local SpawRunnersPos = {
    {-830.410,-2364.311,14.089,147.948},
    {-821.878,-2362.403,14.089,331.732},
    {-805.301,-2352.664,14.083,152.095},
    {-800.602,-2336.376,14.084,139.074},
    {-791.258,-2379.172,14.087,330.169},
    {-776.310,-2387.846,14.083,330.493},
    {-761.371,-2396.106,14.087,334.174},
    {-755.459,-2383.333,14.084,133.310},
    {-762.482,-2375.981,14.084,129.708},
    {-752.552,-2401.187,14.085,331.108}
}

local SpawCopsPos = {
    {-595.217,-2310.977,13.343,138.399},
    {-592.091,-2312.908,13.345,139.513},
    {-589.847,-2315.841,13.343,139.394},
    {-587.641,-2317.791,13.344,143.773},
    {-585.428,-2320.695,13.342,141.393},
    {-582.744,-2323.122,13.341,137.207},
    {-579.516,-2324.729,13.342,144.204},
    {-576.659,-2326.716,13.342,140.955},
    {-574.406,-2329.519,13.341,137.968},
    {-571.498,-2331.458,13.343,141.296}
}

local insideGarage = { --1 x, y, z, vehicleHeading, pedHeading
    {x = -46.56327, y = -1097.382, z = 25.99875, vh = 228.2736, ph = 120.1953}, -- 1 Basic Garage
    {x = 228.721, y = -993.374, z = -99.0, vh = 228.2736, ph = 120.1953}, -- 2 Clean Garage
    {x = 480.991, y = -1317.7, z = 29.2027, vh = 131.7264, ph = 120.1953}, -- 3 Dirty Garage
    {x = -211.309, y = -1324.41, z = 30.8904, vh = 228.2736, ph = 120.1953}, -- 4 Fun Garage
    {x = 436.441, y = -996.352, z = 25.7738, vh = 228.2736, ph = 120.1953}, -- 5 Underground Police Garage
    {x = 449.511, y = -981.129, z = 43.6916, vh = 228.2736, ph = 120.1953}, -- 6 Roof of police station
    {x = -75.1452, y = -818.625, z = 326.176, vh = 228.2736, ph = 120.1953}, -- 7 Roof of the highest building of Vice City
    {x = 110.729, y = 6626.407, z = 31.787, vh = 228.2736, ph = 120.1953}, -- 8 Simple Custom Garage
    {x = -1156.748, y = -2009.824, z = 13.180, vh = 228.2736, ph = 120.1953}, -- 9 Simple Custom Garage
    {x = 732.951, y = -1086.138, z = 22.168, vh = 228.2736, ph = 120.1953}, -- 10 Dirty Garage Bigger
    {x = -334.172, y = -137.801, z = 39.009, vh = 228.2736, ph = 120.1953}, -- 11 Simple Custom Garagen
    {x = 1175.404, y = 2640.987, z = 37.753, vh = 228.2736, ph = 120.1953}, -- 12 Little Custom Garage
    {x = -693.727, y = -757.278, z = 33.684, vh = 228.2736, ph = 120.1953} -- 13 Carpark 
}

carList = {"polf430","pol718","polaven","polmp4","polp1","polgt500"}
runnersCarList = {"adder","banshee2","bullet","cheetah","entityxf","sheava","fmj","infernus","osiris","le7b","reaper","sultanrs","t20","turismor","tyrus","vacca","voltic","prototipo","zentorno"}


local num = 1 --# of the car in car list to show first
local carToShow = carList[num] --carToShow become the car to show

function FadingOut(time)
    if not IsScreenFadedOut() then
        if not IsScreenFadingOut() then
            DoScreenFadeOut(time)
        end
    end
end

function FadingIn(time)
    if IsScreenFadedOut() or IsScreenFadingOut() then
        DoScreenFadeIn(time)
    end
end


function ShowCar(car)
    Wait(100)
    if GetPlayerTeam(PlayerId()) == 1 then -- police ?
        inGar = insideGarage[2] -- Change this number to chnage the police garage
    elseif GetPlayerTeam(PlayerId()) == 2 then -- runner ?
        inGar = insideGarage[9] -- Change this number to chnage the runner garage
    end
    --insideVeh = {-46.56327,-1097.382,25.99875, 228.2736} --coordonnée de l'interieur du garage, la 4eme est l'oriendtation de la voiture
    modelVeh = GetHashKey(car) --The necessary hashkey to create the car
    RequestModel(modelVeh) --Call the car model
    while not HasModelLoaded(modelVeh) do --Wait the model to be loaded
        Citizen.Wait(0)
    end
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Number of player: '..plyInGame )
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Vehicle model loaded' )
    personalvehicle = CreateVehicle(modelVeh ,inGar.x, inGar.y, inGar.z, inGar.vh, false, false) --The first False is for make the car not visible on network
    Citizen.InvokeNative(0xB736A491E64A32CF,Citizen.PointerValueIntInitialized(personalvehicle)) --The car will be detroyed when nobody look at it
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Car choosen: '..modelVeh)
    SetVehicleOnGroundProperly(personalvehicle) --Be sure the car have 4 wheel on ground
    SetVehicleHasBeenOwnedByPlayer(personalvehicle,true) --Set car is owned by player
    local id = NetworkGetNetworkIdFromEntity(personalvehicle) --Don't know what is that, but is necessary
    SetNetworkIdCanMigrate(id, true) --Don't know what is that, but is necessary
    TaskWarpPedIntoVehicle(GetPlayerPed(-1), personalvehicle ,-1)
end 

--fonction pour le choix de la couleur, mais on ne peut pas vraiment le faire...
function ColorToCar(color)
    SetVehicleColours(personalvehicle, color)
end

function DrawMissionText(m_text, showtime)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(m_text)
    DrawSubtitleTimed(showtime, 1)
end

local function DrawCountDown(n)
        SetTextFont( 7 )
        SetTextProportional(0)
        SetTextScale( 3.0989999999999, 3.0989999999999 )
        N_0x4e096588b13ffeca(0)
        SetTextColour( 255, 255, 255, 255 )
        SetTextDropShadow(0, 0, 0, 0,255)
        SetTextEdge(5, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry( "STRING" )
        AddTextComponentString( n )
        DrawText( 0.5, 0.5 )
end


local function CountDown3()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if GetGameTimer() < LastPress3 + 1000 then
                DrawCountDown("3")
            end
        end
    end)
end

local function CountDown2()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if GetGameTimer() < LastPress2 + 1000 then
                DrawCountDown("2")
            end
        end
    end)
end

local function CountDown1()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if GetGameTimer() < LastPress1 + 1000 then
                DrawCountDown("1")
            end
        end
    end)
end

local function CountDownGo()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if GetGameTimer() < LastPressGo + 1000 then
                DrawCountDown("Go")
            end
        end
    end)
end

local function spectatePlayer()
    endScreen = false
    spectate = true
    FreezeEntityPosition(GetPlayerPed(-1),  true)
    SetPlayerWantedLevel(PlayerId(), 0, false)
    SetPlayerWantedLevelNow(PlayerId(), false)
    RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(plyToSpec), 1))
    NetworkSetInSpectatorMode(1, GetPlayerPed(plyToSpec))
    print("Spectating ~b~"..GetPlayerName(plyToSpec))
    while true do
        Citizen.Wait(0)
        if spectate then
            --[[if IsPedFatallyInjured(GetPlayerPed(plyToSpec)) or NetworkIsPlayerActive( plyToSpec ) then
                Wait(2500)
                TriggerServerEvent('hp:observedDead') --Envoie au serveur que l'observé est mort
            end]]
            if IsControlJustPressed(1,190) and plyRun < #players then --Right Arrow
                FadingOut(500)
                plyRun = plyRun + 1 
                plyToSpec = players[plyRun]
                if IsPedSittingInAnyVehicle(GetPlayerPed(plyToSpec)) then 
                    FreezeEntityPosition(GetPlayerPed(-1),  true)
                    SetPlayerWantedLevel(PlayerId(), 0, false)
                    SetPlayerWantedLevelNow(PlayerId(), false)
                    RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(plyToSpec), 1))
                    NetworkSetInSpectatorMode(1, GetPlayerPed(plyToSpec))
                    DrawMissionText("Spectating ~b~"..GetPlayerName(plyToSpec), 10000)
                end
                FadingIn(500)
            end

            if IsControlJustPressed(1,189) and plyRun > 0 then --Left Arrow
                FadingOut(500)
                plyRun = plyRun - 1 
                plyToSpec = players[plyRun]
                if IsPedSittingInAnyVehicle(GetPlayerPed(plyToSpec)) then 
                    FreezeEntityPosition(GetPlayerPed(-1),  true)
                    SetPlayerWantedLevel(PlayerId(), 0, false)
                    SetPlayerWantedLevelNow(PlayerId(), false)
                    RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(plyToSpec), 1))
                    NetworkSetInSpectatorMode(1, GetPlayerPed(plyToSpec))
                    DrawMissionText("Spectating ~b~"..GetPlayerName(plyToSpec), 10000)
                end
                FadingIn(500)
            end
            if not runInProgress then
                FreezeEntityPosition(GetPlayerPed(-1),  false)
                SetPlayerWantedLevel(PlayerId(), 0, false)
                SetPlayerWantedLevelNow(PlayerId(), false)
                RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(-1), 1))
                NetworkSetInSpectatorMode(0, GetPlayerPed(-1))
                spectate = false
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            TriggerServerEvent('hc:firstJoin')
            return
        end
    end
end)


RegisterNetEvent('hc:setTeam')
AddEventHandler('hc:setTeam', function(t)
    SetPlayerTeam(PlayerId(),  t)
    if t == 1 then
        TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 team: cop')
        teamRunner = false
        teamCop = true
    elseif t == 2 then
        TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 team: runner')
        teamRunner = true
        teamCop = false
    end
end)


RegisterNetEvent('hc:selectCar')
AddEventHandler('hc:selectCar', function()
    
    endScreen = false
    if GetPlayerTeam(PlayerId()) == 1 then -- police ?
        carList = {"polf430","pol718","polaven","polbuga","polmp4","polp1","polgt500"}
        ShowCar(carList[num]) --first car to show
    elseif GetPlayerTeam(PlayerId()) == 2 then -- runner ?
        carList = {"adder","banshee2","bullet","cheetah","entityxf","sheava","fmj","infernus","osiris","le7b","reaper","sultanrs","t20","turismor","tyrus","vacca","voltic","prototipo","zentorno"}
        ShowCar(carList[num])
    end
    FadingIn(1000)

    SetEntityHealth(GetPlayerPed(-1), 200)
    while true do
        Citizen.Wait(0)
            if not ready then
                --Choosing car
                if IsControlJustPressed(1,190) and num < #carList then --Right Arrow
                    SetModelAsNoLongerNeeded(personalvehicle) --Set car ready to be destroyed
                    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle)) -- Destroy car in the choosing place
                    num = num + 1 
                    carToShow = carList[num]
                    ShowCar(carToShow)
                end

                if IsControlJustPressed(1,189) and num > 1 then --Left Arrow
                    SetModelAsNoLongerNeeded(personalvehicle)
                    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle))
                    num = num - 1
                    carToShow = carList[num]
                    ShowCar(carToShow)
                end

                --Affichage de la couleur de la voiture
                if IsControlJustPressed(1,188) then --Up Arrow
                    SetModelAsNoLongerNeeded(personalvehicle) 
                    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle)) 
                    ShowCar(carToShow)
                end

                if IsControlJustPressed(1,187) then --Down Arrow
                    SetModelAsNoLongerNeeded(personalvehicle)
                    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle))
                    ShowCar(carToShow)
                end

                if IsControlJustPressed(1,206) or IsControlJustPressed(1,205) then --RB or LB
                    FadingOut(500)
                    Wait(500)
                    if GetPlayerTeam(PlayerId()) == 1 then
                        SetPlayerTeam(PlayerId(),  2)
                        teamRunner = true
                        teamCop = false
                        carList = {"adder","banshee2","bullet","cheetah","entityxf","sheava","fmj","infernus","osiris","le7b","reaper","sultanrs","t20","turismor","tyrus","vacca","voltic","prototipo","zentorno"}
                        num = 1
                        carToShow = carList[num]
                        ShowCar(carToShow)
                        local plyTeam = GetPlayerTeam(PlayerId())
                        TriggerServerEvent('hc:changeTeam', plyTeam) --Send to server car is choosen
                    elseif GetPlayerTeam(PlayerId()) == 2 then
                        SetPlayerTeam(PlayerId(),  1)
                        teamRunner = false
                        teamCop = true
                        carList = {"polf430","pol718","polaven","polbuga","polmp4","polp1","polgt500"}
                        num = 1
                        carToShow = carList[num]
                        ShowCar(carToShow)
                        local plyTeam = GetPlayerTeam(PlayerId())
                        TriggerServerEvent('hc:changeTeam', plyTeam) --Send to server car is choosen
                    end
                    Wait(500)
                    FadingIn(500)
                end

            --as long as nothing validate, show car
                if IsControlJustPressed(1,201) and plyInGame > 1 then -- 201 : "A" or Enter
                    --modelVeh = GetHashKey(carToShow)
                    FadingOut(500)
                    Wait(500)
                    ready = true --Put player ready
                    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Validated')
                    SetModelAsNoLongerNeeded(personalvehicle) --Set car ready to be destroyed
                    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle)) --Destroy car in the choosing place
                    Wait(1000)
                    TriggerServerEvent('hc:carSelected') --Send to server car is choosen
                else
                    FreezeEntityPosition(GetPlayerPed(-1),true) 
                    SetEntityVisible(GetPlayerPed(-1),false) 
                    SetEntityCoords(personalvehicle, inGar.x, inGar.y, inGar.z,1,0,0,1)
                    SetEntityHeading(GetPlayerPed(-1),inGar.ph) 
                    TaskWarpPedIntoVehicle(GetPlayerPed(-1), personalvehicle ,-1)
                    plyVeh = GetVehiclePedIsUsing(GetPlayerPed(-1))
                    colors = table.pack(GetVehicleColours(plyVeh))
                    extra_colors = table.pack(GetVehicleExtraColours(plyVeh))
                end
            else return end
    end
end)



RegisterNetEvent('hc:startingBlock')
AddEventHandler('hc:startingBlock', function(spwNum)
    Wait(500)
    local spawnPos = SpawnPositions[spwNum]
    if GetPlayerTeam(PlayerId()) == 1 then -- police ?
        carList = {"polf430","pol718","polaven","polbuga","polmp4","polp1","polgt500"}
        carToShow = carList[num] --first car to show
        spawnPos = SpawCopsPos[spwNum]
    elseif GetPlayerTeam(PlayerId()) == 2 then -- runner ?
        carList = {"adder","banshee2","bullet","cheetah","entityxf","sheava","fmj","infernus","osiris","le7b","reaper","sultanrs","t20","turismor","tyrus","vacca","voltic","prototipo","zentorno"}
        carToShow = carList[num]
        spawnPos = SpawRunnersPos[spwNum]
    end
    modelVeh2 = GetHashKey(carToShow) 
    ---------------------------------- Make appair the choosen car on network and teleport player in it
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^2 Client: carToShow: '..carToShow )
    RequestModel(modelVeh2)
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Model requested: '..modelVeh2 )
    while not HasModelLoaded(modelVeh2) do
        Citizen.Wait(0)
    end
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Vehicle model loaded' )
    personalvehicle2 = CreateVehicle(modelVeh2, spawnPos[1], spawnPos[2], spawnPos[3], 228.2736, true, false)

    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Choosen Car: '..modelVeh2)

    SetVehicleOnGroundProperly(personalvehicle2)
    SetVehicleHasBeenOwnedByPlayer(personalvehicle2,true)
    local id = NetworkGetNetworkIdFromEntity(personalvehicle2)
    SetNetworkIdCanMigrate(id, true)
    SetEntityCoords(personalvehicle2, spawnPos[1], spawnPos[2], spawnPos[3] + 1, spawnPos[4], 0, 0, 1)
    FreezeEntityPosition(GetPlayerPed(-1),false)
    SetEntityVisible(GetPlayerPed(-1),true)
    SetVehicleColours(personalvehicle2, colors[1], colors[2])
    SetVehicleExtraColours(personalvehicle2, extra_colors[1], extra_colors[2])
    TaskWarpPedIntoVehicle(GetPlayerPed(-1), personalvehicle2 ,-1)
    SetVehicleEngineOn(personalvehicle2,  true,  true)

-------------------------------  

    FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)),  true) -- Block player car
    SetVehicleDoorsLocked(GetVehiclePedIsUsing(GetPlayerPed(-1)), 4) -- Lock all door
    SetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetPlayerName(PlayerId())) -- Change plate by player name
    Wait(1000)
    TriggerServerEvent('hc:plyReady') -- Send to server that player is ready
    ready = true --Ready client side
    FadingIn(500)
    DrawMissionText("Waiting for ~h~~y~ other players~w~", 10000)
end)


--The server send "start" to players when all players are ready
RegisterNetEvent('hc:startRun')
AddEventHandler('hc:startRun', function()
    Citizen.Wait(500)
    N_0x10d373323e5b9c0d()
        if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
            if GetPlayerTeam(PlayerId()) == 1 then
                --blip large
            end
            FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)),  true) -- Block player car
            --Count down
            LastPress3 = GetGameTimer()
            CountDown3()
            Wait(1000)
            LastPress2 = GetGameTimer()
            CountDown2()
            Wait(1000)
            LastPress1 = GetGameTimer()
            CountDown1()
            Wait(1000)
            LastPressGo = GetGameTimer()
            CountDownGo()
            --LastPress1 = 0
            --LastPress2 = 0
            --LastPress3 = 0
            --LastPressGo = 0
            --Count down

            FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)),  false) -- Unlock player car
            SetPlayerWantedLevel(PlayerId(), 0, false) -- set wanted level
            SetPlayerWantedLevelNow(PlayerId(), false) -- apply wanted level now
            SetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetPlayerName(PlayerId())) -- Change plate by player name
            SetVehicleDoorsLocked(GetVehiclePedIsUsing(GetPlayerPed(-1)), 4) -- Lock door
            
            gameTimer = GetGameTimer() + 180000
            runInProgress = true
            inRun = true
        else
            TriggerEvent('chatMessage', '', { 0, 0, 0 }, "^2 Client: You're not in a car")
        end
end)

Citizen.CreateThread( function()
    while true do
        Wait(0)
         if IsPedFatallyInjured(PlayerPedId()) then
            if teamRunner then
                Wait(500)
                --EndScreen("Tu t'es fait eu!!", "DeathFailOut") --Determine l'ecran de fin
                --endScreen = true --Fait afficher l'ecran de fin
                inRun = false --Not "in run" anymore
                ready = false --Not ready anymore
                Wait(2500)
                TriggerServerEvent('hc:runnerDead') --Send toi server that player is dead
                Wait(1000)
                touch = 0
            elseif teamCop then
                Wait(500)
                inRun = false --Not "in run" anymore
                ready = false --Not ready anymore
                Wait(2500)
                TriggerServerEvent('hc:copDead')
            end
                --endScreen = false --arrete d'afficher l'ecran de fin
        end
    end
end)

Citizen.CreateThread( function()
    while true do
        Wait(0)
        if not inRun then
            FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)),  true) -- Block player car
        end
    end
end)


Citizen.CreateThread( function()
    while true do
        Wait(1000)
        if teamRunner then
            if inRun then
                TriggerServerEvent('hc:addTime')
            end
        end
    end
end)


Citizen.CreateThread( function()
	while true do
		Citizen.Wait(0)
        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        for i = 0, 31 do
			if NetworkIsPlayerActive( i ) then
				table.insert( players, i )
			end
		end
		if teamCop then --Cops
            for i = 0, 31 do
                if GetPlayerTeam(i) == 2 then
                    if GetPlayerPed(-1) ~= GetPlayerPed(i) then
                        if HasEntityBeenDamagedByEntity(GetVehiclePedIsUsing(GetPlayerPed(i)), GetVehiclePedIsUsing(GetPlayerPed(-1)), 1) then
                            srvId = GetPlayerServerId(i)
                            TriggerServerEvent('hc:damageRunner', srvId)
                            TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Touched! ')
                        end
                    end
                end
            end
            --AddBlipForRadius(GetEntityCoords(GetPlayerPed(-1), true), 500)      
        end 
    end
end)

RegisterNetEvent('hc:numOfPlayers')
AddEventHandler('hc:numOfPlayers', function(numOfPlayers)
    plyInGame = numOfPlayers
end)

RegisterNetEvent('hc:joinSpectate')
AddEventHandler('hc:joinSpectate', function()
    runInProgress = true
    inRun = false
    spectatePlayer()
end)

RegisterNetEvent('hc:endRun')
AddEventHandler('hc:endRun', function()
    ready = false
    runInProgress = false
    inRun = false
    --TriggerServerEvent('hc:newTeam')
end)

RegisterNetEvent('hc:runnerTouched')
AddEventHandler('hc:runnerTouched', function()
    touch = touch + 1
    if touch == 3 then
        Citizen.Wait(500)
        SetEntityHealth(GetPlayerPed(-1), 0)
        Citizen.Wait(1000)
        AddExplosion(GetEntityCoords(GetPlayerPed(-1)), 6, 0.5, true, false, 0.5)
    end
end)