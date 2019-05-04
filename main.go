package main

import (
	"github.com/gen2brain/raylib-go/raylib"
	"github.com/gen2brain/raylib-go/raymath"
	"math"
	"fmt"

	"planet"
)

const (
	SCREEN_W_DEF = 1920
	SCREEN_H_DEF = 1080
	FOV = 80

	G = 0.001
	WORKER_COUNT = 512
)

type Game struct {
	screenDims rl.Vector2
	camera rl.Camera3D
	planetIDCount int32
	selectedPlanet *planet.Planet
	trailsEnabled bool

	paused bool

	dt float32
	time float32

	updateJobChannel chan int
	updateDoneChannel chan bool

	deadPlanetIDs []int32

	planets []*planet.Planet
}

func NewGame(w, h int32) *Game {
	camera := rl.Camera3D{}
	camera.Position = rl.NewVector3(100.0, 100.0, 100.0)
	camera.Target = rl.NewVector3(0.0, 0.0, 0.0)
	camera.Up = rl.NewVector3(0.0, 1.0, 0.0)
	camera.Fovy = FOV
	camera.Type = rl.CameraPerspective

	rl.SetCameraMode(camera, rl.CameraFree)

	g := Game {
		screenDims: rl.NewVector2(float32(w), float32(h)),
		camera: camera,
		paused: true,
		trailsEnabled: false,
		planets: []*planet.Planet{},
	}

	g.updateJobChannel = make(chan int, WORKER_COUNT)
	g.updateDoneChannel = make(chan bool)

	for i := 0; i < WORKER_COUNT; i++ {
		go g.updateWorker()
	}

	return &g
}

func (g *Game) mainLoop() {
	for !rl.WindowShouldClose() {
		rl.UpdateCamera(&g.camera)
		g.dt = rl.GetFrameTime()
		g.time = rl.GetTime()
		g.update()

		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)
		rl.BeginMode3D(g.camera)

		g.draw()

		rl.EndMode3D()

		rl.DrawFPS(10, 10)
		if g.selectedPlanet != nil {
			g.drawSelectedPlanetInfo()
		}

		rl.DrawText(fmt.Sprintf("Body num: %d", len(g.planets)), 10, int32(g.screenDims.Y - 30), 20, rl.RayWhite)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}

func (g *Game) draw() {
	rl.DrawGrid(50, 100.0)

	for i := 0; i < len(g.planets); i++ {
		col := rl.RayWhite
		if g.selectedPlanet != nil && g.planets[i].ID == g.selectedPlanet.ID {
			col = rl.Lime
			g.camera.Target = g.planets[i].Pos
		}
		g.planets[i].Draw(col, g.trailsEnabled)
	}
}


func (g *Game) getInput() {
	if rl.IsKeyPressed(rl.KeyP) {
		g.paused = !g.paused
	}

	if rl.IsKeyPressed(rl.KeyT) {
		g.trailsEnabled = !g.trailsEnabled
	}

	if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
		g.selectPlanet()
	}
}

func (g *Game) update() {
	if !g.paused {
		g.removeDeadPlanets()

		for i := 0; i < len(g.planets); i++ {
			g.updateJobChannel<- i
		}

		for i := 0; i < len(g.planets); i++ {
			<-g.updateDoneChannel // Wait for all to be finished
		}
	}

	g.getInput()
}

func (g *Game) updateWorker() {
	for job := range g.updateJobChannel {
		g.updatePlanetFully(job, g.dt, g.time, g.trailsEnabled)
		g.updateDoneChannel <- true
	}
}

