local pr = 255
local pg = 255
local pb = 255

local function DrawPlayerList()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive( i ) then
            table.insert( players, i )
        end
    end
	
	--Top bar
	DrawRect( 0.11, 0.025, 0.2, 0.03, 0, 0, 0, 220 )
	
	--Top bar title
	SetTextFont( 4 )
    SetTextProportional( 0 )
    SetTextScale( 0.45, 0.45 )
    SetTextColour( 255, 255, 255, 255 )
    SetTextDropShadow( 0, 0, 0, 0, 255 )
    SetTextEdge( 1, 0, 0, 0, 255 )
    SetTextEntry( "STRING" )
    AddTextComponentString( "Players: " .. #players )
    DrawText( 0.015, 0.007 )
	
	for k, v in pairs( players ) do
		local r
		local g
		local b
		
		if k % 2 == 0 then
			r = 68
			g = 68
			b = 68
		else
			r = 74
			g = 74
			b = 74
		end
        if GetPlayerTeam(v) == 1 then
            pr = 0
            pg = 180
            pb = 255
        elseif GetPlayerTeam(v) == 2 then
            pr = 220
            pg = 0
            pb = 0
        end
		
		--Row BG
		DrawRect( 0.11, 0.025 + ( k * 0.03 ), 0.2, 0.03, r, g, b, 220 )
		
		--Name Label
		SetTextFont( 4 )
		SetTextScale( 0.45, 0.45 )
       
        SetTextColour( pr, pg, pb, 255 )
        SetTextEntry( "STRING" )
        AddTextComponentString( GetPlayerName( v ) )
        DrawText( 0.015, 0.007 + ( k * 0.03 ) )
		
		--Talk Indicator
		local transparency = 60
		
		if NetworkIsPlayerTalking( v ) then
			transparency = 255
		end
		
		DrawSprite( "mplobby", "mp_charcard_stats_icons9", 0.2, 0.024 + ( k * 0.03 ), 0.015, 0.025, 0, 255, 255, 255, transparency )
	end
end

--local LastPress = 0

Citizen.CreateThread( function()
	RequestStreamedTextureDict( "mplobby" )
    while true do
		Wait( 0 )
		DrawPlayerList()
	end
end )