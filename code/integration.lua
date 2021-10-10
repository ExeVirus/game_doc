--------------------------------------------------------------
--                     integration.lua                      --
--------------------------------------------------------------
--                                                          --
-- This file will optionally register game_doc with i3,     --
-- and provide a chat command to access the main game_doc   --
-- formspec.                                                --
--------------------------------------------------------------


-- Chat Command Integration
if game_doc.settings.enable_chat_command then
    minetest.register_chatcommand("doc", {
        privs = {
            interact = true,
        },
        func = function(player_name, _)
            minetest.show_formspec(
                player_name,
                "game_doc_main",
                game_doc.main_form(player_name)
            )
        end,
    })
end

