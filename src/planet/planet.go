package planet

import (
	"github.com/gen2brain/raylib-go/raylib"
	"github.com/gen2brain/raylib-go/raymath"
	"math"
)

const (
	PLNT_DENSITY = 5000
)

type Planet struct {
	Pos rl.Vector3
	Vel rl.Vector3
	ResForce rl.Vector3
	Radius float32
	Mass float32
}

func NewPlanet(pos, vel rl.Vector3, rad float32) *Planet {
	return &Planet {
		Pos: pos,
		Vel: vel,
		ResForce: rl.NewVector3(0, 0, 0),
		Radius: rad,
		Mass: getMass(rad, PLNT_DENSITY),
	}
}

func getMass(rad float32, density float32) float32 {
	return (4/3) * rl.Pi * float32(math.Pow(float64(rad), 3.0))
}

func (p *Planet) Draw() {
	rl.DrawSphere(p.Pos, p.Radius, rl.RayWhite)
}

func (p *Planet) Update(dt float32) {
	raymath.Vector3Scale(&p.ResForce, dt/p.Mass)
	p.Vel = raymath.Vector3Add(p.Vel, p.ResForce)    // F = ma, a = F / m, a * dt = vel increase, f * dt/mass = vel change
	p.ResForce = rl.NewVector3(0, 0, 0)

	p.Pos.X += p.Vel.X * dt;
	p.Pos.Y += p.Vel.Y * dt;
	p.Pos.Z += p.Vel.Z * dt;
}
