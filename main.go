package main

import (
	"github.com/gen2brain/raylib-go/raylib"
	"github.com/gen2brain/raylib-go/raymath"
	"math"
	"fmt"

	"planet"
)

const (
	G = 0.01
)

type Game struct {
	screenDims rl.Vector2
	camera rl.Camera3D
	planetIDCount int32
	selectedPlanetID int32
	selectedPlanet *planet.Planet

	planets []*planet.Planet
}

func NewGame(w, h int32) Game {
	camera := rl.Camera3D{}
	camera.Position = rl.NewVector3(100.0, 100.0, 100.0)
	camera.Target = rl.NewVector3(0.0, 0.0, 0.0)
	camera.Up = rl.NewVector3(0.0, 1.0, 0.0)
	camera.Fovy = 45.0
	camera.Type = rl.CameraPerspective

	rl.SetCameraMode(camera, rl.CameraFree)

	return Game {
		screenDims: rl.NewVector2(float32(w), float32(h)),
		camera: camera,
		selectedPlanetID: -1,
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

		rl.DrawFPS(10, 10)
		if g.selectedPlanetID > -1 {
			g.drawSelectedPlanetInfo()
		}
		rl.EndDrawing()
	}

	rl.CloseWindow()
}

func (g *Game) draw() {
	rl.DrawGrid(50, 500.0)

	for i := 0; i < len(g.planets); i++ {
		col := rl.RayWhite
		if g.planets[i].ID == g.selectedPlanetID {
			col = rl.Lime
			g.camera.Target = g.planets[i].Pos
		}
		g.planets[i].Draw(col)
	}
}

func (g *Game) update(dt float32) {
	for i := 0; i < len(g.planets); i++ {
		for j := 0; j < len(g.planets); j++ { // Update grav force
			if i != j {
				if g.checkForCollision(g.planets[i], g.planets[j]) {
					println("egg")
				}
				iForce, jForce := g.getGravForceBetweenTwoPlanets(g.planets[i], g.planets[j])
				g.planets[i].ResForce = raymath.Vector3Add(g.planets[i].ResForce, iForce)
				g.planets[j].ResForce = raymath.Vector3Add(g.planets[j].ResForce, jForce)
			}
		}

		g.planets[i].Update(dt)
	}

	if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
		g.selectPlanet()
	}
}

func (g *Game) drawSelectedPlanetInfo() {
	rl.DrawText(fmt.Sprintf("ID: %d\nMass: %.2f\nSpeed: %.2f", g.selectedPlanet.ID, g.selectedPlanet.Mass, g.selectedPlanet.GetSpeed()), 10, 30, 20, rl.RayWhite)
}

func (g *Game) addPlanet(pos, vel rl.Vector3, rad float32) {
	g.planets = append(g.planets, planet.NewPlanet(g.planetIDCount, pos, vel, rad))
	if g.planetIDCount < 2147483647 {  // Max value for int32
		g.planetIDCount += 1
	} else {
		g.planetIDCount = 0
	}
}

func (g *Game) removePlanet(ID int32) bool { // returns true if the planet was found and removed
	for i := 0; i < len(g.planets); i++ {
		if g.planets[i].ID == ID {
			g.removePlanetAt(int32(i))
			return true
		}
	}
	return false
}

func (g *Game) removePlanetAt(index int32) {
	g.planets[index] = g.planets[len(g.planets)-1]
	g.planets[len(g.planets)-1] = nil
	g.planets = g.planets[:len(g.planets)-1]
}

func (g *Game) getPlanetByID(ID int32) *planet.Planet {
	index := g.getIndexOfPlanetFromID(ID)
	if index >= 0 {
		return g.planets[index]
	} else {
		return nil
	}
}

func (g *Game) getIndexOfPlanetFromID(ID int32) int {
	for i := 0; i < len(g.planets); i++ {
		if g.planets[i].ID == ID {
			return i
		}
	}
	return -1
}

func (g *Game) selectPlanet() {
	ray := rl.GetMouseRay(rl.GetMousePosition(), g.camera)

	found := false
	for i := 0; i < len(g.planets) && !found; i++ {
		if rl.CheckCollisionRaySphere(ray, g.planets[i].Pos, g.planets[i].Radius + 5) {
			g.selectedPlanetID = g.planets[i].ID
			g.selectedPlanet = g.planets[i]
			found = true
		}
	}

	if !found {
		g.selectedPlanetID = -1
		g.selectedPlanet = nil
	}
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

func (g *Game) checkForCollision(p1, p2 *planet.Planet) bool {
	distVec := raymath.Vector3Subtract(p1.Pos, p2.Pos)
	distSqr := (distVec.X * distVec.X) + (distVec.Y * distVec.Y) + (distVec.Z * distVec.Z)
	radSum := p1.Radius + p2.Radius
	return distSqr <= (radSum * radSum)
	// Above probably more efficient since square root is very expensive compared to squaring
	//return raymath.Vector3Distance(p1.Pos, p2.Pos) <= p1.Radius + p2.Radius
}

const (
	SCREEN_W_DEF = 1280
	SCREEN_H_DEF = 720
)

func main() {
	rl.InitWindow(SCREEN_W_DEF, SCREEN_H_DEF, "Particles")
	//rl.SetTargetFPS(144)

	g := NewGame(SCREEN_W_DEF, SCREEN_H_DEF)
	g.addPlanet(rl.NewVector3(50, 0, 0), rl.NewVector3(0, 10, 30), 0.5)
	g.addPlanet(rl.NewVector3(0, 0, 0), rl.NewVector3(0, 0, 0), 5)

	g.addPlanet(rl.NewVector3(-70, 0, 0), rl.NewVector3(0, -10, -30), 2)

	g.mainLoop()
}
