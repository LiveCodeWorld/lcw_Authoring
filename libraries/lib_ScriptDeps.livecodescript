script "lib_ScriptDeps"
--> MetaData
-
license: GPLv3
name: lib_ScriptDeps
type: library
version: 0.1


--> Script | Deps
-
getprop script_DepLibs [pUseTextStackArray]
   -- should give the option of returning the array directly from the objects script
  put the textStack_LibDeps of the target into dependencyStacks
   return dependencyStacks
end script_DepLibs

getprop textStack_LibDeps
   put the textstack_HkeyObjectArray of the target into objectArray
   delete variable objectArray ["Missing"]
   put the defaultstack into longStackObject
   delete variable objectArray ["revIgniter"]
   put the name of longStackObject into myStackObject
   delete variable objectArray [myStackObject]
   put keys (objectArray) into dependencyStacks
   return dependencyStacks
end textStack_LibDeps
