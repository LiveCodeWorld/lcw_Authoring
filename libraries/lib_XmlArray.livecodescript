script "lib_XmlArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_XmlArray
type: library
version: 0.1

/*
Converts an XML tree into a Revolution multi-dimensional array.
A nodes attributes will be stored as an array of it's "@attributes" key.
Node names will retain the sequence information (i.e. node[1], node[2], etc.).
This information is necessary to determine order that keys should be processed in. Example:
set the itemDelimiter to "["
put the keys of theArray into theKeys
sort theKeys numeric by the last item of each

pUseValueKey: The default value is false. In this case you get an array that has an @attributes
key for nodes that have attributes and either a) no value or b) only child nodes. Otherwise it contains the node contents.
Set to true if you want to store a nodes value in the '@value' key. This will allow a key to have
both attributes (in @attributes key) and a value (in @value key).

"put the array_KeyTranslation [theKey] of the target into theKey" is used to translate keys if pTranslateKeyBoolean = true
pStoreEncodedAs defaults to "UTF-8"
*/



--> Working on
-


--> Xml | Array
-
function xml_ToArray pXML, pTranslateKeyBoolean, pStoreEncodedAs, pUseValueKey, pGoodXML
   -- was "xml_ConvertXmlToArray"
   local theArray, theResult, theRootNode, treeID
   local theXMLEncoding
   
   ## Create an XML tree from XML text
   put pGoodXML is true into pGoodXML
   put revXMLCreateTree (pXML, pGoodXML, true, false) into treeID
   
   if treeID is an integer then
      xml_ExtractEncoding pXML, versionMatch, theXMLEncoding
      
      ## Now convert to array.
      ## The 1st dimension has one key which is the name of the root node.
      put revXMLRootNode(treeID) into theRootNode
      if theRootNode is not empty and not (theRootNode begins with "xmlerr,") then
         put xml_ConvertXMLNodeToArray (treeID, theRootNode, theXMLEncoding, pStoreEncodedAs, pUseValueKey, pTranslateKeyBoolean) into theArray [theRootNode]
      end if
      
      revXMLDeleteTree treeID
   end if
   return theArray
end xml_ToArray

function xml_ArrayFromID treeID, theXMLEncoding, pStoreEncodedAs, pUseValueKey, pTranslateKeyBoolean
   xml_ExtractEncoding pXML, versionMatch, theXMLEncoding
   put revXMLRootNode (treeID) into theRootNode
   if theRootNode is not empty and not (theRootNode begins with "xmlerr,") then
      put xml_ConvertXMLNodeToArray (treeID, theRootNode, theXMLEncoding, pStoreEncodedAs, pUseValueKey, pTranslateKeyBoolean) into theArray [theRootNode]
   else
      return empty
   end if
   return theArray
end xml_ArrayFromID

function xml_ConvertXMLTreeToArray pXMLTree, pStoreEncodedAs, pUseValueKey
   return xml_ToArray (revXMLText (pXMLTree), pStoreEncodedAs, pUseValueKey)
end xml_ConvertXMLTreeToArray

function xml_FromArray pArray, pArrayEncoding, pStoreEncodedAs, pStartNode, pIsFormatted
   put xml_TreeFromArray (pArray, pArrayEncoding, pStoreEncodedAs) into treeID
   put revXMLText (treeID, pStartNode, pIsFormatted) into someXml
   revXMLDeleteTree treeID
   return someXml
end xml_FromArray

function xml_TreeFromArray pArray, pArrayEncoding, pStoreEncodedAs
   -- was "xml_ConvertArrayToXML"
   /*
   Converts a multi-dimensional array to an XML tree.
   The array should contain one key in the 1st dimension which
   will become the root node. Attributes of a node should be stored
   as an array in the @attributes key. Sequence information for multiple
   nodes with the same name should be included in the node name using
   brackets (i.e. node[1], node[2], node[3]).
   Returns an xml tree id (integer) or an error message.
   */
   
   local theError,theRootNode,theXML,theXMLTree
   
   ## if pArrayEncoding is empty then current platform encoding is assumed
   if pStoreEncodedAs is empty then put "UTF-8" into pStoreEncodedAs
   
   ## Create XML for root node. Note that we take extra steps in order to support
   ## converting an array that only represents part of a tree rather than the entire tree.
   ## In this case there may be multiple nodes at the root level.
   put line 1 of the keys of pArray into theRootNode
   set the itemdelimiter to "["
   put "<" & item 1 of theRootNode & "/>" into theXML
   
   ## Create XML needed to create tree
   put format("<?xml version=\"1.0\" encoding=\"%s\"?>%s", pStoreEncodedAs, theXML) into theXML
         put revXMLCreateTree(theXML, true, true, false) into theXMLTree
   
   if theXMLTree is an integer then
      ## Loop over all nodes at root level
      put false into stripMetaKeys
      put xml_SortArrayKeysWithXMLOrdering (pArray, stripMetaKeys) into theNodes
      
      ## Create tree using helper function
      repeat for each line theNode in theNodes
         xml_ConvertArrayDimensionToXML pArray[theNode], theXMLTree, slash & theNode, pArrayEncoding, pStoreEncodedAs
         put the result into theError
         
         if theError is not empty then exit repeat
      end repeat
      
      if theError is not empty then
         ## something went wrong, clean bad tree
         revXMLDeleteTree theXMLTree
      end if
   else
      put theXMLTree into theError
   end if
   
   if theError is not empty then
      return theError
   else
      return theXMLTree
   end if
end xml_TreeFromArray

