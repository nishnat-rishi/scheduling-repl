local hash = {}

hash.rep = {}

for i = 1, 256 do
  hash.rep[string.format('%c', i)] = i
end

function hash.str(s)
  n = 0
  for c in string.gmatch(s, '%a') do
    n = n + hash.rep[c]
  end
  return n
end

return hash