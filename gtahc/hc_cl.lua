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

local insideGarage = { --1 x, y, z, vehicleHeading, pedHeading
    {x = -46.56327, y = -1097.382, z = 25.99875, vh = 228.2736, ph = 120.1953}, -- 1 Garage de base
    {x = 228.721, y = -993.374, z = -99.0, vh = 228.2736, ph = 120.1953}, -- 2 Garage Propre
    {x = 480.991, y = -1317.7, z = 29.2027, vh = 131.7264, ph = 120.1953}, -- 3 Garage Crade
    {x = -211.309, y = -1324.41, z = 30.8904, vh = 228.2736, ph = 120.1953}, -- 4 Garage fun
    {x = 436.441, y = -996.352, z = 25.7738, vh = 228.2736, ph = 120.1953}, -- 5 sous sol garage police
    {x = 449.511, y = -981.129, z = 43.6916, vh = 228.2736, ph = 120.1953}, -- 6 Toit police station
    {x = -75.1452, y = -818.625, z = 326.176, vh = 228.2736, ph = 120.1953}, -- 7 Toit du plus grand building de Vice City
    {x = 110.729, y = 6626.407, z = 31.787, vh = 228.2736, ph = 120.1953}, -- 8 Petit garage Custom - REPLACER
    {x = -1156.748, y = -2009.824, z = 13.180, vh = 228.2736, ph = 120.1953}, -- 9 Garage Custom moyen
    {x = 732.951, y = -1086.138, z = 22.168, vh = 228.2736, ph = 120.1953}, -- 10 Garage Pourrit Moyen
    {x = -334.172, y = -137.801, z = 39.009, vh = 228.2736, ph = 120.1953}, -- 11 Garage Custom moyen
    {x = 1175.404, y = 2640.987, z = 37.753, vh = 228.2736, ph = 120.1953}, -- 12 Petit garage Custom :p
    {x = -693.727, y = -757.278, z = 33.684, vh = 228.2736, ph = 120.1953} -- 13 Garage public (pour les flics?)
}

carList = {"polf430","pol718","polaven","polmp4","polp1","polgt500"}
runnersCarList = {"adder","banshee2","bullet","cheetah","entityxf","sheava","fmj","infernus","osiris","le7b","reaper","sultanrs","t20","turismor","tyrus","vacca","voltic","prototipo","zentorno"}


local num = 1 --Numero de la table des voitures (1 sur 17)
local carToShow = carList[num] --carToShow devient la voiture a prendre en compte

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
    if GetPlayerTeam(PlayerId()) == 1 then -- police ?
        inGar = insideGarage[13] -- changer ce nombre pour changer de garage
    elseif GetPlayerTeam(PlayerId()) == 2 then -- runner ?
        inGar = insideGarage[9] -- changer ce nombre pour changer de garage
    end
    --insideVeh = {-46.56327,-1097.382,25.99875, 228.2736} --coordonnée de l'interieur du garage, la 4eme est l'oriendtation de la voiture
    modelVeh = GetHashKey(car) --Le hashkey est necessaire pour generer la voiture a partir de son nom
    RequestModel(modelVeh) --Appel du model de la voiture
    while not HasModelLoaded(modelVeh) do -- tant que le model n'est pas chargé, ne pas continuer l'execution du code
        Citizen.Wait(0)
    end
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Nombre de joueurs: '..plyInGame )
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Model de vehicule Chargée' )
    personalvehicle = CreateVehicle(modelVeh ,inGar.x, inGar.y, inGar.z, inGar.vh, false, false) --Determiné la voiture a afficher, le 1er fasle permet de la rendre visible que pour le joueur qui l'a généré
    Citizen.InvokeNative(0xB736A491E64A32CF,Citizen.PointerValueIntInitialized(personalvehicle)) --Préparer la voiture a etre detruite des qu'elle sera hors de vue du joueur 
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Voiture choisie: '..modelVeh)
    SetVehicleOnGroundProperly(personalvehicle) --S'assure que la voiture soit posé normalement aui sol
    SetVehicleHasBeenOwnedByPlayer(personalvehicle,true) --Permet au joueur de la demarrer de suite, ou d'entrer dedans sans la braquer
    local id = NetworkGetNetworkIdFromEntity(personalvehicle) --Aucune idée, mais necessaire a ce que j'ai comprius
    SetNetworkIdCanMigrate(id, true) --Aucune idée, mais necessaire a ce que j'ai comprius
--    TaskWarpPedIntoVehicle(GetPlayerPed(-1), personalvehicle ,-1)
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
            if IsControlJustPressed(1,190) and plyRun < #players then --Fleche droite
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

            if IsControlJustPressed(1,189) and plyRun > 0 then --Fleche gauche
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


