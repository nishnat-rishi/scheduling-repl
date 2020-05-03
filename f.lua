----------------------------------------------------------------
--[[
To do list:

  -- Investigate cases where there's a viable slot after sufficient separation for some item to exist, yet that item is not assigned there. (good place to start: last_assignment overshoots frequently and for free range items (5am to 11pm, for example), once it takes up a later value, assignment becomes very limited.)

  (PARTIALLY FIXED)
  -- range limiting doesn't happen as of yet. use 'b' in exclusive range select somehow! (main issue is when b is less than a, we cannot outright reject the item. for example, when a is 10pm and b is 2am, we need 4 hours. but then again,the way we have divided out items, there cannot be generic ranges where b < a for ANY reason! The wraparound point is a myth.)


]]
----------------------------------------------------------------
local hash = require('hash')
math.randomseed(_G.arg[1] and hash.str(_G.arg[1]) or os.time())

local items = require('_items')

local init_time = os.date("*t")
init_time.hour, init_time.min, init_time.sec = 0, 0, 0

local routine = {} -- 1440 items

local function index_difference(i, j)
  if i <= j then
    return j - i
  else
    return (1440 + j) - i
  end
end

-- Returns a value from t which was not previously used (for which _assigned was nil). If every value from t has been assigned, returns a random value.
local function exclusive_select(t)
  local selections = {}
  for i = 1, #t do
    table.insert(selections, i)
  end
  local sel_item = nil
  while #selections > 0 do
    sel_item = t[table.remove(selections, math.random(#selections))]
    if not sel_item._assigned then
      sel_item._assigned = true
      return sel_item
    end
  end
  return t[math.random(#t)]
end

-- finds a slot in routine of size 'size' between a and b
local function exclusive_range_select(size, a, b)
  if a >= b then
    return nil, nil
  end
  a, b = a % 1440, b % 1440
  local i, j, found = a, a, false
  while not found do
    while routine[i] do -- find the first empty slot from a (including a)
      i = (i + 1) % 1440
      j = i
    end
    found = true
    while j ~= (i + size - 1) % 1440 do -- if the empty slot is of size >= size, we have found our slot!
      if routine[j] then -- find a new unoccupied slot
        i = j
        found = false
        break
      end
      j = (j + 1) % 1440
      -- if j == b then
      --   return nil, nil
      -- end
    end
    if found then
      return i, (j + 1) % 1440
    end -- otherwise find a new empty slot
  end
end

local function forward_fill()
  local i = 0
  while not routine[i] do -- find an item
    i = (i + 1) % 1440
  end
  while routine[i] == routine[(i-1)%1440] do -- go to the beginning of the item
    i = (i - 1) % 1440
  end
  local finish = i -- when i == finish, forward_fill is complete
  local cursor = i
  local duration = routine[cursor].variation.duration or routine[cursor].item.duration
  repeat
    if routine[i] then
      if routine[i] ~= routine[(i+1)%1440] then -- i is never 'nil'. i+1 can be nil or another item
        if routine[(i+1)%1440] == nil then
          if index_difference(cursor, (i+1)%1440) < duration._upper then
            routine[(i+1)%1440] = routine[i]
          end
        else
          cursor = (i+1)%1440
          duration = routine[cursor].variation.duration or routine[cursor].item.duration
        end
      end
    else
      if routine[(i+1)%1440] ~= nil then
        cursor = (i+1)%1440
      end
    end
    i = (i+1)%1440
  until i == finish
end

-- local function forward_fill()
--   local i = 1439
--   while true do
--     if routine[i] then
--       local j = i
--       while routine[(j-1)%1440] == routine[j] do
--         j = (j - 1) % 1440
--       end -- after this routine'j' is the starting point, 'i' is the ending point
--       local curr_duration = index_difference(j, i) + 1
--       local duration = routine[j].variation.duration or routine[j].item.duration
--       while curr_duration < duration._upper do
--         i = (i + 1) % 1440
--         if routine[i] then
--           break
--         else
--           routine[i] = routine[(i-1)%1440]
--         end
--         curr_duration = index_difference(j, i) + 1
--       end -- after this, routine[j] will have been forward filled. we'll continue from i = (j - 1) % 1440 (aka i = j; i = (i - 1) % 1440)
--       i = j
--     end
--     i = (i - 1) % 1440
--     if i == 1439 then
--       break
--     end
--   end
-- end
------------------------------------------------------------------

-- Routinize

for _, item in ipairs(items) do -- top-down ranking of items
  if item.slots then -- randomly select item._slots number of variations and assign them. Make sure the ranges are exclusive. When the exclusion is exhausted, choose a range randomly.
    local separation = item._separation
    local last_assignment = nil
    for i = 1, item.slots do
      local variation = exclusive_select(item.variations)
      local ranges = variation.ranges or item.ranges
      local range = exclusive_select(ranges)
      local duration = variation.duration or item.duration
      ----------------------------------------------
      local start, finish = nil, nil
      if last_assignment then
        start, finish = exclusive_range_select(duration._lower, range._start + last_assignment + separation, range._finish)
      else
        start, finish = exclusive_range_select(duration._lower, range._start, range._finish)
      end
      if start then -- current item can be placed!
        local j = start
        local package = {item = item, variation = variation}
        while j ~= finish do
          routine[j] = package
          j = (j + 1) % 1440
        end
        if separation then
          last_assignment = j
        end
      end
      ----------------------------------------------
    end
  else -- assign each and every single variation variation.slots times. Make sure the ranges are exclusive. When the exclusion is exhausted, choose a range randomly.
    local ranges = nil
    local range = nil
    local duration = nil
    local separation = nil

    for _, variation in pairs(item.variations) do
      local last_assignment = nil
      for i = 1, variation.slots do
        ranges = variation.ranges or item.ranges
        range = exclusive_select(ranges)
        duration = variation.duration or item.duration
        separation = variation._separation or item._separation
        ----------------------------------------------
        local start, finish = nil, nil
        if last_assignment then -- last_assignment ONLY exists when separation exists. Hence we can use separation wherever we know last_assignment exists.
         start, finish = exclusive_range_select(duration._lower, range._start + last_assignment + separation, range._finish)
        else -- no last_assignment exists (because no separation exists). hence we go about assigning things as normal.s
          start, finish = exclusive_range_select(duration._lower, range._start, range._finish)
        end
        if start then -- current item can be placed!
          local j = start
          local package = {item = item, variation = variation}
          while j ~= finish do
            routine[j] = package
            j = (j + 1) % 1440
          end
          if separation then -- last_assignment exists
            last_assignment = j
          end
        end
        ----------------------------------------------
      end
    end
  end


end

------------------------------------------------------------------

-- Post routinization activities

forward_fill()

------------------------------------------------------------------

-- Display routine

function index_to_duration_stamp(i)
  local hour, min = i // 60, (i % 60) + 1
  if min == 60 then
    hour, min = hour + 1, 0
  end
  local h_str, m_str = hour > 0 and string.format('%dh', hour) or '', min > 0 and string.format('%dm', min) or ''
  return string.format('%s%s', h_str, m_str)
end

local function index_to_time_stamp(i)
  init_time.hour, init_time.min = i // 60, i % 60
  -- print(_ts(init_time))
  local str = os.date("%a %d/%m/%y %I:%M%p", os.time(init_time))
  init_time.hour, init_time.min = 0, 0
  return str
end

-- f = io.open('routine.txt', 'w')

local curr_ind = 0
local i = 1
print()
while i < 1440 do
  if routine[curr_ind] ~= routine[i] then
    print(string.format('%s\t%s (%s)', index_to_time_stamp(curr_ind), routine[curr_ind] and routine[curr_ind].variation.name or '--', index_to_duration_stamp((i - curr_ind) - 1)))
    -- f:write(string.format('%s\t%s (%s)\n', index_to_time_stamp(curr_ind), routine[curr_ind] and routine[curr_ind].variation.name or '--', index_to_duration_stamp((i - curr_ind) - 1)))
    curr_ind = i
  else
    i = i + 1
  end
end
print(string.format('%s\t%s (%s)', index_to_time_stamp(curr_ind), routine[curr_ind] and routine[curr_ind].variation.name or '--', index_to_duration_stamp((i - curr_ind) - 1)))

-- f:write(string.format('%s\t%s (%s)\n', index_to_time_stamp(curr_ind), routine[curr_ind] and routine[curr_ind].variation.name or '--', index_to_duration_stamp((i - curr_ind) - 1)))

-- io.close(f)




