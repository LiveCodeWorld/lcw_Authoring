script "behavior_FedwikiOverides"
--> MetaData
-
license: GPLv3
name: behavior_FedwikiOverides
type: behavior
version: 0.1

/*
See also behavior_RigLocalOveride
*/


--> Fedwiki | Overrides
-
before fedwiki_ReturnJSON pageJSON
   -- this would normally return pageJSON back to the Fedwiki client
   -- but here we override it
   -- could be a front script
   
   if the shiftkey is "Down" then put pageJSON
   put json_ToArray (pageJSON) into pageArray
   display_Array pageArray, "fedwiki_ReturnJSON()"
   exit to top
end fedwiki_ReturnJSON
