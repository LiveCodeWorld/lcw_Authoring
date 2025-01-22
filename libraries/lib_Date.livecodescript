script "lib_Date"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Date
type: library
version: 0.1

/*
This library focusses on processing dates, especially the various international date formats common on the internet.

See also:
-- https://github.com/revig/revigniter/blob/develop/system/helpers/dateHelper.livecodescript
-- https://github.com/derbrill/libdate/blob/master/libdate.livecodescript
*/


--> Working on
-

--> Date | Standard
-
function test_8601ToInternet
   -- https://en.wikipedia.org/wiki/ISO_8601
   -- converts to "internet date"
   -- corresponds to November 5, 1994, 8:15:30 am, US Eastern Standard Time.
   
   get "1994-11-05T08:15:30-05:00"
   put date_8601ToInternet (it) into iDate
   if iDate is not "Sat, 5 Nov 1994 03:15:30 +0000" then return it & CR & iDate
   
   get "1994-11-05T13:15:30Z"
   put date_8601ToInternet (it) into iDate
   if iDate is not "Sat, 5 Nov 1994 13:15:30 +0000" then return it & CR & iDate
   
   get "2018-09-15T05:53:00+00:00"
   put date_8601ToInternet (it) into iDate
   if iDate is not "Sat, 15 Sep 2018 05:53:00 +0100" then return it & CR & iDate
   
   get "2018-09-15T05:53:00-07:00"
   put date_8601ToInternet (it) into iDate
   if iDate is not "Fri, 14 Sep 2018 22:53:00 +0100" then return it & CR & iDate
   
   get "2018-09-14T22:53:00-07:00"
   put date_8601ToInternet (it) into iDate
   if iDate is not "Fri, 14 Sep 2018 15:53:00 +0100" then return it & CR & iDate
   
   get "2019-09-07T15:50+00Z"
   put date_8601ToInternet (it) into iDate
   if iDate is not "Sat, 7 Sep 2019 15:50:00 +0100" then return it & CR & iDate
   
   get "2019-09-07T15:50-04:00"
   put date_8601ToInternet (it) into iDate
   if iDate is not "Sat, 7 Sep 2019 11:50:00 +0100" then return it & CR & iDate
   
   get "2020-12-08 03:23:50.765525487 -0500"
   put date_8601ToInternet (it) into iDate
   if iDate is not "Mon, 7 Dec 2020 22:23:50 +0000" then return it & CR & iDate
   
   -- no idea what this is?!?
   -- get "2019-09-07T-15:50+00"
   return "Passed all tests"
end test_8601ToInternet