private command xml_ConvertArrayDimensionToXML pArray, pTreeID, pNode, pArrayEncoding, pStoreEncodedAs
   /*
   -- Helper function for xml_FromArray
   -- Converts the multi-dimensional array pArray to nodes in pTreeID.-- Calls itself recursively.
   -- Returns error message.
   */
   local theError, theKey, theKeys, theNode
   
   ## A workaround for fact that Revolution does not return
   ## keys in the order we created them
   put false into stripMetaKeys
   put xml_SortArrayKeysWithXMLOrdering(pArray, stripMetaKeys) into theNodes
   
   ## Arrays might have sequencing info in name
   ## (i.e. step[1], step[2], ... )
   set the itemdelimiter to "["
   
   repeat for each line theFullNode in theNodes
      put item 1 of theFullNode into theNode
      
      ## Look for attributes. These will be added as attributes to pNode.
      if theNode is "@attributes" or theNode is "@attr" then
         repeat for each line theKey in the keys of pArray[theFullNode]
            revSetXMLAttribute pTreeID, pNode, theKey, xml_EncodeString(pArray[theFullNode][theKey], pArrayEncoding, pStoreEncodedAs)
            if the result begins with "xmlerr," then
               put the result && "(setting attribute" && theKey && "for node" && pNode & ")" into theError
            end if
            
            if theError is not empty then exit repeat
         end repeat
         
      else if theNode is "@value" then
         ## This XML tree is using complex structure. Node is the value of the parent node
         revPutIntoXMLNode pTreeID, pNode, xml_EncodeString(pArray[theFullNode], pArrayEncoding, pStoreEncodedAs)
         if the result begins with "xmlerr," then
            put the result && "(adding child node" && theNode && "to node" && pNode & ")" into theError
         end if
         
      else
         if the keys of pArray[theFullNode] is not empty then
            ## Node has children. Add node to XML tree then call self recursivly to create children nodes.
            revAddXMLNode pTreeID, pNode, theNode, empty
            if the result begins with "xmlerr," then
               put the result && "(adding node" && theNode & ")" into theError
            end if
            
            if theError is empty then
               xml_ConvertArrayDimensionToXML pArray[theFullNode], pTreeID, pNode & slash & theFullNode, pArrayEncoding, pStoreEncodedAs
               put the result into theError
            end if
         else
            ## Node has no children but possibly a value. Create node and add value (which may be empty).
            revAddXMLNode pTreeID, pNode, theNode, xml_EncodeString(pArray[theFullNode], pArrayEncoding, pStoreEncodedAs)
            if the result begins with "xmlerr," then
               put the result && "(adding child node" && theNode && "to node" && pNode & ")" into theError
            end if
         end if
      end if
      
      if theError is not empty then exit repeat
   end repeat
   
   return theError
end xml_ConvertArrayDimensionToXML

function xml_SortArrayKeysWithXMLOrdering pArray, pStripMetaKeys
   -- Revolution array keys are never guaranteed to be in order you created-- them in so we must come up with some other way of maintaining-- proper sequence. For arrays representing XML, the XML syntax is-- used (i.e. node[1], node[2], etc.). This handler will sort keys that use-- this syntax for representing sequence.
   put pStripMetaKeys is not false into pStripMetaKeys
   
   put the keys of pArray into theKeys
   set the itemdelimiter to "["
   sort theKeys numeric by the last item of each -- 1], 2], 3], etc.
   
   -- additional sort to allow ordering according to naming of keys
   -- sort theKeys - breaks xml creation
   
   if pStripMetaKeys then
      filter theKeys without "@*"
   end if
   
   return theKeys
end xml_SortArrayKeysWithXMLOrdering

function xml_ConvertXMLNodeToArray pTreeID, pNode, pXMLTreeEncoding, pStoreEncodedAs, pUseValueKey, pTranslateKeyBoolean
   /*
   Helper function for xml_ToArray.
   Converts an XML node to a multi-dimensional array.-- Calls itself recursively.
   */
   local theArrayA, theAttributes, theChildNode, theKey
   
   ## Look for attributes of the node. Store as array in "@attributes" key
   put revXMLAttributes (pTreeID, pNode, tab, cr) into theAttributes
   if theAttributes is not empty then
      put xml_EncodeString (theAttributes, pXMLTreeEncoding, pStoreEncodedAs) into theAttributes
      split theAttributes by cr and tab -- create array
      put theAttributes into theArrayA ["@attributes"]
   end if
   
   ## Look for children nodes.
   set the itemdelimiter to slash
   put revXMLFirstChild (pTreeID, pNode) into theChildNode
   if theChildNode is empty or theChildNode begins with "xmlerr," then
      put xml_EncodeString (revXMLNodeContents (pTreeID, pNode), pXMLTreeEncoding, pStoreEncodedAs) into theValue
      if word 1 to -1 of theValue is empty and the keys of theArrayA is not empty then
         ## Empty node that has attributes
         return theArrayA
      else if pUseValueKey then
         ## Force value into @value
         put theValue into theArrayA ["@value"]
         return theArrayA
      else
         ## Single Node with value: Return value. Attributes are ignored.
         return theValue
      end if
   else
      ## Child nodes were found. Recursively call self and store result in array.
      repeat while theChildNode is not empty and not (theChildNode begins with "xmlerr,")
         put the last item of theChildNode into theKey
         
         /*
         if pTranslateKeyBoolean is true then
            put the array_KeyTranslation [theKey] of the target into theKey
            if theKey is empty then next repeat -- this can repeat forever
         end if 
         */
         
         put xml_ConvertXMLNodeToArray (pTreeID, theChildNode, pXMLTreeEncoding, pStoreEncodedAs, pUseValueKey, pTranslateKeyBoolean) into theArrayA [theKey]
         put revXMLNextSibling (pTreeID, theChildNode) into theChildNode
      end repeat
      
      return theArrayA
   end if
end xml_ConvertXMLNodeToArray
