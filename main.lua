require "constants"
require "planet"
require "lander"
require "misc"
require "levels"
require "worldFuncs"
require "camera"
require "area"

debugGraph = require "debugGraph"

lg = love.graphics

function love.load()
  love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
	plSize = 1
	love.keyboard.setKeyRepeat(true)
	--landerImg = lg.newImage("assets/lander.png")    -- Load lander image

  fpsGraph = debugGraph:new('fps', 0, SCREEN_HEIGHT-80)
  memGraph = debugGraph:new('mem', 0, SCREEN_HEIGHT-40)

  dampening = true
  VEL_DEBUG = false
  FORCE_DEBUG = false
  mouseX, mouseY = 0, 0
  love.physics.setMeter(SCALE)
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(nil, nil, nil, postSolveCallback)
  bodies = {planets={}, players={}, bullets={}, missiles={}}
  areas = {}
  bodies, areas = loadLvl(1)
  changeHpAfterCollision = {}
  timeOfLastPlDestruction = 0
  paused = false

  camera = Camera(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
end

function love.wheelmoved(x, y)
  camera:changeZoom(y/CAMERA_SCROLL_ZOOM_SPEED)
end

function love.mousepressed(x, y, button)
  mouseX, mouseY = camera:translateXY(x, y)
end

function love.mousereleased(x, y, button)
  x, y = camera:translateXY(x, y)
  if button == 1 then
    table.insert(bodies.planets, Planet({type="p", num=#bodies.planets+1}, mouseX, mouseY, mouseX-x, mouseY-y, plSize, PL_DENSITY))
  end

  if button == 2 then
		--drawGridOfPlanets(mouseX, mouseY, x, y, plSize)
    table.insert(areas, Area({num=#areas+1}, mouseX, mouseY, {r=0.2, g=0.8, b=0}, "Egg", 100, 1))
  end
end

function love.keypressed(key)
  if key == "c" then
    resetWorld()
  elseif inTable(levelNames, key) then
		if love.keyboard.isDown("r") then
      resetWorld()
      bodies = loadLvl(tonumber(key))
		end
  elseif key == "f" then
    FORCE_DEBUG = not FORCE_DEBUG
  elseif key == "v" then
    VEL_DEBUG = not VEL_DEBUG
	elseif key == "=" then
		plSize = plSize + 1
	elseif key == "-" and plSize > 1 then
		plSize = plSize - 1
  elseif key == "t" then
    dampening = not dampening
  elseif key == "b" then
    clearBullets()
  elseif key == "m" then
    bodies.planets[1]:destroy()
  elseif key == "p" then
    paused = not paused
  elseif key == "n" then
    camera:reset()
  elseif key == "y" then
    camera.followPlayer = not camera.followPlayer

  -- player 1 controls
  elseif key == "w" then
    if bodies.players[1] == nil then
      local mX, mY = camera:translateXY(love.mouse.getPosition())
      table.insert(bodies.players, Lander({type="l", num=1, team="capturer"}, mX, mY, 0, 0, 20, 20, LD_DENSITY))
    end

  elseif key == "x" then
    if bodies.players[1] ~= nil and #bodies.players > 1 then
      bodies.players[1].targetOn = not bodies.players[1].targetOn
    end
  elseif key == "space" then
    if bodies.players[1] ~= nil then
      if bodies.players[1].targetOn then
        bodies.players[1]:fireMissile()
      end
    end

	-- player 2 controls
  elseif key == "up" then
		if bodies.players[2] == nil then
			local mX, mY = camera:translateXY(love.mouse.getPosition())
      table.insert(bodies.players, Lander({type="l", num=9999999, team="preventer"}, mX, mY, 0, 0, 20, 20, LD_DENSITY))
    end
  end
end

function love.update(dt)
  if not paused then
    world:update(dt)
    changeHpAfterCollisionFunc()
    checkBulletTimeouts()
    checkSmallPlanetTimeouts()

    for _, j in pairs(bodies) do
      for x=1, #j do
        j[x]:update(dt)
      end
    end

    for i=1, #areas do -- Update areas
      areas[i]:update(dt)
    end
  end

  -- Update the graphs
  fpsGraph:update(dt)
  memGraph:update(dt)

  camera:update()
end

function love.draw()
  lg.push()
    camera:centerOrigin()
    camera:zoomDisplay()
    camera:translateDisplay()
    for _, j in pairs(bodies) do
      for x=1, #j do
        j[x]:draw()
      end
    end

    for i=1, #areas do
      areas[i]:draw()
    end
  lg.pop()

  lg.setColor({1, 1, 1})
  lg.print(love.timer.getFPS(), 10, 10)
  lg.print("Object Count: "..#bodies.planets+#bodies.players+#bodies.bullets+#bodies.missiles, 10, 24)
  --lg.print("Total mass in world: "..tostring(getTotalMassInWorld()), 10, 160)

	lg.print("Size: "..plSize, 10, 96)

  if camera.followPlayer then
    lg.setColor({1, 1, 1})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("Y: Follow player", 10, 82)

  if FORCE_DEBUG then
    lg.setColor({1, 0, 0})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("F: Force debug", 10, 40)

  if VEL_DEBUG then
    lg.setColor({0, 1, 0})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("V: Velocity debug", 10, 54)

  if dampening then
    lg.setColor({1, 1 ,1})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("T: Angular Dampeners", 10, 68)
  lg.setColor({1, 1, 1})


  if #bodies.players < 1 then
		lg.setColor({0, 1, 0})
		lg.print("Player 1 press 'w' to join.", 400, 10)
  elseif #bodies.players < 2 then
		lg.setColor({0, 1, 0})
		lg.print("Player 2 press UP to join.", 400, 10)
	end

  lg.setColor({1, 1, 1})
  fpsGraph:draw()
  memGraph:draw()

  if paused then
    lg.rectangle("fill", SCREEN_WIDTH-30, 10, 10, 30)
    lg.rectangle("fill", SCREEN_WIDTH-50, 10, 10, 30)
  end
end

function drawGridOfPlanets(mouseX, mouseY, x, y, size)
	local num = 10*(1/size)
  for i=0, num do
		for j=0, num do
			table.insert(bodies.planets, Planet({type="p", num=#bodies.planets+1}, mouseX+(i*size*2), mouseY+(j*size*2), mouseX-x, mouseY-y, size, PL_DENSITY))
		end
  end
end

function postSolveCallback(fixture1, fixture2, contact, normalImpulse, tangentImpulse) -- Box2D callback when collisions happen
  currTime = love.timer.getTime()
  local data1, data2 = fixture1:getUserData(), fixture2:getUserData()
  if (data1.userType == "planet" and data2.userType == "bullet") or (data1.userType == "bullet" and data2.userType == "planet") then
    --if (normalImpulse >= PL_DESTROY_IMP) then
    if (data1.userType == "planet") then
      if not data1.parentClass.body:isDestroyed() then
        table.insert(changeHpAfterCollision, {bod=data1.parentClass, change=(-normalImpulse)})
      end
    elseif data2.userType == "planet" then
      if not data2.parentClass.body:isDestroyed() then
        table.insert(changeHpAfterCollision, {bod=data2.parentClass, change=(-normalImpulse)})
      end
    end
    --end
  end

--elseif data1.userType == "lander"
end
