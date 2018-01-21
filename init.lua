local chathelp = {}

-- Options for Print_Message
local log = 0
local green = '#00FF00'
local red = '#FF0000'
local orange = '#FF6700'
local none = 99
local spawnpoint = minetest.setting_get("static_spawnpoint") or "" -- Position as String for Spawn

-- Registered Commands for Chathelp

minetest.register_chatcommand("who", {
    params = "",
    description = "List all connected players.",
    func = function(name)
		chathelp.who(name)
 
    end

})

minetest.register_chatcommand("where_is", {
    params = "Playername",
    description = "Show's the Position of the Player.",
    func = function(name, playername)
		chathelp.where(name, playername)
		
    end

})

minetest.register_chatcommand("what_is", {
    params = "Playername",
    description = "Show's Information about the Item.",
    func = function(name, playername)
		chathelp.show_item(name)
		
    end

})

minetest.register_chatcommand("show_ip", {
    params = "Playername",
    description = "Show's the IP of the Player.",
    privs = {server = true},
    func = function(name, playername)
		chathelp.show_ip(name, playername)
		
    end

})

--[[
minetest.register_chatcommand("show_me", {
    params = "",
    description = "Show's Information about the pointed Item.",
    func = function(name)
		chathelp.show_me(name)
		
    end

})
--]]

minetest.register_chatcommand("bring", {
    params = "Playername",
    description = "Teleports to Player.",
    privs = {server = true},
    func = function(name, playername)
		chathelp.teleport_to(name, playername)
		
    end

})

minetest.register_chatcommand("summon", {
    params = "Playername",
    description = "Summons a Player.",
    privs = {server = true},
    func = function(name, playername)
		chathelp.summon(name, playername)
		
    end

})

minetest.register_chatcommand("set_hp", {
    params = "Playername, Hitpoints",
    description = "Set's the HP of a Player.",
    privs = {server = true},
    func = function(name, arg)
		chathelp.set_hp(name, arg)
		
    end

})

minetest.register_chatcommand("add_hp", {
    params = "Playername, Hitpoints",
    description = "Adds Hitpoints to a Player.",
    privs = {server = true},
    func = function(name, arg)
		chathelp.add_hp(name, arg)
		
    end

})

minetest.register_chatcommand("sub_hp", {
    params = "Playername, Hitpoints",
    description = "Removes Hitpoints to a Player.",
    privs = {server = true},
    func = function(name, arg)
		chathelp.sub_hp(name, arg)
		
    end

})
minetest.register_chatcommand("get_hp", {
    params = "Playername",
    description = "Shows the Hitpoints to a Player.",
    func = function(name, playername)
		chathelp.get_hp(name, playername)
		
    end

})

minetest.register_chatcommand("spawn", {
    params = "Playername",
    description = "Moves you to Spawn.",
    privs = {interact = true},
    func = function(name)
		if(spawnpoint ~= "") then
			local player = minetest.get_player_by_name(name)
			player:setpos(minetest.string_to_pos(spawnpoint))
	
		else
			chathelp.print(name, "No Spawnpoint set, contact the Admin.", red)
		
		end
    end

})
-- Commands for chathelp

-- who - Shows you all Players are online.
function chathelp.who(name)

        connected_players_string = 'Players online: '
 
        for _,player in ipairs(minetest.get_connected_players()) do
            connected_players_string  =  connected_players_string .. 
                                         player:get_player_name() .. 
                                         ','
        end -- for _,player
 
	chathelp.print(name, connected_players_string, green)
	--minetest.chat_send_player(name, connected_players_string)
 
        return true

end -- who()

-- whereis searches for the Player, if the Player is online, 
-- it show's you the current Coordinates of the Playername.

