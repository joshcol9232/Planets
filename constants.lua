SCALE = 100

G = (2*(10^-3))*SCALE -- Gravitational constant, real value = 6.67*(10^-11)

-- Planets
PL_DENSITY = 5514 -- Planet density: 5514 is density of earth (kg/m^-3)
PL_HP = 100
PL_MIN_IMP_TO_DAMAGE = 10000 -- minimum impulse required to do damage. This prevents bullets in-between planets causing them to split repeatedly.
PL_SPLIT_SPEED = 100
PL_DESTROY_RATE = 0--.01 -- A planet can be destroyed every x seconds
PL_CHANCE_OF_SECOND_SPLIT = 10  -- 1/x chance of planet splitting again after it has been split already. -- more realistic splitting.
PL_TIMEOUT_THRESHOLD_R = 2 -- If a planet has a radius below or equal to this number then it despawns after a certain amount of time.
PL_TIMEOUT = 4
PL_JOIN_TIME = 0.1 -- Time it takes for planets to join

-- Landers
LD_DENSITY = 675    -- Lander density = density of alumnium (2700) /4, as a lander isn't a solid block of aluminium.
LD_DAMPENING = 70
LD_FIRE_RATE = 0.1  -- Seconds between firing a bullet

landerBodyDraw = {-5,-5, 5,-5, 12,8, 13,15, 8,9, 0,10, -8,9, -13,15, -12,8} -- For drawing only
landerBodyP1 =   {-5,-5, 5,-5, 12,8, 13,15, 8,9,       -8,9, -13,15, -12,8}  -- Physics objects - max of 8 verticies

-- Bullets
BLT_DENSITY = 11340 -- Density of lead
BLT_DIMENSION = 2
BLT_VELOCITY = 400--00
BLT_RECOIL = 1 -- Multiplyer
BLT_TIMEOUT = 4 -- Number in seconds before bullets despawn.

-- Missiles
MS_DENSITY = 675 -- Same as lander density
MS_DAMPENING = 65
MS_DIMENSION_X = 2
MS_DIMENSION_Y = 10
MS_VEL = 100

-- HP bar
HPBAR_OPEN_TIME = 5
HPBAR_FADE_RATE = 1  -- How much the transparency (alpha) changes per second when fading

CAMERA_SPEED = 10
CAMERA_SCROLL_ZOOM_SPEED = 14
CAMERA_ROTATE_SPEED = math.pi/200

MAP_WIDTH = 2000 -- Actuall width goes from -2000 to 2000
MAP_HEIGHT = 2000

DEFAULT_SCREEN_WIDTH = 1000
DEFAULT_SCREEN_HEIGHT = 700
