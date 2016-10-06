script "Global_Shape_Hexagon_Set_Menu"
--> MetaData
-
license: GPLv3
name: Global_Shape_Hexagon_Set_Menu
type: controller
version: 0.1


--> Global | Shape | Hexagon | Set | Menu
-
on menu_IncreaseNodeFactor mTarget
   put the hexagon_Views of mTarget into hexagonViews
   repeat for each line hexagonView in hexagonViews
      put the inner_View of hexagonView into ringView
      if exists (ringView) is false then next repeat
      
      put the node_Factor of ringView into nodeFactor
      add (0.1 * nodeFactor) to nodeFactor
      set the node_Factor of ringView to nodeFactor
   end repeat
end menu_IncreaseNodeFactor

-- on menu_DecreaseNodeFactor mTarget
   put the hexagon_Views of mTarget into hexagonViews
   repeat for each line hexagonView in hexagonViews
      put the node_Factor of hexagonView into nodeFactor
      subtract (0.1 * nodeFactor) from nodeFactor
      set the node_Factor of hexagonView to nodeFactor
   end repeat
end menu_DecreaseNodeFactor

on _
end _

on submenu_ShapeHexagon
   return "Global | Shape | Hexagon | Menu"
end submenu_ShapeHexagon


on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Shape | Hexagon | Set | Menu | Props
-
getprop some_Prop
   return "yellow"
end some_Prop

getprop some_Props
   return "yellow,green,blue"
end some_Props


--> Global | Shape | Hexagon | Set | Menu | Disabled
-
getprop disabled_Test [mTarget]
   return false
end disabled_Test


--> Dev | Menu
-
on menu_UpdateHexagons mTarget
   lock screen
   set the locklocation of mTarget to true
   put view_GetTemplateObject ("Shape|Hexagon") into templateObject  
   put the hexagon_Views of mTarget into hexagonViews
   repeat for each line hexagonView in hexagonViews
      set the cursor to busy
      put the rect of hexagonView into hRect
      put the class_Array of hexagonView into classArray
      
      delete hexagonView
      copy templateObject to mTarget
      put it into copiedView
      
      set the rect of copiedView to hRect
      set the class_Array of copiedView to classArray
   end repeat
   set the locklocation of mTarget to false
   unlock screen
end menu_UpdateHexagons
