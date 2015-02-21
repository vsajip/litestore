import
  parseopt2,
  parsecfg,
  streams,
  strutils,
  logging
import
  types,
  utils

const cfgfile = "litestore.nimble".slurp

var 
  file*, address*, version*, appname*: string
  port*: int
  operation = opRun
  directory = ""
  readonly = false
  purge = false
  logLevel = lvlInfo
  
var f = newStringStream(cfgfile)
if f != nil:
  var p: CfgParser
  open(p, f, "litestore.nimble")
  while true:
    var e = next(p)
    case e.kind
    of cfgEof:
      break
    of cfgKeyValuePair:
      case e.key:
        of "version":
          version = e.value
        of "appame":
          appname = e.value
        of "port":
          port = e.value.parseInt
        of "address":
          address = e.value
        of "file":
          file = e.value
        else:
          discard
    of cfgError:
      fail(1, "Configuration error.")
    else: 
      discard
  close(p)
else:
  fail(2, "Cannot process configuration file.")

let
  usage* = appname & " v" & version & " - Lightweight REST Document Store" & """
  (c) 2015 Fabio Cevasco

  Usage:
    LS [-p:<port> -a:<address>] [<file>] [--pack:<directory> | --unpack:<directory>] 

  Options:
    -a, --address     Specify address (default: 0.0.0.0).
    --export          Export the previously-packed specified directory to the current directory.
    -h, --help        Display this message.
    --import          Import the specified directory (Store all its contents).
    -l, --log         Specify the log level: debug, info, warn, error, fatal, none (default: info)
    -p, --port        Specify port number (default: 9500).
    --purge           Delete exported files (used in conjunction with --export).
    -r, --readonly    Allow only data retrieval operations.
    -v, --version     Display the program version.
"""

for kind, key, val in getOpt():
  case kind:
    of cmdLongOption, cmdShortOption:
      case key:
        of "address", "a":
          if val == "":
            fail(100, "Address not specified.")
          address = val
        of "port", "p":
          if val == "":
            fail(101, "Port not specified.")
          port = val.parseInt
        of "log", "l":
          if val == "":
            fail(102, "Log level not specified.")
          try:
            logLevel = logging.LevelNames.find(val.toUpper).Level
          except:
            fail(103, "Invalid log level '$1'" % val)
        of "import":
          if val == "":
            fail(104, "Directory to import not specified.")
          operation = opImport
          directory = val
        of "export":
          if val == "":
            fail(105, "Directory to export not specified.")
          operation = opExport
          directory = val
        of "purge":
          purge = true
        of "version", "v":
          echo version
          quit(0)
        of "help", "h":
          echo usage
          quit(0)
        of "readonly", "r":
          readonly = true
        else:
          discard
    of cmdArgument:
      file = key
    else:
      discard

var LS*: LiteStore

LS.port = port
LS.address = address
LS.operation = operation
LS.file = file
LS.purge = purge
LS.directory = directory
LS.appversion = version
LS.readonly = readonly
LS.appname = appname

# Initialize loggers

logging.handlers.add(newConsoleLogger(logLevel, "$date $time - "))
logging.handlers.add(newFileLogger("litestore.log.txt", fmAppend, logLevel, fmtStr = "$date $time - "))
