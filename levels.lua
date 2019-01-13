levels = {
  {  -- Level 1
    planets = {
      { id = {type="p", num=1},
        posx = 500, posy = 350, -- Position
        vx = 0, vy = 0,         -- Velocity
        r = 50,                 -- Radius
        d = PL_DENSITY          -- Density
      },
      { id = {type="p", num=2},
        posx = 300, posy = 200,
        vx = 40, vy = 0,
        r = 5,
        d = PL_DENSITY
      }
    }
  },
  { -- Level 2
    planets = {
      { id = {type="p", num=1},
        posx = 500, posy = 350, -- Position
        vx = 0, vy = 0,         -- Velocity
        r = 200,                -- Radius
        d = PL_DENSITY          -- Density
      }
    }
  },
  { -- Level 3
    planets = {
      { id = {type="p", num=1},
        posx = 500, posy = 350, -- Position
        vx = 0, vy = 0,         -- Velocity
        r = 100,                -- Radius
        d = PL_DENSITY          -- Density
      },
      { id = {type="p", num=2},
        posx = 500, posy = 200,
        vx = 52, vy = 0,
        r = 3,
        d = PL_DENSITY
      },
      { id = {type="p", num=3},
        posx = 500, posy = 500,
        vx = -56, vy = 0,
        r = 3,
        d = PL_DENSITY
      },
      { id = {type="p", num=4},
        posx = 350, posy = 350,
        vx = 0, vy = 65,
        r = 3,
        d = PL_DENSITY
      },
      { id = {type="p", num=5},
        posx = 300, posy = 350,
        vx = 0, vy = 65,
        r = 1,
        d = PL_DENSITY
      },
      { id = {type="p", num=6},
        posx = 650, posy = 400,
        vx = 0, vy = 55,
        r = 1,
        d = PL_DENSITY
      },
      { id = {type="p", num=7},
        posx = 650, posy = 320
        ,
        vx = 0, vy = -60,
        r = 1,
        d = PL_DENSITY
      },
      { id = {type="p", num=8},
        posx = 650, posy = 420,
        vx = 0, vy = 57,
        r = 1,
        d = PL_DENSITY
      },
      { id = {type="p", num=9},
        posx = 650, posy = 400,
        vx = 0, vy = 59,
        r = 1,
        d = PL_DENSITY
      },
      { id = {type="p", num=10},
        posx = 300, posy = 600,
        vx = 45, vy = 0,
        r = 1,
        d = PL_DENSITY
      },
      { id = {type="p", num=11},
        posx = 300, posy = 200,
        vx = -60, vy = 0,
        r = 1,
        d = PL_DENSITY
      },
      { id = {type="p", num=12},
        posx = 320, posy = 120,
        vx = 53, vy = 0,
        r = 5,
        d = PL_DENSITY
      }
    }
  }
}

levelNames = {"1", "2", "3"} -- Active levels

function loadLvl(num)
  local lvl = levels[num]
  local bodies = {planets={}, players={}, bullets={}, missiles={}}

  for i=1, #lvl.planets do
    pl = lvl.planets[i]
    table.insert(bodies.planets, Planet(pl.id, pl.posx, pl.posy, pl.vx, pl.vy, pl.r, pl.d))
  end

  if lvl.landers ~= nil then
    for i=1, #lvl.landers do
      lr = lvl.landers[i]
      table.insert(bodies.players, Lander(lr.id, lr.posx, lr.posy, lr.vx, lr.vy, lr.r, lr.d))
    end
  end

  return bodies
end


--lvl.planets[1]