function date_8601ToInternet rfc8601Date
   -- convert rfc8601Date to standard date
   -- return rfc8601Date
   
   if rfc8601Date contains "T" then
      get rfc8601Date
      replace "T" with CR in it
      put line 1 of it into someDate
      put line 2 of it into timeBit
      switch
         case timeBit contains "-"
            set the itemdelimiter to "-"
            put item 1 of timeBit into someTime
            put "-" & item 2 of timeBit into someTimeZone
            break
         case timeBit contains "+"
            set the itemdelimiter to "+"
            put item 1 of timeBit into someTime
            put item 2 of timeBit into someTimeZone
            break
         case timeBit contains "Z"
            set the itemdelimiter to "Z"
            put item 1 of timeBit into someTime
            put "Z" into someTimeZone
            break
         default
            breakpoint
            put timeBit into someTime
            put "Z" into someTimeZone
      end switch
   else
      put word 1 of rfc8601Date into someDate
      put word 2 of rfc8601Date into someTime
      put word 3 of rfc8601Date into someTimeZone
   end if
   
   replace "-" with comma in someDate
   put someDate into someDateItems
   --
   set the itemdelimiter to ":"
   if the number of items of someTime = 1 then
      put char 1 to 2 of someTime into colonHours
      put char 3 to 4 of someTime into colonMinutes
      put char 5 to -1 of someTime into colonSeconds
   else
      put item 1 of someTime into colonHours
      put item 2 of someTime into colonMinutes
      put item 3 of someTime into colonSeconds
   end if
   if colonSeconds is empty then
      put 0 into colonSeconds
   end if
   --
   set the itemdelimiter to comma
   if someTimeZone contains "Z" is false then
      if colonHours is a number AND colonMinutes is a number AND colonSeconds is a number then
         put colonHours * 60*60 into someSeconds
         add colonMinutes*60 to someSeconds
         add colonSeconds to someSeconds
         --
         set the itemdelimiter to ":"
         if the number of items of someTimeZone = 1 then
            put char 1 to -3 of someTimeZone into tzHours
            
         else
            put item 1 of someTimeZone into tzHours
            put item 2 of someTimeZone into tzMinutes
         end if
         
         if tzHours is a number AND tzMinutes is a number then
            if tzHours > 0 then
               add tzHours*60*60 to someSeconds
               add tzMinutes*60 to someSeconds
            else
               add tzHours*60*60 to someSeconds
               subtract tzMinutes*60 from someSeconds               
            end if
            --
            if someSeconds < 0 then
               -- steal a day
               add 24*60*60 to someSeconds
               --
               set the itemdelimiter to comma
               put item 3 of someDateItems into someDay
               subtract 1 from someDay
               put someDay into item 3 of someDateItems
            end if
            
            put (someSeconds  div (60*60)) into colonHours
            put (someSeconds  mod (60*60)) into secondsRemaining
            put (secondsRemaining  div 60) into colonMinutes
            put (secondsRemaining  mod 60) into colonSeconds
         end if
      end if
   end if
   --
   set the itemdelimiter to comma
   put colonHours into item 4 of someDateItems
   put colonMinutes into item 5 of someDateItems
   if colonSeconds is empty then
      put 0 into item 6 of someDateItems 
   else
      put trunc (colonSeconds) into item 6 of someDateItems 
   end if
   put 0 into item 7 of someDateItems
   --
   convert someDateItems to internet date
   return someDateItems
end date_8601ToInternet

--> Date | 8601
-
function date_Construct8601 someDate, extended, convertToUTC
   -- extended is true:  1981-04-05T14:30:30-05:00
   -- extended is false: 19810405T14:30:30-05 00
   
   convert someDate to internet date
   put word -1 of someDate into utcOffset
   
   convert someDate to dateItems
   put item 1 of someDate into y
   put item 2 of someDate into mons
   put item 3 of someDate into d
   put item 4 of someDate into h
   put item 5 of someDate into mins
   put item 6 of someDate into s
   
   if convertToUTC is true then
      put char 2 to 3 of utcOffset into extraHours
      put char 4 to 5 of utcOffset into extraMin
      
      if char 1 of utcOffset is "+" then
         add extraHours to h
         add extraMin to m
      else
         subtract extraHours from h
         subtract extraMin from m
      end if
      
      if extended is true then
         put "%04d-%02d-%02dT%02d:%02d:%02d" into baseString
      else
         put "%04d%02d%02dT%02d:%02d:%02d" into baseString
      end if
      put format(baseString, y, mons, d, h, mins, s) into fDate
      if char -3 to -1 of fDate = ":00" then delete char -3 to -1 of fDate
      return fDate & " Z"
   else
      if extended is true then
         put "%04d-%02d-%02dT%02d:%02d:%02d %s" into baseString
      else
         put "%04d%02d%02dT%02d:%02d:%02d %s" into baseString
      end if
      put format(baseString, y, mons, d, h, mins, s, utcOffset) into fDate
      return fDate
   end if
end date_Construct8601

command date_Convert8601 @rfc8601Date
   put date_8601ToInternet (rfc8601Date) into rfc8601Date
end date_Convert8601

