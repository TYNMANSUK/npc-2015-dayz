Npc = {
	
	streamedState = {};
	check_cob = true;
		
	isSpawnNpc = function ()
		for i,v in ipairs(getElementsByType ( "ped", root, true )) do
			Npc.streamedState[v] = isPedDucked(v)
		end
		addEventHandler("onClientRender",root,Npc.typeBotSensy)
		
		addEventHandler( "onClientElementStreamIn",root,
			function()
				if getElementType(source) == "ped" then
					if source:getData("npc_ped") then
						Npc.streamedState[source] = isPedDucked(source)
						triggerServerEvent("isElementStreamIn",root,source)
					end
				end
			end
		)


		addEventHandler( "onClientElementStreamOut",root,
			function()
				if getElementType(source) == "ped" then
					if source:getData("npc_ped") then
						Npc.streamedState[source] = nil
						triggerServerEvent("isElementStreamOut",root,source)
					end
				end
			end
		)
	end;
	
	typeBotSensy = function ( )
		local x,y,z = 0,0,3
		local maxtime = 2
		for i,npc in ipairs( getElementsByType("ped",root, true ) ) do
		
			Npc.check_cob = {}
			
			if not npc:getData("npc_ped") then
				return
			end
			
			local zx,zy,zz = getElementPosition(npc)
			
			if npc:getData("npc_random_pos") then
				local zx_,zy_,zz_ = unpack ( npc:getData("npc_spawn_start") )
				local size = tonumber ( npc:getData("npc_random_pos_size") )
				local minX, minY, maxX, maxY = getRectangle( zx_,zy_,size )
				
				Npc.check_cob[npc] = isRectangle ( zx_ , zy_ , zz_ , npc , size )
				if NpcConfig.showLine then
					local color = Npc.check_cob[npc] ~= true and tocolor(255,0,0) or tocolor(255,255,255)
					dxDrawLine3D( minX, minY, zz_, maxX, minY, zz_, color, 5 )
					dxDrawLine3D( minX, minY, zz_, minX, maxY, zz_, color, 5 )
					dxDrawLine3D( maxX, maxY, zz_, minX, maxY, zz_, color, 5 )
					dxDrawLine3D( maxX, maxY, zz_, maxX, minY, zz_, color, 5 )
					-- dxDrawText(tostring(Npc.check_cob[npc]),20,220)
				end
			end
			-- отрисовка линии путей
			if NpcConfig.showLine then
				local table_pos = npc:getData("npc_tack_table_pos") or false
				if table_pos then
					for a,v in ipairs ( table_pos ) do
						local x1,y1,z1 = unpack ( table_pos[a] )
						if table_pos[a + 1] then
							local x2,y2,z2 = unpack ( table_pos[a + 1] )
							dxDrawLine3D(x1,y1,z1,x2,y2,z2,tocolor(255,255,255),3)
						end
					end
				end
			end
			
			if npc:getData("npc_dead") then return end
			if npc:getData("npc_getAgressor") then return end
			
			local type_Npc = npc:getData("npc_type") or "Solo"
			if type_Npc and NpcConfig.typeNpc[type_Npc] then
				local speed = npc:getData("npc_speed") or "walk"
				local tack = npc:getData("npc_tackPos") or false
				if tack then
					local px,py,pz = tack[1],tack[2],tack[3]
					local rot_z = math.deg(math.atan2(px-zx,py-zy))
					local isclear,rotPl = Npc.isLinePosition(zx, zy, zz,rot_z)
					if not isclear and speed ~= "stop" and NpcConfig.speedType[speed] then
						setPedControlState(npc,"forwards",true)
						setPedControlState(npc,speed,true)
						makeNPCWalkToPos(npc,px,py,pz,getGameSpeed())
						setPedControlState(npc,"left",false)
						setPedControlState(npc,"right",false)
					else
						if isclear and isclear ~= "center" and rotPl then
							setPedControlState(npc,"forwards",true)
							setPedControlState(npc,isclear,true)
							setElementRotation (npc, 0, 0, - rot_z - rotPl, 'default', true)
						elseif isclear and isclear == "center" and ( rotPl or rotPl == 0 ) then
							-- setPedControlState(npc,"forwards",true)
							setPedControlState(npc,"jump",true)
							setPedControlState(npc,"left",false)
							setPedControlState(npc,"right",false)
						else
							setPedControlState(npc,"forwards",false)
						end
					end
					if npc and tack and getDistanceBetweenPoints3D(zx,zy,zz,px,py,pz) <= 1 then
						
						if npc:getData("npc_tack_start") then
							npc:setData("npc_tack_start",false)
							return
						end
						if npc:getData("npc_random_pos_tick") and Npc.check_cob[npc] then
							npc:setData("npc_random_pos_tick",false)
							return
						end
						
						npc:setData("npc_tackPos",false)
						setPedControlState(npc,"forwards",false)
						
					end				
				end
			end
		end
		for player,wasDucked in pairs(Npc.streamedState) do
			if isElement(player) then
				local isDucked = isPedDucked(player)
				if wasDucked ~= isDucked then
					-- If he's just stood up
					if (wasDucked) and (not isDucked) then
						-- He has to be aiming
						if isPedDoingTask(player,"TASK_SIMPLE_USE_GUN") then
							-- And moving in some direction
							if  	( getPedAnalogControlState ( player, "forwards" ) ~= 0 )
								or	( getPedAnalogControlState ( player, "backwards" )  ~= 0 ) 
								or  ( getPedAnalogControlState ( player, "left" ) ~= 0 )
								or  ( getPedAnalogControlState ( player, "right" ) ~= 0 ) then
								
								setElementPosition ( player, getElementPosition(player) )
							end
						end
					end
					Npc.streamedState[player] = isDucked
				end
			end
		end
	end;
	
	isLinePosition = function (x,y,z,rot)
		local rat = false
		local rotP = 0
		for a,v in ipairs ( NpcConfig.lineCheck ) do
			local x1,y1,z1 = x - math.sin(math.rad(-rot + v[2])) * ( NpcConfig.distanceisLine + v[3] ), y + math.cos(math.rad(-rot + v[2])) * ( NpcConfig.distanceisLine + v[3] ), z
			if not isLineOfSightClear (x,y,z,x1,y1,z1, true, true, true, true, false, false, false) then
				rat = v[1]
				rotP = v[2]
				break
			end
			if NpcConfig.showLine then
				dxDrawLine3D(x,y,z,x1,y1,z1,tocolor(255,255,255),1)
			end
		end
		return rat,rotP
	end;
	

	
}
addEventHandler("onClientResourceStart",resourceRoot,Npc.isSpawnNpc)

