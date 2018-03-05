script "Global_Handler_Dictionary_Menu"
--> MetaData
-
license: GPLv3
name: Global_Handler_Dictionary_Menu
type: controller
version: 0.1


--> Global | Handler | Dictionary | Menu
-
on menu_DisplayDictionaryTerms
   put ide_GetDictionaryTerms() into dictionaryTerms
   display_Index dictionaryTerms, "ide_GetDictionaryTerms()"
end menu_DisplayDictionaryTerms

on _
end _

on menu_LoadDictionaryTerms
   ide_LoadDictionaryTerms
   
   menu_DisplayDictionaryTerms
end menu_LoadDictionaryTerms

on menu_FetchDictionaryTerms
   put ide_FetchDictionaryTerms() into dictionaryTerms
   display_Index dictionaryTerms, "ide_FetchDictionaryTerms()"
end menu_FetchDictionaryTerms

on menu_StoreDictionaryTerms
   put ide_GetDictionaryTerms() into dictionaryTerms
   ide_StoreDictionaryTerms dictionaryTerms
end menu_StoreDictionaryTerms

on _
end _

on menu_RevDictionaryTerms
   put rev_FetchDictionaryTerms() into dictionaryTerms
   display_Index dictionaryTerms, "rev_FetchDictionaryTerms()"
end menu_RevDictionaryTerms


--> Global | Handler | Dictionary | Menu | Props
-

--> Global | Handler | Dictionary | Menu | Disabled
-
