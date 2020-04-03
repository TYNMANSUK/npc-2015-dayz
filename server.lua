
addEvent("isElementStreamIn",true)
addEvent("isElementStreamOut",true)

Npc = {

	AssemblyCol = {};
	DeadNpc = {};
	time_npc = {};
	getStreamWeapon= {};
	
	worldToMap = function ( x , y , radius , angle )
		local a = math.rad(90 - angle);
		local dx = math.cos(a) * radius;
		local dy = math.sin(a) * radius;
		return x + dx, y + dy
	end;
	
	ElementNpc = {
		{"npc_ped",true},
		{"npc_tackPos",false},
		{"npc_tack",false},
		{"npc_tack_value",false},
		{"npc_tack_table_pos",false},
		{"npc_tack_start",false},
		{"npc_spawn_start",false},
		{"npc_respawn",false},
		{"npc_dead",false},
		{"npc_respawn_time",0},
		{"npc_random_pos",false},
		{"npc_random_pos_tick",false},
		{"npc_random_pos_size",false},
		{"npc_tack_value_max",false};
		{"ncp_getWeaopn_settings",false};
		{"npc_getAgressor",false};
		{"npc_pos_tisk",100}};
	
	create = function (x,y,z)
		if assert ( { y, z } ) then
			-- x,y,z = 0,0,0
		end
		-- создаем НПС
		local ped = createPed ( 0 , x , y , z , math.random ( 0 , 360 ) )
		if not ped and isElement(ped) then
			return false
		end
		-- загружаем НПС в базу и выдаем дефолтные задачи.
		Npc.setStatus ( ped , "stopping" )
		Npc.setType ( ped , "stopping" )
		for a,v in ipairs ( Npc.ElementNpc ) do
			ped:setData ( v[1] , v[2] )
		end
		ped:setData ( "npc_spawn_start" , { x , y, z } )
		addEventHandler("onElementDataChange",ped,Npc.isGetDataNpc)
		addEventHandler("onPedWasted",ped,Npc.isPedDead)
		return ped
	end;
	
	-- установить новую задачу ( статус )
	setStatus = function ( npc , meanings )
		if npc and isElement(npc) then
			-- дабы избежать сбоя статуса НПС,делаем проверку на одинаковый статус
			-- outputChatBox("NPC SET NEW STATUS - "..meanings.. " old status - " .. tostring(npc:getData("npc_status")))
			if meanings ~= npc:getData("npc_status") then
				npc:setData("npc_status",meanings)
			end
		end
	end;
	
	-- установить тип нпс
	setType = function ( npc , type )
		if npc and isElement(npc) then
			if NpcConfig.typeNpc[type] then
				npc:setData("npc_type",type)
				local speed = NpcConfig.typeNpc[type].speed
				npc:setData("npc_speed",speed)
			end
		end
	end;
	
	get = function ( npc )
		if npc and isElement(npc) then
			
		end
	end;
	
	setSpeed = function ( npc , speed )
		if npc and isElement(npc) then
			if NpcConfig.speedType[speed] then
				npc:setData("npc_speed",speed)
			end
		end
	end;
	
	setPos = function(npc,x,y,z)
		if npc and isElement(npc) then
			npc:setData("npc_tackPos",{x,y,z})
		end
	end;	
	
	setPosTable = function(npc,table_pos)
		if npc and isElement(npc) and table_pos then
			local value = 1
			if table_pos[value] then
				local x,y,z = unpack ( table_pos[ value ] )
				Npc.setPos ( npc , x , y, z  )
				npc:setData("npc_tack_start",true)
				npc:setData("npc_tack_value",value)
			end
			npc:setData("npc_tack_value",value)
			npc:setData("npc_tack_value_max",#table_pos)
			npc:setData("npc_tack_table_pos",table_pos)
			npc:setData("npc_tack",true)
		end
	end;
	
	setPosRectangle = function(npc,size)
		if npc and isElement(npc) then
			local x,y,z = unpack ( npc:getData("npc_spawn_start") )
			-- local x,y,z = getElementPosition ( npc )
			local x,y = Npc.worldToMap( x , y , size , getPedRotation( npc ) - 90 )
			Npc.setPos ( npc , x , y, z  )
			npc:setData("npc_random_pos",true)
			npc:setData("npc_tack",true)
			npc:setData("npc_random_pos_tick",true)
			npc:setData("npc_random_pos_size",size)
		end
	end;
	
	setPosTick = function ( npc , time )
		if npc and isElement(npc) then
			if time < 1 then
				time = 50
			end
			npc:setData("npc_pos_tisk", time * 1000 )
		end
	end;
	
	
	setWeapon = function ( npc , wp , ammo )
		if npc and isElement(npc) then
			if NpcConfig.weapon_id[wp] then
				local name_weapon = wp
				local ammo_weapon = ammo or 0
				local reload_weapon =  ammo and true or false
				
				npc:setData("ncp_getWeaopn_settings",{ name_weapon , ammo_weapon ,reload_weapon } )
				
				outputChatBox("give weapon npc:")
				outputChatBox("Wp name "..tostring ( name_weapon) )
				outputChatBox("Wp ammo "..tostring ( ammo_weapon) )
				outputChatBox("Wp reload "..tostring (reload_weapon) )
				outputChatBox("_")
				giveWeapon ( npc, NpcConfig.weapon_id[wp].id, 1, true )
				-- Npc.getStreamWeapon
			end
		end
	end;
	
	isGetDataNpc = function ( dataName )
		if not isElement( source ) or getElementType( source ) ~= "ped" then
			return
		end
		if dataName == "npc_tack_start" then
			if source:getData("npc_tack") then
				local time = tonumber ( source:getData("npc_pos_tisk") )
				if not isTimer(Npc.time_npc[source]) then
					Npc.time_npc[source] = setTimer(function(source)
						local value = source:getData("npc_tack_value") or false
						local value_max = source:getData("npc_tack_value_max") or false
						if value and value_max then
							if value >= value_max then value = 0 end					
							value = tonumber ( value ) + 1
							-- outputChatBox("Value - "..tostring(value).." max value - "..tostring(value_max))
							local table_pos = source:getData("npc_tack_table_pos")
							-- outputChatBox("table - "..tostring(table_pos))
							if table_pos[value] then
								local x,y,z = unpack ( table_pos[ value ] )
								Npc.setPos ( source , x , y, z  )
								source:setData("npc_tack_start",true)
								source:setData("npc_tack_value",value)
							end
							-- outputChatBox( tostring ( value ))
						end
					end,time,1,source)
				end
			end
		elseif dataName == "npc_random_pos_tick" then
			if source:getData("npc_tack") then
				local time = tonumber ( source:getData("npc_pos_tisk") )
				if not isTimer(Npc.time_npc[source]) then
					Npc.time_npc[source] = setTimer(function(source)
						local size = source:getData("npc_random_pos_size") or 5
						Npc.setPosRectangle(source,size)
						-- outputChatBox("random")
						killTimer(Npc.time_npc[source])
						Npc.time_npc[source] = nil
					end,time,1,source)
				end
			end
			-- outputChatBox(tostring(dataName))

		end
	end;
	
	isPedDead = function ( )
		if not isElement( source ) or getElementType( source ) ~= "ped" then
			return
		end
		-- outputChatBox("Dead NPc" .. tostring ( source ) )
		removeEventHandler("onElementDataChange",source,Npc.isGetDataNpc)
		removeEventHandler("onPedWasted",source,Npc.isPedDead)
		if source:getData("npc_respawn") then
			local time = tonumber ( source:getData("npc_respawn_time") * 1000 )
			if time > 0 then
				killPed(  source )
				source:setData("npc_dead",true)
				-- outputChatBox("Dad Npc - respawn time - " .. tostring(time) .. " secund ")
				if not isTimer(Npc.DeadNpc[source]) then
					Npc.DeadNpc[source] = setTimer ( function ( source )
						setElementHealth(source,100)
						-- outputChatBox("respawn Npc!!!")
						Npc.DeadNpc[source] = nil
						source:setData("npc_dead",false)
						source:setData("npc_getAgressor",false)
					end,time,1,source)
					return
				end
			end
		end
		for a,v in ipairs ( Npc.ElementNpc ) do
			source:removeData ( v[1]  )
		end
		source:destroy()
		-- outputChatBox("remove NPc" .. tostring ( source ) )
	end;	
	
	respawn = function ( npc , time )
		if npc and isElement(npc) then
			local timer_spawn = time or 10
			npc:setData("npc_respawn",true)
			npc:setData("npc_respawn_time",time)
		end
	end;
		
	isElementStreamIn = function ( npc )
		if npc:getData("npc_tack_start") then
			local table_pos = npc:getData("npc_tack_table_pos")
			local value = math.random ( 1 , #table_pos )
			if table_pos[value] then
				local x,y,z = unpack ( table_pos[ value ] )
				npc:setPosition(x,y,z)
			end
		elseif not npc:getData("npc_tack_start") and npc:getData("npc_spawn_start") then
			local x,y,z = unpack ( npc:getData("npc_spawn_start") )
			npc:setPosition(x,y,z)
		end
		npc:setAlpha(255)
		npc:setFrozen(false)
	end;
	
	isElementStreamOut = function ( npc )
		-- outputChatBox("isElementStreamOut - "..tostring(npc))
		npc:setAlpha(0)
		npc:setFrozen(true)
	end;
	
}

addEventHandler("isElementStreamIn",root,Npc.isElementStreamIn)
addEventHandler("isElementStreamOut",root,Npc.isElementStreamIn)