PL_DENSITY = 5514 -- Planet density: 5514 is density of earth (kg/m^-3)
LD_DENSITY = 2    -- Lander density.

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
        vx = 33, vy = 0,
        r = 5,
        d = PL_DENSITY
      }
    },
    landers = {

    }
  }
}



function loadLvl(num)
  local lvl = levels[num]
  local planets = {}
  local player1 = nil
  local player2 = nil

  for i=1, #lvl.planets do
    pl = lvl.planets[i]
    table.insert(planets, Planet(pl.id, pl.posx, pl.posy, pl.vx, pl.vy, pl.r, pl.d))
  end

  return planets, player1, player2
end


--lvl.planets[1]
