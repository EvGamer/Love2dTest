function _unpackRecursion(table, index)
  if index >= #table then
    return table[index]
  end
  return table[index], _unpackRecursion(table, index + 1)
end

function unpack(table, start)
  return _unpackRecursion(table, start or 1)
end

return unpack