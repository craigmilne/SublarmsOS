function openRednet()
  local listOfSides = rs.getSides()
  local listOfPoss = {}
  local count = 0
  while true do
    count = count + 1
   
    if peripheral.isPresent(tostring(listOfSides[count])) and peripheral.getType(listOfSides[count]) == "modem" then
      table.insert(listOfPoss, tostring(listOfSides[count]))
    end

    if count == 6 and table.maxn(listOfPoss) == 0 then
      return nil
    end

    if count == 6 and table.maxn(listOfPoss) ~= 0 then
      rednet.open(listOfPoss[1])
      return listOfPoss[1]
    end
  end
end

