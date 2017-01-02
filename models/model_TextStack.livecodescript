script "model_TextStack"
--> MetaData
-
license: GPLv3
name: model_TextStack
type: model
version: 0.6

/*
A "text stack" is a representation of a stack, together with any metadata in a simple text format.
All the text files are contained in a single folder.

It should be possible to reconstruct the entire stack from the "data" folder,
while the metadata folder should contain any information which desribes or graphs any dependencies for the stack.
*/


--> TextStack | DepStacks
-
getprop textstack_DepStacks
   put the textstack_HkeyObjectArray of the target into objectArray
   delete variable objectArray ["Missing"]
   put the stack_Object of the target into longStackObject
   delete variable objectArray ["revIgniter"]
   put the name of longStackObject into myStackObject
   delete variable objectArray [myStackObject]
   put keys (objectArray) into dependencyStacks
   return dependencyStacks
end textstack_DepStacks

getprop textstack_HkeyObjectArray
   put the textstack_ProcessedHkeyArray of the target into processedHkeyArray  
   put hkeyArray_ConstructObjectArray (processedHkeyArray) into hkeyObjectArray
   return hkeyObjectArray
end textstack_HkeyObjectArray

getprop textstack_ProcessedHkeyArray
   put the project_ProcessedHkeyArrayFile of the target into someFile
   put array_Fetch (someFile) into rigHkeyArray
   return rigHkeyArray
end textstack_ProcessedHkeyArray

setprop textstack_ProcessedHkeyArray rigHkeyArray
   put the project_ProcessedHkeyArrayFile of the target into someFile
   array_Save someFile, rigHkeyArray
   return someFile
end textstack_ProcessedHkeyArray


--> hArray | Model
-
command hArray_LoadGlobal
   global gHkey_Array
   put hArray_FetchData() into gHkey_Array
end hArray_LoadGlobal

command hArray_StoreGlobal
   global gHkey_Array
   hArray_StoreData gHkey_Array
end hArray_StoreGlobal

command hArray_DeleteArrayDatabase
   global gHkey_Array
   delete variable gHkey_Array
end hArray_DeleteArrayDatabase

function hArray_FetchData
   put lcw_FetchArray ("Hkey_Data.array") into hArray
   return hArray
end hArray_FetchData

command hArray_StoreData hArray
   lcw_StoreArray "Hkey_Data.array", hArray
end hArray_StoreData


--> Project | hArray | Model
-
/*
Should change this to store it somewhere sensible
Like the lcw_User folder?
*/

function project_FetchHarray
   put lcw_FetchArray ("Hkey_Data.array") into hArray
   return hArray
end project_FetchHarray

command project_SaveHarray hArray
   lcw_StoreArray "Hkey_Data.array", hArray
   put the result into arrayFile
   return arrayFile
end project_SaveHarray