function rss_ConvertDate rssDate
   -- "2020-11-05T17:31:22Z"
   set the itemdelimiter to "("
   put item 2 of rssDate into longTimeZone
   delete char -1 of longTimeZone
   put word 1 to -1 of item 1 of rssDate into rssDate
   set the itemdelimiter to comma
   
   put "\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.*" into someReg
   if matchText (rssDate, someReg) is true then
      put date_8601ToInternet (rssDate) into iDate
      return iDate
   end if
   
   put word -1 of rssDate into maybeZone
   put the keys of date_TimeZoneDictionary() into tZones -- TimeZones()
   switch
      case maybeZone is among the lines of tZones
         -- let's hack the last word of rssDate in case it is not in "+0000" format
         put "+0000" into word -1 of rssDate
         convert rssDate to seconds -- to local time
         if rssDate is not a number then return rssDate
         --
         put date_FromUniversalTime (rssDate, maybeZone) into dateInSeconds
         -- put FromUniversalTime (rssDate, maybeZone) into dateInSeconds
         convert dateInSeconds to internet date
         return dateInSeconds
      case matchText (maybeZone, "\+\d\d\d\d")
         convert rssDate to seconds
         if rssDate is not a number then return rssDate
         --
         _AddInternetDateOffset rssDate, maybeZone
         convert rssDate to internet date
         return rssDate
      case matchtext (maybeZone, ".+([\+-]\d\d\d\d)", tzBit)
         -- Wards date format
         -- Tue Nov 03 2020 10:33:17 GMT-0500 => Sat, 7 Nov 2020 22:49:36 +0000
         put word 1 of rssDate into iDate
         put comma && word 3 of rssDate after iDate
         put space & word 2 of rssDate after iDate
         put space & word 4 to 5 of rssDate after iDate
         put space & "+0000" after iDate
         --
         convert iDate to seconds
         if iDate is not a number then return rssDate
         --
         _AddInternetDateOffset iDate, tzBit
         convert iDate to internet date
         return iDate
      default
         -- not sure waht it is?
         return rssDate
   end switch
end rss_ConvertDate

function date_GetSinceSeconds sincePeriod, pSinceSeconds
   -- used for user friendly dispay / input
   if pSinceSeconds is empty then
      put the seconds into pSinceSeconds
   end if
   --
   put word 1 of sincePeriod into sinceNum
   put word 2 of sincePeriod into sinceWord
   --
   switch sinceWord
      case "min"
      case "mins"
      case "minute"
      case "minutes"
         put sinceNum * 60 into periodInSeconds
         break
      case "hour"
      case "hours"
         put sinceNum * 60 * 60 into periodInSeconds
         break
      case "day"
      case "days"
         put sinceNum * 24 * 60 * 60 into periodInSeconds
         break
      case "week"
      case "weeks"
         put sinceNum * 7 * 24 * 60 * 60 into periodInSeconds
         break
   end switch
   subtract periodInSeconds from pSinceSeconds
   --
   return pSinceSeconds
end date_GetSinceSeconds


--> Date
-
function date_GetInternetSeconds iDate
   put word -1 of iDate into iDateOffset
   convert iDate to seconds -- this ignores the last "+0050" iDateOffset bit
   _AddInternetDateOffset iDate, iDateOffset
   return iDate
end date_GetInternetSeconds

private command _AddInternetDateOffset @dateInSeconds, iDateOffset
   put char 2 to 3 of iDateOffset into sHours
   put char 4 to 5 of iDateOffset into sMin
   --
   if char 1 of iDateOffset = "+" then
      add sHours * 60*60 to dateInSeconds
      add sMin * 60 to dateInSeconds
   else
      subtract sHours * 60*60 from dateInSeconds
      subtract sMin * 60 from dateInSeconds
   end if
end _AddInternetDateOffset

