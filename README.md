# game_doc
#### In-Game Documentation Tree System


*game_doc* provides a few different functions for other mods and games to use, allowing for much needed in-game documentation for minetest-engine based games and mods. All games/mods that include game_doc by default (adjustable setting) will have a chat command `/doc` to view the main documentation menu.

This mod assumes all documentation will be in the form of either a `hypertext` element, or a `markdown.md` file (or folder of such files) that this mod then uses [markdown2formspec](https://github.com/ExeVirus/markdown2formspec) mod to parse into a hypertext element.

They are:

```lua
gmd.add_direct_entry(category_name, entry_name, hypertext_element, hidden)
-- hidden is always optional, defaults to false
-- Will add <entry_name> to <category_name> containing the hypertext formspec element to be displayed

gmd.add_file_entry(category_name, entry_name, markdown_file, hidden)
-- hidden is always optional, defaults to false
-- Will parse the provided markdown_file and add the resulting hypertext element to be found at <entry_name> in <category_name>

gmd.add_folder_entries(category_name, folder_location, hidden)
-- hidden is always optional, defaults to false
-- Will parse the provided folder for any `.md` files that are present, turn them into hypertext elements,
-- use their filename as <entry_name> and add them to the provided category. 

```

The tree structure is:

Main Menu \> categories \> list_names \> formspec

## Hidden Entries

This mod also supports hidden and unhidden entries, all categories and entries are shown by default to all players. To hide or unhide entries use:

```lua

gmd.hide_category(player_name, category)

gmd.show_category(player_name, category)

gmd.hide_entry(player_name, entry)

gmd.show_entry(player_name, entry)

```

## Direct access

You can access the categories and entries via these functions. **BE CAREFUL**, these are not copies, and changes will affect things, read the mod code if you are worried by this warning.

```lua
gmd.get_doc_data()
-- Returns a table 
-- {
--  category_name { hidden=false/true, entries { entry1 { hidden=false/true, hypertext }, entry2 {hidden=false/true, hypertext } }
--  category_name { hidden=false/true, entries { entry1 { hidden=false/true, hypertext }, entry2 {hidden=false/true, hypertext } }
--  etc.
-- }
--

-- Note the hidden values are just the starting values for new players, the player hidden entry/category data
-- is held in this function:
gmd.get_hidden_data()
-- Returns a table 
-- {
--  player_name  = {
--    category_name { hidden=false/true, entries { entry1 { hidden=false/true }, entry2 {hidden=false/true } }
--    category_name { hidden=false/true, entries { entry1 { hidden=false/true }, entry2 {hidden=false/true } }
--    etc.
--  }
--  player_name  = {
--    category_name { hidden=false/true, entries { entry1 { hidden=false/true }, entry2 {hidden=false/true } }
--    category_name { hidden=false/true, entries { entry1 { hidden=false/true }, entry2 {hidden=false/true } }
--    etc.
--  }
--  etc.
-- }

```

## Other Notes

The entire hidden system can be disabled, which allows the backend code to run faster, and allows the mod to act more like a documentation system only.

Notice with the hidden functionality, the use cases for this mod can expand. Categories and entries can be quests/lore/old dialog/etc. No sounds are generated
from this mod, and no other popups are created, hopefully letting mod authors have as much flexibility as possible using it. 

