script "lib_Standalone"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Standalone
type: library
version: 0.1

/*Some help*/


--> Working on
-
getprop standalone_Array
   -- simple. Was "getStandaloneSettings"
   put the standalone_SettingsArray of the target into settingsArray
   --
   put settingsArray ["name"] into tRelevantSettingsA ["standaloneName"]
   put settingsArray ["defaultBuildFolder"] into tRelevantSettingsA ["defaultBuildFolder"]
   --
   return tRelevantSettingsA
end standalone_Array


--> Standalone
-
getprop standalone_SettingsArray
   put the stack_Name of the target into stackName
   --
   set the customPropertySet of stack stackName to "cRevStandaloneSettings"
   put the customProperties of stack stackName into settingsArray
   set the customPropertySet of stack stackName to empty 
   --
   return settingsArray
end standalone_SettingsArray

setprop standalone_SettingsArray settingsArray
   put the stack_Name of the target into stackName
   --
   set the customPropertySet of stack stackName to "cRevStandaloneSettings"
   set the customProperties of stack stackName to settingsArray
   set the customPropertySet of stack stackName to empty
   --
   return stackName
end standalone_SettingsArray

getprop standalone_Settings
   put the standalone_SettingsArray of the target into settingsArray
   put standalone_GetSettings (settingsArray) into tRelevantSettingsA
   return tRelevantSettingsA
end standalone_Settings

setprop standalone_SettingsValue [sKey] sValue
   put the standalone_SettingsArray of the target into settingsArray
   --
   put sValue into settingsArray [sKey]
   --
   set the standalone_SettingsArray of the target to settingsArray
   return settingsArray
end standalone_SettingsValue


--> Standalone | Settings | Files
-
setprop standalone_RemovePath somePath
   put the standalone_SettingsArray of the target into settingsArray
   --
   put settingsArray ["files"] into pathIndex
   line_Delete somePath, pathIndex
   put pathIndex into settingsArray ["files"]
   --
   set the standalone_SettingsArray of the target to settingsArray
   return settingsArray
end standalone_RemovePath

setprop standalone_AddPath [uniqueShortFiles] newPaths
   put the standalone_SettingsArray of the target into settingsArray
   --
   put settingsArray ["files"] into pathIndex
   if uniqueShortFiles is not false then
      file_AddUniqueShortFile pathIndex, newPaths
   else
      line_Add newPaths, pathIndex
   end if
   put pathIndex into settingsArray ["files"]
   --
   set the standalone_SettingsArray of the target to settingsArray
   return settingsArray
end standalone_AddPath

command file_AddUniqueShortFile @pathIndex, newPaths
   set the itemdelimiter to slash
   repeat for each line somePath in newPaths
      if somePath is empty then next repeat
      
      # Strip and paths with same short file
      put item -1 of somePath into shortFile
      put "*/" & shortFile into sFilter
      filter pathIndex without sFilter
      
      # Add somePath
      set the wholematches to true
      put lineoffset (somePath, pathIndex) into lineNum
      if lineNum is 0 then
         put the number of lines of pathIndex into maxLine
         put maxLine + 1 into lineNum
         put somePath into line lineNum of pathIndex
      end if
   end repeat
end file_AddUniqueShortFile

getprop standalone_Files
   put the standalone_SettingsArray of the target into settingsArray
   put settingsArray ["files"] into pathIndex
   return pathIndex
end standalone_Files

setprop standalone_Files pathIndex
   put the standalone_SettingsArray of the target into settingsArray
   put pathIndex into settingsArray ["files"]
   set the standalone_SettingsArray of the target to settingsArray
   return settingsArray
end standalone_Files


--> Private
-
private command _DeconstructSettingsArray settingsArray, @standaloneName, defaultBuildFolder
   put settingsArray ["name"] into standaloneName
   put settingsArray ["defaultBuildFolder"] into defaultBuildFolder
end _DeconstructSettingsArray
