script "lib_MenuButton"
--> MetaData
-
license: GPLv3
name: lib_MenuButton
type: library
version: 0.9

/*
Not sure if any of this is needed.
*/

/*
This fancy default searching etc can be achieved by adding a virtual custom property to the target
Or by adding a before handler in a behavior of this script.

Consequenlty none of this code in this section is needed.
*/

/*
Views can have attached menus. 
These menus are defined and controlled by scripts that reside in a revolution object. 
The object that contains this script is a "menu_Controller", and we store the link to this menu_Controller
as a view_Value. 
If not value is set then we return a default value, which for views is the card the view is on.

It is possible to set the "menu_Controller" to another object, and so move the scripts controlling the menu arround.
This is often simpler to do with a "global menu".
*/
