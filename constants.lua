SCALE = 100

G = (2*(10^-3))*SCALE -- Gravitational constant, real value = 6.67*(10^-11)

-- Planets
PL_DENSITY = 5514 -- Planet density: 5514 is density of earth (kg/m^-3)
PL_HP = 100
PL_SPLIT_SPEED = 100
PL_DESTROY_IMP = 100000
PL_DESTROY_RATE = 0.01 -- A planet can be destroyed every x seconds

-- Landers
LD_DENSITY = 675    -- Lander density = density of alumnium (2700) /4, as a lander isn't a solid block of aluminium.
LD_DAMPENING = 70
LD_FIRE_RATE = 0.1  -- Seconds between firing a bullet

landerBody = {-8,-8, 8,-8, 12,8, -12,8}

-- Bullets
BLT_DENSITY = 11340 -- Density of lead
BLT_DIMENSION = 2
BLT_VELOCITY = 800--00
BLT_RECOIL = 1 -- Multiplyer
BLT_HP_DAMAGE = 100

-- Missiles
MS_DENSITY = 675 -- Same as lander density
MS_DAMPENING = 65
MS_DIMENSION_X = 2
MS_DIMENSION_Y = 10
MS_VEL = 100

SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 700

CAMERA_SPEED = 10
CAMERA_SCROLL_ZOOM_SPEED = 14

MAP_WIDTH = 2000 -- Actuall width goes from -2000 to 2000
MAP_HEIGHT = 2000