RegisterNetEvent('hc:setTeamCop')
AddEventHandler('hc:setTeamCop', function()
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 team: cop')
    SetPlayerTeam(PlayerId(),  1)
    teamRunner = false
    teamCop = true
end)

RegisterNetEvent('hc:setTeamRunner')
AddEventHandler('hc:setTeamRunner', function()
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 team: runner')
    SetPlayerTeam(PlayerId(),  2)
    teamRunner = true
    teamCop = false

end)


RegisterNetEvent('hc:selectCar')
AddEventHandler('hc:selectCar', function()
    
    endScreen = false
    if GetPlayerTeam(PlayerId()) == 1 then -- police ?
        carList = {"polf430","pol718","polaven","polbuga","polmp4","polp1","polgt500"}
        ShowCar(carList[num]) --la 1ere voiture qui va apparaitre, defini tout en haut de cette page de code
    elseif GetPlayerTeam(PlayerId()) == 2 then -- runner ?
        carList = {"adder","banshee2","bullet","cheetah","entityxf","sheava","fmj","infernus","osiris","le7b","reaper","sultanrs","t20","turismor","tyrus","vacca","voltic","prototipo","zentorno"}
        ShowCar(carList[num])
    end
    FadingIn(1000)

    SetEntityHealth(GetPlayerPed(-1), 200)
    while true do
        Citizen.Wait(0)

        if not ready then

            --Choix de la voiture
            if IsControlJustPressed(1,190) and num < #carList then --Fleche droite
                SetModelAsNoLongerNeeded(personalvehicle) --Préparer la voiture a etre detruite
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle)) -- fais disparaitre la voiture
                num = num + 1 
                carToShow = carList[num]
                ShowCar(carToShow)
            end

            if IsControlJustPressed(1,189) and num > 1 then --Fleche gauche
                SetModelAsNoLongerNeeded(personalvehicle)
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle))
                num = num - 1
                carToShow = carList[num]
                ShowCar(carToShow)
            end

            --Affichage de la couleur de la voiture
            if IsControlJustPressed(1,188) then --Fleche haut
                SetModelAsNoLongerNeeded(personalvehicle) --Préparer la voiture a etre detruite
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle)) -- fais disparaitre la voiture
                ShowCar(carToShow)
            end

            if IsControlJustPressed(1,187) then --Fleche bas
                SetModelAsNoLongerNeeded(personalvehicle)
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle))
                ShowCar(carToShow)
            end

        --Tant que rien n'est validé, afficher la voiture
            if IsControlJustPressed(1,201) and plyInGame > 1 then -- 201 correspond a "Valider" soit "Enter" ou "A" sur une manette
                modelVeh = GetHashKey(carToShow)
                FadingOut(500)
                Wait(500)
                ready = true --passe le joueur en pret
                TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Entrer Validé')
                SetModelAsNoLongerNeeded(personalvehicle) --Préparer la voiture a etre detruite
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(personalvehicle)) --detruit la voiture dans le magasin
                Wait(500)
                TriggerServerEvent('hc:carSelected') --Envoie au serveur que la voiture a ete choisie
            else
                FreezeEntityPosition(GetPlayerPed(-1),true) --paralyse le joueur
                SetEntityVisible(GetPlayerPed(-1),false) --le rend invisible
                SetEntityCoords(personalvehicle, inGar.x, inGar.y, inGar.z,1,0,0,1)-- TP la voiture a cet entroit
                SetEntityHeading(GetPlayerPed(-1),inGar.ph) -- L'endroit ou le joueur regarde a ce momet la
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
        carToShow = carList[num] --la 1ere voiture qui va apparaitre, defini tout en haut de cette page de code
    elseif GetPlayerTeam(PlayerId()) == 2 then -- runner ?
        carList = {"adder","banshee2","bullet","cheetah","entityxf","sheava","fmj","infernus","osiris","le7b","reaper","sultanrs","t20","turismor","tyrus","vacca","voltic","prototipo","zentorno"}
        carToShow = carList[num]
    end
    modelVeh = GetHashKey(carToShow) --Le hashkey est necessaire pour generer la voiture a partir de son nom
    ---------------------------------- fait apparaitre la voiture choisie en visible pour tout le monde et TP le joueur a l'interieur
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^2 Client: carToShow: '..carToShow )
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^2 Client: Position d arrivée: '..spwNum )
    RequestModel(modelVeh)
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Model requesté: '..modelVeh )
    while not HasModelLoaded(modelVeh) do
        Citizen.Wait(0)
    end
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Model de vehicule Chargée' )
    personalvehicle = CreateVehicle(modelVeh ,spawnPos[1], spawnPos[2], spawnPos[3], 228.2736, true, false)

    TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Client: Voiture choisie: '..modelVeh)

    SetVehicleOnGroundProperly(personalvehicle)
    SetVehicleHasBeenOwnedByPlayer(personalvehicle,true)
    local id = NetworkGetNetworkIdFromEntity(personalvehicle)
    SetNetworkIdCanMigrate(id, true)
    SetEntityCoords(personalvehicle,spawnPos[1],spawnPos[2],spawnPos[3] + 1, 1, 0, 0, 1)
    FreezeEntityPosition(GetPlayerPed(-1),false)
    SetEntityVisible(GetPlayerPed(-1),true)
    SetVehicleColours(personalvehicle, colors[1], colors[2])
    SetVehicleExtraColours(personalvehicle, extra_colors[1], extra_colors[2])
    TaskWarpPedIntoVehicle(GetPlayerPed(-1), personalvehicle ,-1)
    SetVehicleEngineOn(personalvehicle,  true,  true)

