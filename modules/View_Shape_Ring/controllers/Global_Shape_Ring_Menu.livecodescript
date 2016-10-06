script "Global_Shape_Ring_Menu"
--> MetaData
-
license: GPLv3
name: Global_Shape_Ring_Menu
type: controller
version: 0.1


--> Global | Shape | Ring | Menu
-
on menu_NodeNumber mTarget, pointNum
   local pInitialRotation
   set the ring_NodeNumber [pInitialRotation] of mTarget to pointNum
end menu_NodeNumber

getprop point_Num [mTarget]
   put the ring_NodeNumber of mTarget into pointNum
   return pointNum
end point_Num

getprop point_Nums
   return "3,4,5,6,7,8,9"
end point_Nums

on menu_ShowRing mTarget, someBoolean
   set the ring_Visible of mTarget to someBoolean
end  menu_ShowRing

on menu_ShowBorder mTarget, someBoolean
   set the showborder of mTarget to someBoolean
end menu_ShowBorder

on _
end _

on menu_IncreaseNodeFactor mTarget
   put the node_Factor of mTarget into nodeFactor
   add (0.1 * nodeFactor) to nodeFactor
   set the node_Factor of mTarget to nodeFactor
end menu_IncreaseNodeFactor

on menu_DecreaseNodeFactor mTarget
   put the node_Factor of mTarget into nodeFactor
   subtract (0.1 * nodeFactor) from nodeFactor
   set the node_Factor of mTarget to nodeFactor
end menu_DecreaseNodeFactor

on _
end _


on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Shape | Ring | Menu | Props
-
getprop show_Ring [mTarget]
   return the ring_Visible of mTarget
end show_Ring

getprop show_Border [mTarget]
   put the showborder of mTarget into someBoolean
   return someBoolean
end show_Border


--> Global | Shape | Ring | Menu | Disabled
-
getprop disabled_Test [mTarget]
   return false
end disabled_Test


--> Dev | Menu
-
on menu_RefreshNodes mTarget
   put the ring_NodeNumber of mTarget into nodeNum
   set the ring_NodeNumber of mTarget to nodeNum
end menu_RefreshNodes
