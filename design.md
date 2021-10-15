# Main Formspec

? question mark in the top left corner (image_button), for explaining how to use this documentation works, shows a formspec, that on receive shows this main menu again

quit button in the center

"select" button in the top right to select besides doubleclick

textlist[]
containing all the categories
" Overview"
"catgeory1"

```formspec
formspec_version[4]
size[20,20]
position[0.5,0.5]
bgcolor[#111E]
hypertext[0,0;20,20;;<style color=#AFA size=32><b><center>Game Guide</center></b></style>]
button[0.2,2.2;5,1.6;gdmc_help;Help]
button[7.5,2.2;5,1.6;gdmc_quit;Quit]
button[14.8,2.2;5,1.6;gdmc_select;Select]
textlist[0.2,4;19.6,15.8;gmdc_list;Getting Started,Mesecon,Farming;1;false]
```

# Category Formspec

back button top left corner

quit button in the center

"select" button in the top right to select besides doubleclick

textlist[]
containing all the entries
" Overview"
"item1"

on_submit, look for back button, select button, or DBL click on textlist

```formspec
formspec_version[4]
size[20,20]
position[0.5,0.5]
bgcolor[#111E]
hypertext[0,0;20,20;;<style color=#AFA size=28><b><center>Getting Started</center></b></style>]
button[0.2,2.2;5,1.6;gdmc_back;Back]
button[7.5,2.2;5,1.6;gdmc_quit;Quit]
button[14.8,2.2;5,1.6;gdmc_select;Select]
textlist[0.2,4;19.6,15.8;gmdc_list;Welcome,Digging,Crafting;1;false]
```

# Documentation Formspec

```formspec
formspec_version[4]
size[20,20]
position[0.5,0.5]
bgcolor[#111E]
button[0.2,0.2;5,1.6;gdmc_back;Back]
button[7.5,0.2;5,1.6;gdmc_quit;Quit]
hypertext[0.2,2;19.6,15.8;;hello]
```

Documentation hypertext in the top

# Notes

1. At any time, if exscape is pressed, just let them leave
2. Always start them at the top level formspec

# Hidden System Design

## Note about loading player tables

If the .json loaded is invalid, Error out and stop loading the server,
alert the user to which .json

Ignore any entries or categories that the player has that aren't even entries or
categories, the server owner may re-enable them later. 

## Startup

1. Parse all the entries at on_load into a default hidden table
2. Load the previous table of default hidden categories and entries
3. Build a table of those (categories and entries) that are changed since last time (all of them if first execution)
    - If any are changed, load and change ALL player entries to be up to date

## On-Join-Player

When a player joins, load their saved "shown" values
    - If they have none, use the defaults
    - All values are assumed to be HIDDEN by default, so this runtime player table will only have the to be shown values:
```lua
player_data[player_name].shown_categories = {
    "cat1",
    "cat2",
    "cat3",
    "cat4",
}
player_data[player_name].shown_entries = {
    ["cat1"] = { "ent1", "ent2", },
    ["cat2"] = { "ent1", "ent2", },
}
```

This will require some processing to find out if a player has something hidden that is normally shown, as you must compare
the *missing* saved "hidden" category/entry with the default "shown" category/entry and make sure to save the player actually 
*doesn't* have that shown (like it would be by default).

Finally Sort the shown_categories list and the shown_entries sub-lists

## On-Leave-Player

Make the runtime player table equal to nil:
```lua 
player_data[player_name] = nil
```
For keeping down memory usage :)

## Display 

1. When a player loads up the main_form(), use the shown_categories for the player list
2. When a player loads up a category_form, use the shown_entires for the player list
3. When they try to view a hidden category OR entry, instead take them to the main_form

## Modifications

```lua
function on_modification(player_name)
    local hidden_table = nil
    if player_is_logged_in then
        update their runtime lists() (and sort)
        if no_change() then
            return
        end
        invalidate_their_currently_displayed_entry&category&form()

        hidden_table = player_table
    else
        if minetest.builtin_auth_handler.get_auth(player_name) == nil then
            return
        else
            hidden_table = calculate_effects_of_defaults_on_load(load_values(player_name))
            update_the_table(hidden_table)
        end
    end

    -- Made it this far, time to save
    calculate_effects_of_defaults_on_save(hidden_table)
    save_as_json(hidden_table, player_name) --will not save nil table
end
```