function makeNPCWalkToPos(npc,x,y,z,maxtime)
	if not isElement (npc) then return maxtime end
	local px,py,pz = getElementPosition(npc)
	local typeSpeed = npc:getData("npc_speed") or false
	local speed = 1.5559
	if typeSpeed and NpcConfig.speedType[typeSpeed] then
		speed = ( 12.281 *  NpcConfig.speedType[typeSpeed] / 100 )
	end
	local walk_dist = speed * maxtime * 0.001
	local dx,dy,dz = x-px,y-py,z-pz
	local dist = getDistanceBetweenPoints3D(0,0,0,dx,dy,dz)
	dx,dy,dz = dx/dist,dy/dist,dz/dist
	local maxtime_unm = maxtime
	if dist < walk_dist then
		maxtime = maxtime*dist/walk_dist
		walk_dist = dist
	end
	local model = getElementModel(npc)
	x,y,z = px+dx*walk_dist,py+dy*walk_dist,pz+dz*walk_dist
	local rot = -math.deg(math.atan2(dx,dy))
	if x and y and z and rot and type(x) == "number" and type(y) == "number" and type(z) == "number" and type(rot) == "number" then
		setElementPosition(npc,x,y,z,false)
		setElementRotation (npc, 0, 0, rot, 'default', true)
		return maxtime
	else
		setElementPosition(npc,px,py,pz,false)
		setElementRotation (npc, 0, 0, getPedRotation(npc), 'default', true)
		return maxtime_unm
	end
end

function bindpos ()
	local x,y,z = getElementPosition(localPlayer)
	outputChatBox("{"..x..","..y..","..z.."},")
end
bindKey("1","down",bindpos)
