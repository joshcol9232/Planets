levels = {
  {  -- Level 1
    planets = {
      { id = 1,
        posx = 500, posy = 350, -- Position
        vx = 0, vy = 0,         -- Velocity
        r = 50,                 -- Radius
        d = PL_DENSITY          -- Density
      },
      { id = 2,
        posx = 300, posy = 200,
        vx = 40, vy = 0,
        r = 5,
        d = PL_DENSITY
      }
    },
    landers = {}
  },
  { -- Level 2
    planets = {
      { id = 1,
        posx = 500, posy = 350, -- Position
        vx = 0, vy = 0,         -- Velocity
        r = 200,                -- Radius
        d = PL_DENSITY          -- Density
      }
    },
    landers = {}
  }
}

levelNames = {"1", "2"} -- Active levels

function loadLvl(num)
  local lvl = levels[num]
  local planets = {}
  local player1 = nil
  local player2 = nil

  for i=1, #lvl.planets do
    pl = lvl.planets[i]
    table.insert(planets, Planet(pl.id, pl.posx, pl.posy, pl.vx, pl.vy, pl.r, pl.d))
  end

  for i=1, #lvl.landers do
    lr = lvl.landers[i]
    table.insert(players, Lander(lr.id, lr.posx, lr.posy, lr.vx, lr.vy, lr.r, lr.d))
  end

  return planets, players
end


--lvl.planets[1]
