local self = {
	getTableAttack = {}; -- таблица хранения , тех кто стрелял в нпс
}

-- Если по НПС начали стрелять
function self.getAttackNpc( attacker, weapon, bodypart, loss )
	if getElementType ( source ) == "ped" then
		if attacker and attacker == localPlayer then
			if not self.getTableAttack[npc] then 
				return self.tableAttack ( source , localPlayer )
			end
		end
	end
end

-- Заполняем данные тех , кто стрелял в НПС
function self.tableAttack ( npc , agressor )
	if npc and isElement( npc ) and agressor then
		if self.getTableAttack[npc] ~= agressor then
			self.getTableAttack[npc] = agressor
			triggerServerEvent ( "attackNpc" , localPlayer , npc )
			outputChatBox( "Attack npc " .. tostring ( npc ) )
			setPedControlState ( npc , "forwards" , false )
		end
	end
end

function self.updAttack  ( npc , x , y , z )
	if assert ( { npc , x , y , z } ) then
		local sx,sy,sz = getElementPosition(npc)
		x,y,z = x-sx,y-sy,z-sz
		local yx,yy,yz = 0,0,1
		local xx,xy,xz = yy*z-yz*y,yz*x-yx*z,yx*y-yy*x
		yx,yy,yz = y*xz-z*xy,z*xx-x*xz,x*xy-y*xx
		-- local inacc = 1-getNPCWeaponAccuracy(npc)
		local inacc = 6
		local ticks = getTickCount()
		local xmult = inacc*math.sin(ticks*0.01 )*1000/math.sqrt(xx*xx+xy*xy+xz*xz)
		local ymult = inacc*math.cos(ticks*0.011)*1000/math.sqrt(yx*yx+yy*yy+yz*yz)
		local mult = 1000/math.sqrt(x*x+y*y+z*z)
		xx,xy,xz = xx*xmult,xy*xmult,xz*xmult
		yx,yy,yz = yx*ymult,yy*ymult,yz*ymult
		x,y,z = x*mult,y*mult,z*mult
		
		setPedAimTarget(npc,sx+xx+yx+x,sy+xy+yy+y,sz+xz+yz+z)
		if isPedInVehicle(npc) then
			setPedControlState(npc,"vehicle_fire",not getPedControlState(npc,"vehicle_fire"))
		else
			setPedControlState(npc,"aim_weapon",true)
			setPedControlState(npc,"fire",not getPedControlState(npc,"fire"))
		end
	end
end

-- обрабатываем действия НПС
function self.updData ( )
	for a,v in ipairs ( getElementsByType("ped",root, true ) ) do
		local agressor = v:getData("npc_getAgressor") or false
		if v:getData("npc_ped") and agressor then
			-- setPedAimTarget( ped thePed, float x, float y, float z )
			local x,y,z = getElementPosition(agressor)
			local vx,vy,vz = getElementVelocity(agressor)
			local tgtype = getElementType(agressor)
			if ( agressor_type == "ped" or agressor_type == "player" ) then
				x,y,z = getPedBonePosition(agressor,3)
				local vehicle = getPedOccupiedVehicle(agressor)
				if vehicle then
					vx,vy,vz = getElementVelocity(vehicle)
				end
			end
			vx,vy,vz = vx*6,vy*6,vz*6
			self.updAttack ( v , x + vx , y + vy , z + vz )
		end
	end
end

addEventHandler ( "onClientPedDamage", getRootElement(), self.getAttackNpc )
addEventHandler ( "onClientRender", getRootElement(), self.updData )