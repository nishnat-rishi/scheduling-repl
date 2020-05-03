----------------------------------------------------------
-- Helper user data
local math_options = {'Complex Numbers', 'Differential Geometry', 'Z Transforms', 'Fourier Transforms'}
local flow_pages = math.random(312)
local cc_pages = math.random(899)
-- local klein_selections = math.random() -- {{'I', math.random(325)}, {'II', math.random(267)}, {'III', math.random(318)}}; local curr_klein = klein_selections[math.random(#klein_selections)]; string.format('Felix Klein Part %s, pages (%d, %d)', curr_klein[1], curr_klein[2], curr_klein[2]+1)
----------------------------------------------------------
local items = {

  {category = 'TODAY\'S TASKS',
    variations = {
      {
        name = 'Work on CN Video Script',
        duration = {lower = '1h30m', upper = '2h30m'},
        slots = 1,
        ranges = {
          {start = '7pm', finish = '11pm'}
        }
      },
      -- {
      --   name = '',
      --   duration = {lower = '', upper = ''},
      --   slots = 1,
      --   ranges = {
      --     start = ''
      --   }
      -- }
    }
  },

  {category = 'Study',
    duration = {lower = '30m', upper = '1h'},
    ranges = {
      {start = '8am', finish = '10am'},
      {start = '12pm', finish = '2pm'},
      {start = '4pm', finish = '6pm'},
      {start = '7pm', finish = '9pm'},
    },
    slots = 3,
    variations = { -- any 3 / day
      {name = 'CN'},
      {name = 'AI'},
      {name = 'CGM'},
      {name = 'EG'},
      {name = 'OM'},
      {name = 'MP'},
    }
  },

  {category = 'Hygeine',
    variations = {
      {
        name = 'Brush teeth',
        duration = {lower = '5m', upper = '7m'},
        slots = 2,
        ranges = {
          {start = '6am', finish = '7am'},
          {start = '9pm', finish = '11pm'}
        }
      },
      {
        name = 'Bathe',
        separation = '4h',
        duration = {lower = '1h30m', upper = '2h30m'},
        slots = 1,
        ranges = {
          {start = '7am', finish = '11pm'}
        }
      },
    }
  },

  {category = 'Food',
    duration = {lower = '30m', upper = '45m'},
    slots = 3,
    variations = {
      {
        name = 'Breakfast',
        ranges = {
          {start = '8am', finish = '11am'}
        }
      },
      {
        name = 'Lunch',
        ranges = {
          {start = '1pm', finish = '3:30pm'}
        }
      },
      {
        name = 'Dinner',
        ranges = {
          {start = '8pm', finish = '10pm'}
        }
      },
    },
  },

  {category = 'Responsibilities',
    variations = {
      {
        name = 'Broom 1st floor',
        slots = 1,
        duration = {lower = '20m', upper = '30m'},
        ranges = {
          {start = '6am', finish = '8am'}
        }
      },
      {
        name = 'Sit beside nani',
        slots = 2,
        duration = {lower = '10m', upper = '30m'},
        ranges = {
          {start = '9am', finish = '1pm'},
          {start = '3pm', finish = '9pm'}
        }
      },
      {
        name = 'Wash utensils',
        slots = 1,
        duration  ={lower = '20m', upper = '30m'},
        ranges = {
          {start = '9pm', finish = '11pm'}
        }
      },
      {
        name = 'Wipe kitchen floor',
        slots = 1,
        duration = {lower = '10m', upper = '20m'},
        ranges = {
          {start = '7am', finish = '12pm'}
        }
      }
    }
  },

  {category = 'Recreation',
    separation = '20m',
    duration = {lower = '10m', upper = '40m'},
    ranges = {
      {start = '7am', finish = '9pm'}
    },
    slots = 4,
    variations = {
      {
        name = string.format('John Bird\'s Math, (%s)', math_options[math.random (#math_options)]),
      },
      {
        name = string.format('Read pages (%d, %d) of Mihaly Csikszentmihalyi\'s Compendium', flow_pages, flow_pages + 1),
      },
      {name = 'Code this system!'},
      {
        name = string.format('Read pages (%d, %d) of Code Complete', cc_pages, cc_pages+1)
      },
      {
        name = 'Felix Klein\'s mathematics series (Part I)'
      }
    }
  },

  -- {category = 'Miscellaneous',
  --   ranges = {start = '7am', finish = '10pm'},
  --   variations = {
  --     {
  --       name = '',
  --       duration = ''
  --     }
  --   }
  -- }
}


-- PRIORITIZING IS DONE BY USER INPUTTING VARIOUS CATEGORIES IN ORDER. PRIORITIZING VIA FUNCTIONS IS DISCARDED.

-- items.overrides = {
--   function (first, second)
--     return first.category == 'Study' and second.category == 'Food' -- Food is second class to study
--   end,
-- }

local function to_24h_format(hour, min, sec, meridian) -- expects meridian to be lowercase
  if meridian then -- input is in 12h format
    if meridian == 'pm' then
      if hour ~= 12 then
        hour = hour + 12
      end
    elseif hour == 12 then
      hour = 0
    end
  end
  return hour, min, sec
end

local function parse_duration_as_minutes(dur_str)
  local t1, t2 = string.match(dur_str:lower(), "(%d*[h]*%a*)(%d*[m]*%a*)")
  -- policy: if nothing is given, assume 1minute. otherwise we accept 1h, 1h2m, 20m.
  local h_index = string.find(t1, 'h')
  local hour, m_index, min = nil, nil, nil
  if h_index then -- t1 is in hours, t2 is automatically assumed to be in mins
    hour = tonumber(string.sub(t1, 0, h_index-1))
    m_index = string.find(t2, 'm')
    min = m_index and tonumber(string.sub(t2, 0, m_index-1)) or 0
  else 
    m_index = string.find(t1, 'm')
    hour, min = 0, m_index and tonumber(string.sub(t1, 0, string.find(t1, 'm')-1)) or 1
  end
  return hour * 60 + min
end

local function parse_time_as_index(time_str)
  local hour, min, sec, meridian = string.match(time_str:lower(), "(%d+):*(%d*):*(%d*)(%am)")
  -- provides 0 min or 0 sec if user is using short notations such as 12PM or 12:04PM
  hour, min, sec = tonumber(hour), min == '' and 0 or tonumber(min), sec == '' and 0 or tonumber(sec)
  hour, min, sec = to_24h_format(hour, min, sec, meridian)
  return hour * 60 + min
  -- return {hour = hour, min = min, sec = 0}
end

local function _ts(t)
  local s = '{'
  for k, v in pairs(t) do
    if type(v) ~= 'table' then
      s = s .. k .. '=' .. string.format('%s', v)
    else
      s = s .. k .. '=' .. _ts(v)
    end
    if next(t, k) then
      s = s .. ', '
    end
  end
  s = s .. '}'
  return s
end

-- traverse whole table and adds hidden representations of duration and ranges in numeric forms
-- don't consider the overrides for now (make sure items doesn't have a non-numeric index)
local function add_numeric_repr(t)
  for k, v in pairs(t) do
    if k == 'separation' then
      t._separation = parse_duration_as_minutes(v)
    end
    if k == 'duration' then
      v._lower = parse_duration_as_minutes(v.lower)
      v._upper = parse_duration_as_minutes(v.upper)
    elseif k == 'ranges' then
      for _, range in pairs(v) do
        range._start = parse_time_as_index(range.start)
        range._finish = parse_time_as_index(range.finish)
      end
    elseif type(v) == 'table' then
      add_numeric_repr(v)
    end
  end
end

local function compile_checks(t)
  for k, v in pairs(t) do
    if k == 'duration' then
      if not (v._upper and v._lower) then
        error(string.format('CUSTOM_ERROR: numeric representations of \'upper\' or \'lower\' or both are missing! (lower: %s, upper: %s)', v.lower, v.upper))
      end
      if v._upper < v._lower then
        error('CUSTOM_ERROR: lower is more than upper.')
      end
    end
    if k == 'ranges' then
      for _, range in pairs(v) do
        if not (range._finish or range._start) then
          error(string.format('CUSTOM_ERROR: numeric representations of \'start\' or \'finish\' or both are missing! (start: %s, finish: %s)', range.start, range.finish))
        end
        if range._finish < range._start then
          error('CUSTOM_ERROR: item finishes before it starts (finish < start).')
        end
      end
    end
    if k ~= 'duration' and k ~= 'ranges' and type(v) == 'table' then
      compile_checks(v)
    end
  end
end

local function assign(items)

end

add_numeric_repr(items)
compile_checks(items)
assign(items)

-- print(_ts(items)) -- Debugging help

return items