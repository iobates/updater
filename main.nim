# Copyright Tobias Lindgaard
# License GPLv3 or later
import json, os, strutils, times

proc getJson(file:string): string =
  let data = readFile(file)
  return data

let
  parsed = parseJson(getJson("data.json"))

type
  seqString = seq[string]
  


proc checkProjects() =
  for key,val in pairs(parsed):
    try:
      os.setCurrentDir($parsed[key]["dir"].str)
    except:
      var
        path = string($parsed[key]["dir"]).split('/')
        realpath: string
      path.delete(4)
      path.delete(0)
      realpath = path.join("/")
      realpath = "/" & realpath
      echo realpath
      os.setCurrentDir(realpath)
      echo($parsed[key]["repo"].str)
      discard os.execShellCmd("git clone " & $parsed[key]["repo"].str)
      echo("Seems " & $parsed[key]["dir"] & " doesn't exists")

proc whatDay() : WeekDay =
  var lt = getLocalTime(getTime())
  lt.weekday
        

proc strToDay(d: string) : WeekDay =
  if d == "Monday" or d == "monday" or d == "Mon" or d == "mon":
    return dMon
  elif d == "Tuesday" or d == "tuesday" or d == "Tue" or d == "tue":
    return dTue
  elif d == "Wednesday" or d == "wednesday" or d == "Wed" or d == "wed":
    return dWed
  elif d == "Thursday" or d == "thursday" or d == "Thu" or d == "thu":
    return dThu
  elif d == "Friday" or d == "friday" or d == "Fri" or d == "fri":
    return dFri
  elif d == "Saturday" or d == "saturday" or d == "Sat" or d == "sat":
    return dSat
  elif d == "Sunday" or d == "sunday" or d == "Sun" or d == "sun":
    return dSun 

            
proc matchDay(day: string): bool =
  let vday = whatDay()
  if vday == strToDay(day):
    return true
  else:
    return false
    

      
proc listProjects(): seqString =
  var list : seqString
  list = @[]
  for k,v in pairs(parsed):
    list.add(k)
  return list


proc pull(p: string) =
  for k,v in pairs(parsed):
    if p == k:
       echo($parsed[k]["dir"].str)
       os.setCurrentDir($parsed[k]["dir"].str)
       discard os.execShellCmd("git pull")

proc pullall() =
  for k,v in pairs(parsed):
    echo($parsed[k]["dir"].str)
    os.setCurrentDir($parsed[k]["dir"].str)
    discard os.execShellCmd("git pull")


proc moveToProject(p: string) =
  os.setCurrentDir($parsed[p]["dir"].str)
    

proc cronMain() =
  checkProjects()
  for project,v in pairs(parsed):
    for pkey, value in pairs(v):
      if pkey == "update":
        for d, day in pairs(value):
          if matchDay(day.str) or day.str == "all":
            pull(project)



    
proc main() =
  checkProjects()
  echo(listProjects())
  echo("What Project do you want to update?")
  echo("To update all use 'all' or 'a', quit with 'quit' or 'q'")
  let
    input = readline(stdin)
  if input == "all" or input == "a":
    pullall()
  elif input == "quit" or input == "q":
    quit()
  else:
    pull(input)
  main()

cron_main()
# var d = whatDay()
# if d == dSun:
#     echo "Today is ", d



