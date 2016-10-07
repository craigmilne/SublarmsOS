-- Write a new variable file, basically a JSON with slightly different rules
function writeVariableFile(fileName, vars)
  local str = textutils.serialize(vars)
  local handle = assert(fs.open(fileName, "w"), "Failed to save file ("..fileName..")")
  handle.write(str)
  handle.close()
end

-- Read said variable file
function readVariableFile(fileName)
  local handle = assert(fs.open(fileName, "r"), "Failed to read file ("..fileName..")")
  local input = handle.readAll()
  handle.close()
  local vars = textutils.unserialize(input)
  return vars
end