-------------------------------  

    FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)),  true) -- Bloque la voiture du joueur
    SetVehicleDoorsLocked(GetVehiclePedIsUsing(GetPlayerPed(-1)), 4) -- Verouille les portes pour que le joueur ne puisse plus sortir de la voiture
    SetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetPlayerName(PlayerId())) -- Met le pseudo du joueur comme plaque d'immatriculation
    TriggerServerEvent('hc:plyReady') -- Envoie au serveur que le joueur est pret
    ready = true --Pret
    FadingIn(500)
    DrawMissionText("Waiting for ~h~~y~ other players~w~", 10000)
end)


--Le serveur envoie le top depart quand tous les joueurs sont pret
RegisterNetEvent('hc:startRun')
AddEventHandler('hc:startRun', function()
    Citizen.Wait(500)
    --enlever l'image du chargement
    N_0x10d373323e5b9c0d()
        if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
            if GetPlayerTeam(PlayerId()) == 1 then
                --blip large
            end
            FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)),  true) -- Bloque la voiture du joueur
--Compte a rebours
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
--Compte a rebours

            FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)),  false) -- Débloque la voiture du joueur
            SetPlayerWantedLevel(PlayerId(), wantedLevel, false) -- Met le niveau de recherche à 5
            SetPlayerWantedLevelNow(PlayerId(), false) -- Applique le niveau de recherche maintenant
            SetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetPlayerName(PlayerId())) -- Met le pseudo du joueur comme plaque d'immatriculation
            SetVehicleDoorsLocked(GetVehiclePedIsUsing(GetPlayerPed(-1)), 4) -- Verouille les portes pour que le joueur ne puisse plus sortir de la voiture
            
            gameTimer = GetGameTimer() + 180000
            runInProgress = true
            inRun = true

        else
            TriggerEvent('chatMessage', '', { 0, 0, 0 }, "^2 Client: t'es pas dans une voiture")
        end

end)

Citizen.CreateThread( function()
    while true do
        Wait(0)
        if teamRunner then
            if IsPedFatallyInjured(PlayerPedId()) then
                Wait(500)
                --EndScreen("Tu t'es fait eu!!", "DeathFailOut") --Determine l'ecran de fin
                --endScreen = true --Fait afficher l'ecran de fin
                inRun = false --met le joueur en mode "plus dans la course"
                ready = false --il n'est plus pret non plus
                Wait(2500)
                TriggerServerEvent('hc:runnerDead') --envoie au serveur que le joueur est mort
                Wait(1000)
                touch = 0
                --endScreen = false --arrete d'afficher l'ecran de fin
            end
        end
    end
end)

Citizen.CreateThread( function()
    while true do
        Wait(0)
        if teamRunner then
            if inRun then
                if gameTimer == GetGameTimer() then
                    TriggerServerEvent('hc:runnerWon')
                    touch = 0
                    inRun = false --met le joueur en mode "plus dans la course"
                    ready = false --il n'est plus pret non plus
                end
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
                            TriggerEvent('chatMessage', '', { 0, 0, 0 }, '^1 Touché! '..srvId)
                        end
                    end
                end
            end
            --AddBlipForRadius(GetEntityCoords(GetPlayerPed(-1), true), 500)      
        elseif teamRunner then --Runners
            if touch == 3 then
                Citizen.Wait(5000)
                ExplodeVehicle(GetVehiclePedIsUsing(GetPlayerPed(-1)), true, true)
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
    TriggerServerEvent('hc:newTeam')
end)

RegisterNetEvent('hc:runnerTouched')
AddEventHandler('hc:runnerTouched', function()
    touch = touch + 1
    if touch == 3 then 
        Wait(2000)
        AddExplosion(GetEntityCoords(GetPlayerPed(-1)), 6, 0.5, true, false, 0.5)
    end
end)