--                                    _            
--   __ _  __ _ _ __ ___   ___     __| | ___   ___ 
--  / _` |/ _` | '_ ` _ \ / _ \   / _` |/ _ \ / __|
-- | (_| | (_| | | | | | |  __/  | (_| | (_) | (__ 
--  \__, |\__,_|_| |_| |_|\_______\__,_|\___/ \___|
--  |___/                    |_____|               
--
-- Author: ExeVirus (Just_Visiting)
-- MIT Licensed 2021
--
-- Please see the readme for an overview of the modder-facing api.


-- This mod is broken into multiple files: 
----
---- <> settingtypes.txt:
----      Edit to change the default look, default hidden values, turn off the hidden system, etc.
----
---- <> code/settings.lua:
----      Loads the settings into the game_doc table
----
---- <> code/add_entires.lua: 
----      Provides the 3 modder facing game_doc registration functions
---- 
---- <> code/direct_access.lua:
----      Provides the 2 modder-facing game_doc direct access functions
----      Note: changes made in these tables will affect the game, they are NOT copies
----
---- <> code/formspecs.lua:
----      Generates the 3 different formspecs (main, category, and entry) for this in-game documentation/text system
----
---- <> code/integration.lua:
----      Based on settings, will register the command /game_doc to show the main documentation menu
----      and will, if found, add a tab to i3 to access the same formspec from the inventory screen.
---- 
---- <> code/player_management.lua:
----      As player's join the game for the first time, and have their hidden values updated,
----      this file will manage those player states.
----
---- <> code/hidden_modifications.lua:
----      Provides the 4 modder-facing game_doc hidden-modification functions


-- Global main mod table
game_doc = {}

-- Boilerplates
game_doc.name = "game_doc"
game_doc.path = minetest.get_modpath(game_doc.name)
game_doc.doc_data = {} -- the actual entries
game_doc.ready_forms = {} -- for storing ready made category formspecs- if hidden system is disabled
game_doc.mods_loaded = false 

-- File Loading
dofile(game_doc.path .. "/code/settings.lua")
dofile(game_doc.path .. "/code/add_entries.lua")
dofile(game_doc.path .. "/code/direct_access.lua")
dofile(game_doc.path .. "/code/formspecs.lua")
dofile(game_doc.path .. "/code/integration.lua")

-- These are only used if the hidden system is enabled
if game_doc.hidden_enable then
    dofile(game_doc.path .. "/code/player_management.lua")
    dofile(game_doc.path .. "/code/hidden_modifications.lua")
end

-- Done, let 'em know
minetest.log("info","'game_doc' loaded successfully")