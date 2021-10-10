--------------------------------------------------------------
--                  player_management.lua                   --
--------------------------------------------------------------
--                                                          --
-- This file manages the somewhat complex process of        --
-- managing player hidden values via mod storage.           --
-- For example:                                             --
--                                                          --
-- When a category is hidden by default, and a plyer has    --
-- somehow unlocked that category or entry, they will have  --
-- an entry in their player table specifying as such.       --
--                                                          --
-- For this table, categories are stored in one list, and   --
-- Entires are stored in a separate table that uses the     --
-- category as a key, to speed up the formspec display at   --
-- runtime.                                                 --
--                                                          --
-- Nothing happens in this file if the hidden system is     --
-- disabled, as it's un-needed to track per-player data.    --
--                                                          --
-- Note: if you have a player reveal a hidden entry, and    --
-- then you remove that entry for some reason, they will    --
-- have a memory leak here where we track that hidden value --
-- but it's no longer needed. This is done so if that entry --
-- returned, the old player value will be remembered.       --
--------------------------------------------------------------

--All hidden data for each player is stored here
game_doc.player_data = {}

