script "lib_Edit"
--> MetaData
-
license: GPLv3
name: lib_Edit
type: library
version: 0.1

/*
Note: On Mac OS systems, if the application is already running, the launch command does nothing, and "Process is already open." is placed in the result function. 
Note: On Windows and Linux, an additional instance of the application will start.

Note: On OS X systems, you can use the launch command to start up an application, but not a Unix process. To work with a Unix process, use the shell function instead.

Tip: On Windows systems, you can also start up an application by using the shell function with the Windows "start" command:
get shell("start MyProgram.exe")
*/


--> Atom
-
--> Atom
-
command atom_Edit someFile
   if there is a file someFile then
      atom_DisplayFile someFile
   else
      atom_DisplayText someFile
   end if
end atom_Edit

command atom_DisplayText someText, pFileExtension, pUseBinary
   put the tempname into someFile
   if pFileExtension is not empty then
      put "." & pFileExtension after someFile
   end if
   if pUseBinary is true then
      put someText into url ("binfile:" & someFile)
   else
      put someText into url ("file:" & someFile)
   end if
   --
   atom_DisplayFile someFile
   put the result into launchSuccess
   return launchSuccess
end atom_DisplayText

command atom_DisplayFile someFile
   -- not sure why
   -- launch someFile with "Atom" does not work
   
   launch someFile with "/Applications/Atom.app" -- "Atom"
   put the result into launchSuccess
   return launchSuccess
end atom_DisplayFile

command edit_TextFile someFile
   atom_DisplayFile someFile
   if the result is not empty then
      shell_TextFile someFile
   end if
end edit_TextFile

command shell_TextFile someFile
   if someFile is empty then
      put "edit" && kwote(someFile) into someShell
   else
      put "edit" && kwote(someFile) into someShell
   end if
   put shell (SomeShell) into shellResult
   lcw_Notify shellResult
end shell_TextFile


