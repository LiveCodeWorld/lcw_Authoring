script "Global | Hkey | Send | Menu"
--> MetaData
-
license: GPLv3
name: Global | Hkey | Send | Menu
type: controller
version: 0.3


--> Menu | Init
-
getprop menu_Target [tObject]
   put scriptEditor_GetHkey() into hKey
   return hKey
end menu_Target

getprop disabled_SendCommand [hKeyLine]
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   switch hType
      case "C"
      case "M"
         return false
      case "PF"
         return "delete"
      default
         return true
   end switch
end disabled_SendCommand

getprop disabled_EvaluateFunction [hKeyLine]
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   switch hType
      case "F"
         return false
      case "C"
      case "M"
         return "delete"
      default
         return true
   end switch
end disabled_EvaluateFunction


--> Global | Hkey | Send | Menu
-
on menu_SendCommand hKeyLine
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   --
   -- check that command only has one param
   put handler_Get (hKeyLine) into someCommand
   put line 1 of someCommand into hLine
   switch the number of words of hLine
      case 2
         dispatch hName to hObject
         break
      default
         lcw_AnswerWarning "Command has at least one param!"
   end switch
end menu_SendCommand

on menu_EvaluateFunction hKeyLine
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   --
   -- check that command only has one param
   put handler_Get (hKeyLine) into someCommand
   put line 1 of someCommand into hLine
   switch the number of words of hLine
      case 2
         put hName & "()" into someFunction
         put value (someFunction, hObject)
         break
      default
         lcw_AnswerWarning "Function has at least one param!"
   end switch
end menu_EvaluateFunction
