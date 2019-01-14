SCALE = 100

G = (2*(10^-3))*SCALE -- Gravitational constant, real value = 6.67*(10^-11)

-- Planets
PL_DENSITY = 5514 -- Planet density: 5514 is density of earth (kg/m^-3)
PL_SPLIT_FACTOR = 3 -- The number of chunks the planet splits up into when broken.
PL_SPLIT_SPEED = 10

-- Landers
LD_DENSITY = 675    -- Lander density = density of alumnium (2700) /4, as a lander isn't a solid block of aluminium.
LD_DAMPENING = 65
LD_FIRE_RATE = 0.1  -- Seconds between firing a bullet

-- Bullets
BLT_DENSITY = 11340 -- Density of lead
BLT_DIMENSION = 2
BLT_VELOCITY = 400--00
BLT_RECOIL = 1 -- Multiplyer

-- Missiles
MS_DENSITY = 675 -- Same as lander density
MS_DAMPENING = 65
MS_DIMENSION_X = 2
MS_DIMENSION_Y = 10
MS_VEL = 100

SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 700
