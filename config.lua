NpcConfig = {

	showLine = true;
	
	distanceStream = 0,
	distanceStream_Qout = 600,
	distanceisLine = 1.5,
	
	speedType = {
		["stop"] = 0,
		["walk"] = 10,
		["run"]	= 50,
		["sprint"] = 80,
		["sprintfast"] = 100
	},

	typeNpc = {
		["Solo"] = {
			speed = "sprint",
		},
		["Bot"] = {
			speed = "sprintfast",
		},
		["Zombie"] = {
			speed = "walk",
		}
	},
	lineCheck = {
		{"center",0,0.3},
		{"left",-30,0.5},
		{"right",30,0.5},
		-- {"left",-85,-0.9},
		-- {"right",85,-0.9},
	},
	
	weapon_id = {
		["M4A1"] = { id_model = 1337 , ammo = 30 , id = 30 },
	},
	
}


function getRectangle ( x, y , size )
	return x - size, y - size, x + size, y + size
end

function isRectangle ( maxx , miny , zet , ped  , size )
	local x,y,z = getElementPosition( ped )
	if ( getDistanceBetweenPoints3D( maxx , miny , zet , x, y, z ) < size ) then
		return true
	end
	return false
end

function getRandomspeed ( )
	--  test
	local sppedAllType = {"walk","run","sprint","sprintfast"}

	local speed = "walk"
	return speed
end