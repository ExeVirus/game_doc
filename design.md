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




