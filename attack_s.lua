local self = {
	getTableAttack = {};
}

function self.getAttack ( npc)
	if client == source then
		local agressor = client or source

		self.getTableAttack[npc] = agressor
		npc:setData("npc_getAgressor",agressor)
	end
end
addEvent( "attackNpc", true )
addEventHandler ( "attackNpc" , root , self.getAttack )