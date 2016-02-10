import json
import os
import strutils

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

proc main() =
  echo(listProjects())
  echo("What Project do you want to update?")
  let
    input = readline(stdin)
  if input == "all":
    pullall()
  elif input == "quit" or input == "q":
    quit()
  elif input == "check" or input == "c":
    checkProjects()
  else:
    pull(input)
  main()


main()