func (g *Game) updatePlanetFully(i int, dt, time float32, trails bool) {
	for j := 0; j < len(g.planets); j++ { // Update grav force
		if i != j {
			if g.checkForCollision(g.planets[i], g.planets[j]) {
				g.collide(g.planets[i], g.planets[j])
			} else {
				iForce, jForce := g.getGravForceBetweenTwoPlanets(g.planets[i], g.planets[j])
				g.planets[i].ResForce = raymath.Vector3Add(g.planets[i].ResForce, iForce)
				g.planets[j].ResForce = raymath.Vector3Add(g.planets[j].ResForce, jForce)
			}
		}
	}

	g.planets[i].Update(dt, time, trails)
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

func (g *Game) removePlanetAt(index int) {
	g.planets[index] = g.planets[len(g.planets)-1]
	g.planets[len(g.planets)-1] = nil
	g.planets = g.planets[:len(g.planets)-1]
}

func (g *Game) removeDeadPlanets() {
	for _, id := range g.deadPlanetIDs {
		g.removePlanetByID(id)
	}
}

func (g *Game) getPlanetByID(ID int32) *planet.Planet {
	index := g.getIndexOfPlanetFromID(ID)
	if index >= 0 {
		return g.planets[index]
	} else {
		return nil
	}
}

func (g *Game) removePlanetByID(ID int32) bool {
	index := g.getIndexOfPlanetFromID(ID)
	if index >= 0 {
		g.removePlanetAt(index)
		return true
	} else {
		return false
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
			g.selectedPlanet = g.planets[i]
			found = true
		}
	}

	if !found {
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
	distVec := raymath.Vector3Subtract(p2.Pos, p1.Pos)
	radSum := float64(p1.Radius + p2.Radius)

	if math.Abs(float64(distVec.X)) <= radSum && math.Abs(float64(distVec.Y)) <= radSum && math.Abs(float64(distVec.Z)) <= radSum && radSum < 100 { // Box collision to do a rough check
		distSqr := (distVec.X * distVec.X) + (distVec.Y * distVec.Y) + (distVec.Z * distVec.Z)
		return distSqr <= float32(radSum * radSum)
	} else {
		return false
	}
}

func (g *Game) collide(p1, p2 *planet.Planet) {
	totalMomentum := raymath.Vector3Add(p1.GetMomentum(), p2.GetMomentum())
	totalMass := p1.Mass + p2.Mass
	totalVolume := totalMass/planet.PLNT_DENSITY

	big := p1
	small := p2
	if big.Radius < small.Radius {
		big = p2
		small = p1
	}

	if !(math.Pow(float64(big.Radius/small.Radius), 3) > 2.0) { // If difference in size is not very big, get midpoint of position to set as new position
		big.Pos = rl.NewVector3((big.Pos.X + small.Pos.X)/2, (big.Pos.Y + small.Pos.Y)/2, (big.Pos.Z + small.Pos.Z)/2)
	}

	big.Vel = rl.NewVector3(totalMomentum.X/totalMass, totalMomentum.Y/totalMass, totalMomentum.Z/totalMass)
	big.Radius = float32(math.Pow(float64((3 * totalVolume)/(4 * rl.Pi)), 1.0/3))   // Volume of sphere rearranged for r
	big.Mass = totalMass
	g.deadPlanetIDs = append(g.deadPlanetIDs, small.ID)

	if g.selectedPlanet != nil && g.selectedPlanet.ID == small.ID {
		g.selectedPlanet = big
	}
}


func (g *Game) makeCube(pos rl.Vector3, width, height, depth int, spacing, rad float32) {
	for x := float32(0); x < float32(width) * spacing; x += spacing {
		for y := float32(0); y < float32(height) * spacing; y += spacing {
			for z := float32(0); z < float32(depth) * spacing; z += spacing {
				g.addPlanet(raymath.Vector3Add(pos, rl.NewVector3(x, y, z)), rl.NewVector3(0, 0, 0), rad)
			}
		}
	}
}


func volumeOfSphere(radius float32) float32 {
	return (4.0 * rl.Pi * (radius * radius * radius))/3.0
}


func main() {
	rl.SetConfigFlags(rl.FlagMsaa4xHint)
	rl.SetConfigFlags(rl.FlagWindowUndecorated)
	rl.InitWindow(SCREEN_W_DEF, SCREEN_H_DEF, "Planets")

	g := NewGame(SCREEN_W_DEF, SCREEN_H_DEF)
	/*
	g.addPlanet(rl.NewVector3(50, 0, 0), rl.NewVector3(0, 1, 3), 0.5)
	g.addPlanet(rl.NewVector3(0, 0, 0), rl.NewVector3(0, 0, 0), 5)

	g.addPlanet(rl.NewVector3(-70, 0, 0), rl.NewVector3(0, -10, -30), 2)
	*/

	w := 8
	h := 8
	d := 8
	fmt.Println("Total num:", w*h*d)
	g.makeCube(rl.NewVector3(0.0, 100.0, 0.0), w, h, d, 60, 2)

	g.mainLoop()
}