function chathelp.where(name, playername)

	-- empty or invalid Nameparameter?
	if(not chathelp.check_name) then
		chathelp.print(name, "Invalid Playername \"\" or nil", red)
		return
		
	end -- (if(check_name)
	
	if(not chathelp.player_exists(playername)) then
		chathelp.print(name, "Player " .. playername .. " are unknown.", red)
		return

	end -- if(minetest.player_exists)
	
	if(not chathelp.is_online(playername)) then
		chathelp.print(name, "Player " .. playername .. " is not online.", red)
		return

	end -- if(is_online
	
	-- GetPlayerobject
	local player = minetest.get_player_by_name(playername)
		
	-- all ok, get Position and report it
	local pos = minetest.pos_to_string(player:getpos())
	chathelp.print(name, "You can find Player: " .. playername .. " at Pos: " .. pos, green)
	
end -- whereis()

-- check_online(name) returns true, if the given playername is online
function chathelp.is_online(name)
	
	for _,player in ipairs(minetest.get_connected_players()) do
            if name == player:get_player_name() then
                return true

            end -- if(name == player.get_name()
	    
	end -- for _,player
	
	-- Player is not online
	return false

end -- is_online()

-- check if player is known? false = unknown
function chathelp.player_exists(name)
	-- is the player in auth.txt?
	if(minetest.player_exists(name)) then 
		return true  -- yeahh, found
		
	end -- if(player_exists)
	
	return false -- not found, Player unknown
	
end -- player_exists()

-- check_name, returns true, if the name is valid
function chathelp.check_name(name)

	if(name == "" or name == nil) then
		return false
		
	end
	
	return true

end -- check_name()

-- Shows the IP of a Player, need Server-Priv
function chathelp.show_ip(name, playername)
	
	if( chathelp.is_online(playername) ) then
		local ip = minetest.get_player_ip(playername)
		chathelp.print(name, "The IP from " .. playername .. " is: " .. ip, green)
		
	else
		if( chathelp.player_exists(playername) )then
			chathelp.print(name, "The Player " .. playername .. " isn't online.", orange)
			
		else
			chathelp.print(name, "Player " .. playername .. " is unknown.", red)
			
		end -- if(player_exist)
		
	end -- if(player_is_online)
	
end -- chathelp.show_ip()

-- Shows Information about an Item you held in the Hand
function chathelp.show_item(name)
	
	local player = minetest.get_player_by_name(name) -- Get the Playerobject
	
	if( (player ~= nil) ) then
	
		local item = player:get_wielded_item() -- Get the current used Item
		
		if( (item ~= nil) )then
			if(item:get_name() ~= "") then
				chathelp.print(name, "Itemname: ", orange)
				chathelp.print(name, item:get_name() .. " - " .. item:get_count() .. " / " .. item:get_stack_max(), green)
				
			else
				chathelp.print(name, "You have no Item in your Hand.", red)
				
			end -- if( item:get_name
			
		else
			chathelp.print(name, "You have no Item in your Hand.", red)
			
		end --- if( item
	
	end -- if( player
		
end -- chathelp.show_item()

--[[
-- Shows Information about an Item you point on it
function chathelp.show_me(name)


	local curr_node_pos = minetest.get_thing_position(pointed_thing, true)
	local curr_node = minetest.get_node_or_nil(curr_node_pos)
	
	if( curr_node ~= nil ) then
		chathelp.print(name, "Itemname: ", orange)
		chathelp.print(name, curr_node:get_name(), green)
		
	else
		chathelp.print(name, "Pointed on no Node.", red)
	
	end

end -- chathelp.show_me()
--]]

-- Teleports me to the Position of the Playername
function chathelp.teleport_to(name, playername)

	if( chathelp.is_online(playername) )then -- is Player online?
		local player = minetest.get_player_by_name(playername)
		chathelp.print(name, "Player " .. player:get_player_name() .. " is at Pos: " .. minetest.pos_to_string(player:get_pos()), green)
		chathelp.print(name, "Teleporting ..", orange)
		
		local me = minetest.get_player_by_name(name) -- Own Playerobject
		me:set_pos(player:getpos()) -- Teleport
		
		-- Log the Teleport
		chathelp.print(name, name .. " teleported to " .. player:get_player_name() .. " at Pos: " .. minetest.pos_to_string(player:getpos()), log)
		
	else
		chathelp.print(name, "Player " .. playername .. " isn't online.", red)
	
	end -- if(is_online
	
end -- chathelp.teleport_to

-- Brings a Player to me
function chathelp.summon(name, playername)

	if( chathelp.is_online(playername) )then -- is Player online?
		local player = minetest.get_player_by_name(playername)
		local player_pos = minetest.pos_to_string(player:get_pos())
		
		chathelp.print(name, "Player " .. player:get_player_name() .. " is at Pos: " .. player_pos, green)
		chathelp.print(name, "Summoning ..", orange)
		
		local me = minetest.get_player_by_name(name) -- Own Playerobject
		player:set_pos(me:getpos()) -- Teleport
		
		-- Log the Teleport
		chathelp.print(name, name .. " summoned " .. player:get_player_name() .. " from Pos: " .. player_pos, log)
		
	else
		chathelp.print(name, "Player " .. playername .. " isn't online.", red)
	
	end -- if(is_online
	
end -- chathelp.summon()

-- Shows the HP of an Player
function chathelp.get_hp(name, playername)

	if( string.len(playername) == 0 ) then
		chathelp.print(name, "No Playername given.", red)
		return false
	end
	
	if( chathelp.is_online(playername) )then -- is Player online?
		local player = minetest.get_player_by_name(playername)
		local hp = player:get_hp()
		
		chathelp.print(name, player:get_player_name() .. " has " .. hp .. " Hitpoints.", green)
		if(hp > 0) then
			chathelp.print(name, "This are " .. hp / 2 .. " Hearts.", green)
			
		else
			chathelp.print(name, "Is dead.", green)
		
		end -- if(hp > 0)

	else
		chathelp.print(name, "Player " .. playername .. " isn't online.", red)
	
	end -- if(is_online

end -- chathelp.get_hp()

-- Sets the HP of an Player
function chathelp.set_hp(name, arg)

	local playername
	local hitpoints
	
	if( string.find(arg, ",") == nil) then
		chathelp.print(name, "Wrong Parameter (No Hitpoints).", red)
		return false
		
	end
	
	-- Split the Argument
	playername = chathelp.trim(string.sub(arg,1, string.find(arg, ",")-1))
	local hp = chathelp.trim(string.sub(arg, string.find(arg, ",") + 1, -1))
	
	if(string.len(hp) == 0) then
		chathelp.print(name, "No Number of Hitpoints given.", red)
		
	else
		hitpoints = tonumber(hp)
		
	end -- if(string.len)
	

	if( chathelp.is_online(playername) )then -- is Player online?
		local player = minetest.get_player_by_name(playername)
		chathelp.print(name, "Hitpoints of " .. playername .. " set to " .. hitpoints, green)
		player:set_hp(hitpoints) -- Sets the Hitpoints
		chathelp.print(name, "Has setted the Hitpoints of " .. playername .. " to " .. hitpoints, log)
	
	else
		chathelp.print(name, "Player " .. playername .. " isn't online.", red)
	
	end -- if(is_online

end -- chathelp.set_hp()

-- Adds HP to the Player
function chathelp.add_hp(name, arg)

	local playername
	local hitpoints
	
	if( string.find(arg, ",") == nil) then
		chathelp.print(name, "Wrong Parameter (No Hitpoints).", red)
		return false
		
	end
	
	-- Split the Argument
	playername = chathelp.trim(string.sub(arg,1, string.find(arg, ",")-1))
	local hp = chathelp.trim(string.sub(arg, string.find(arg, ",") + 1, -1))
	if(string.len(hp) == 0) then
		chathelp.print(name, "No Number of Hitpoints given.", red)
		
	else
		hitpoints = tonumber(hp)
		
	end -- if(string.len)
	
	if( chathelp.is_online(playername) )then -- is Player online?
		local player = minetest.get_player_by_name(playername)
		chathelp.print(name, hitpoints .. " Hitpoints add to " .. playername, green)
		player:set_hp(player:get_hp() + hitpoints) -- Add Hitpoints
		chathelp.print(name, name .. " has added " .. hitpoints .. " Hitpoints to " .. playername, log)
	
	else
		chathelp.print(name, "Player " .. playername .. " isn't online.", red)
	
	end -- if(is_online

end -- chathelp.add_hp()

-- Removes HP to the Player
function chathelp.sub_hp(name, arg)

	local playername
	local hitpoints
	
	if( string.find(arg, ",") == nil) then
		chathelp.print(name, "Wrong Parameter (No Hitpoints).", red)
		return false
		
	end
	
	-- Split the Argument
	playername = chathelp.trim(string.sub(arg,1, string.find(arg, ",")-1))
	local hp = chathelp.trim(string.sub(arg, string.find(arg, ",") + 1, -1))
	if(string.len(hp) == 0) then
		chathelp.print(name, "No Number of Hitpoints given.", red)
		
	else
		hitpoints = tonumber(hp)
		
	end -- if(string.len)
	
	if( chathelp.is_online(playername) )then -- is Player online?
		local player = minetest.get_player_by_name(playername)
		chathelp.print(name, hitpoints .. " Hitpoints removed from " .. playername, green)
		player:set_hp(player:get_hp() - hitpoints) -- Add Hitpoints
		chathelp.print(name, name .. " has removed " .. hitpoints .. " Hitpoints from " .. playername, log)
	
	else
		chathelp.print(name, "Player " .. playername .. " isn't online.", red)
	
	end -- if(is_online

end -- chathelp.sub_hp()

-- Trims a String
function chathelp.trim(myString)
	return (string.gsub(myString, "^%s*(.-)%s*$", "%1"))

end -- chathelp.trim()

-- Writes a Message in a specific color or Logs it
function chathelp.print(name, message, color)

	error = error or none	-- No Error given, set it to 99 (none)
	
	-- Logs a Message
	if(color == log) then
		minetest.log("action","[CHATHELP] "..name .. " : " .. message)
		return
	
	else
		if(color ~= none) then
			minetest.chat_send_player(name, core.colorize(color, message))
			return
		
		else 
			minetest.chat_send_player(name,  message)
			return
		
		end -- if(error ~=none)
		
	end -- if(error == log)
	
end -- print_message()

print("[MOD] " .. minetest.get_current_modname() .. " loaded.")