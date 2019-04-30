package main

import (
	"github.com/gen2brain/raylib-go/raylib"
	"github.com/gen2brain/raylib-go/raymath"
	"math"

	"planet"
)

const (
	G = 0.5
)

type Game struct {
	screen_dims rl.Vector2
	camera rl.Camera3D

	planets []*planet.Planet
}

func NewGame(w, h int32) Game {
	camera := rl.Camera3D{}
	camera.Position = rl.NewVector3(300.0, 300.0, 300.0)
	camera.Target = rl.NewVector3(0.0, 0.0, 0.0)
	camera.Up = rl.NewVector3(0.0, 1.0, 0.0)
	camera.Fovy = 45.0
	camera.Type = rl.CameraPerspective

	rl.SetCameraMode(camera, rl.CameraFree)

	return Game {
		screen_dims: rl.NewVector2(float32(w), float32(h)),
		camera: camera,
		planets: []*planet.Planet{},
	}
}

func (g *Game) mainLoop() {
	for !rl.WindowShouldClose() {
		rl.UpdateCamera(&g.camera)
		g.update(rl.GetFrameTime())

		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)

		rl.BeginMode3D(g.camera)
		g.draw()

		rl.EndMode3D()

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

func (g *Game) draw() {
	rl.DrawGrid(50, 200.0)

	for i := 0; i < len(g.planets); i++ {
		g.planets[i].Draw()
	}
}

func (g *Game) update(dt float32) {
	for i := 0; i < len(g.planets); i++ {
		g.planets[i].Update(dt)

		for j := 0; j < len(g.planets); j++ { // Update grav force
			if i != j {
				iForce, jForce := g.getGravForceBetweenTwoPlanets(g.planets[i], g.planets[j])
				g.planets[i].ResForce = raymath.Vector3Add(g.planets[i].ResForce, iForce)
				g.planets[j].ResForce = raymath.Vector3Add(g.planets[j].ResForce, jForce)
			}
		}
	}
}

func (g *Game) addPlanet(pos, vel rl.Vector3, rad float32) {
	g.planets = append(g.planets, planet.NewPlanet(pos, vel, rad))
}

func (g *Game) getGravForceBetweenTwoPlanets(p1, p2 *planet.Planet) (rl.Vector3, rl.Vector3) {
	dist := raymath.Vector3Distance(p1.Pos, p2.Pos)
	if dist > p1.Radius + p2.Radius {
		angleX := float64(raymath.Vector2Angle( rl.NewVector2(p1.Pos.X, p1.Pos.Y), rl.NewVector2(p2.Pos.X, p2.Pos.Y)) * rl.Deg2rad)
		angleY := float64(raymath.Vector2Angle( rl.NewVector2(p1.Pos.Y, p1.Pos.Z), rl.NewVector2(p2.Pos.Y, p2.Pos.Z)) * rl.Deg2rad)
		angleZ := float64(raymath.Vector2Angle( rl.NewVector2(p1.Pos.Z, p1.Pos.Y), rl.NewVector2(p2.Pos.Z, p2.Pos.Y)) * rl.Deg2rad)

		forceMag := (G * p1.Mass * p2.Mass)/(dist * dist)
		force := rl.NewVector3(0, 0, 0)
		force.X = forceMag * float32(math.Cos(angleX))
		force.Y = forceMag * float32(math.Cos(angleY))
		force.Z = forceMag * float32(math.Cos(angleZ))

		return force, rl.NewVector3(-force.X, -force.Y, -force.Z)
	} else {
		return rl.NewVector3(0, 0, 0), rl.NewVector3(0, 0, 0)
	}
}


const (
	SCREEN_W_DEF = 1280
	SCREEN_H_DEF = 720
)

func main() {
	rl.InitWindow(SCREEN_W_DEF, SCREEN_H_DEF, "Particles")
	rl.SetTargetFPS(144)

	g := NewGame(SCREEN_W_DEF, SCREEN_H_DEF)
	g.addPlanet(rl.NewVector3(0, 0, 0), rl.NewVector3(0, 10, 30), 2)
	g.addPlanet(rl.NewVector3(50, 0, 0), rl.NewVector3(0, 0, 0), 20)

	g.mainLoop()
}