function date_FromUniversalTime dateInSeconds, iDateOffset
   -- put FromUniversalTime (rssDate, iDateOffset) into dateInSeconds
   put date_TimeZoneDictionary() into rfc822Array
   put rfc822Array [iDateOffset] into tBit
   if tBit is not empty then
      _AddInternetDateOffset dateInSeconds, tBit
   end if
   return dateInSeconds
end date_FromUniversalTime

function date_TimeZoneDictionary
   /*
   -- https://stackoverflow.com/questions/15247742/rfc-822-date-time-format-in-rss-2-0-feeds-cet-not-accepted
   
   The RFC indicates it only supports a very limited set of symbolic timezone names; just UTC and US ones:
   
   zone        =  "UT"  / "GMT"                ; Universal Time
   ; North American : UT
   /  "EST" / "EDT"                ;  Eastern:  - 5/ - 4
   /  "CST" / "CDT"                ;  Central:  - 6/ - 5
   /  "MST" / "MDT"                ;  Mountain: - 7/ - 6
   /  "PST" / "PDT"                ;  Pacific:  - 8/ - 7
   /  1ALPHA                       ; Military: Z = UT;
   ;  A:-1; (J not used)
   ;  M:-12; N:+1; Y:+12
   / ( ("+" / "-") 4DIGIT )        ; Local differential
   ;  hours+min. (HHMM)
   */
   put "+0000" into rfc822Array ["GMT"]
   put "+0000" into rfc822Array ["UT"]
   --
   put "-0500" into rfc822Array ["EST"]
   put "-0400" into rfc822Array ["EDT"]
   --
   put "-0600" into rfc822Array ["CST"]
   put "-0500" into rfc822Array ["CDT"]
   --
   put "-0700" into rfc822Array ["MST"]
   put "-0600" into rfc822Array ["MDT"]
   --
   put "-0800" into rfc822Array ["PST"]
   put "-0700" into rfc822Array ["PDT"]
   return rfc822Array
end date_TimeZoneDictionary


--> Date | WC3
-

function date_Construct7232 pInternetDate
   if pInternetDate is empty then
      put the internet date into pInternetDate
   end if
   
   put word -1 of pInternetDate into utcOffset
   convert pInternetDate to dateItems
   -- 
   put char 2 to 3 of utcOffset into extraHours
   put char 4 to 5 of utcOffset into extraMin
   if char 1 of utcOffset is "+" then
      add extraHours to item 4 of pInternetDate
      add extraMin to item 5 of pInternetDate
   else
      subtract extraHours from item 4 of pInternetDate
      subtract extraMin from item 5 of pInternetDate
   end if
   --
   convert pInternetDate to internet date
   
   put "GMT" into word -1 of pInternetDate
   return pInternetDate
end date_Construct7232


--> Date | WC3
-
function date_ConstructWc3Datetime someDate
   -- extended is true:  1981-04-05T14:30:30-05:00
   put date_Construct8601 (someDate, true, true) into someDate
   replace space with empty in someDate
   return someDate
end date_ConstructWc3Datetime

command date_Wc3Datetime @revisionDate
   -- https://www.w3.org/TR/NOTE-datetime
   
   replace "T" with return in revisionDate
   put line 1 of revisionDate into someDate
   put line 2 of revisionDate into someTime
   
   replace "-" with comma in someDate
   
   set the itemdelimiter to "+"
   put item 1 of someTime into colonTime
   put item 2 of someTime into colonTimeDifference
   replace ":" with empty in colonTimeDifference
   put format("%04d", colonTimeDifference) into timeDifference
   -- put ":" after char 2 of timeDifference
   
   replace ":" with comma in colonTime
   
   set the itemdelimiter to comma
   put someDate into someDateItems
   put colonTime into item 4 of someDateItems
   
   put 0 into item 7 of someDateItems
   
   convert someDateItems to internet date
   put timeDifference into char -4 to -1 of someDateItems
   -- replace space with empty in someDateItems
   
   put someDateItems into revisionDate
end date_Wc3Datetime



--> Deps
-
