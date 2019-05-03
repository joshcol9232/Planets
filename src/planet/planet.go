package planet

import (
	"github.com/gen2brain/raylib-go/raylib"
	"github.com/gen2brain/raylib-go/raymath"
)

const (
	PLNT_DENSITY = 5000
	TRAIL_PLACEMENT_INTERVAL = 0.2
	TRAIL_NODE_DURATION = 2.0
)

type Planet struct {
	ID int32  // max of 2147483647
	Pos rl.Vector3
	Vel rl.Vector3
	ResForce rl.Vector3
	Radius float32
	Mass float32
	trail []*TrailNode
	trailTimer float32
}

func NewPlanet(ID int32, pos, vel rl.Vector3, rad float32) *Planet {
	return &Planet {
		ID: ID,
		Pos: pos,
		Vel: vel,
		ResForce: rl.NewVector3(0, 0, 0),
		Radius: rad,
		Mass: GetMass(rad, PLNT_DENSITY),
	}
}

func (p *Planet) Draw(col rl.Color) {
	rl.DrawSphere(p.Pos, p.Radius, col)
	p.drawTrail()
}

func (p *Planet) Update(dt, time float32) {
	p.killTrailNodes(time)

	raymath.Vector3Scale(&p.ResForce, dt/p.Mass)
	p.Vel = raymath.Vector3Add(p.Vel, p.ResForce)    // F = ma, a = F / m, a * dt = vel increase, f * dt/mass = vel change
	p.ResForce = rl.NewVector3(0, 0, 0)

	p.Pos.X += p.Vel.X * dt;
	p.Pos.Y += p.Vel.Y * dt;
	p.Pos.Z += p.Vel.Z * dt;

	p.trailTimer += dt
	if p.trailTimer >= TRAIL_PLACEMENT_INTERVAL {
		p.placeTrailNode(time)
	}
}

func (p *Planet) drawTrail() {
	for i := 1; i < len(p.trail); i++ {
		col := rl.Blue
		col.A = 255 - uint8(((rl.GetTime() - p.trail[i].TimeCreated) / TRAIL_NODE_DURATION) * 255)
		rl.DrawLine3D(p.trail[i-1].Pos, p.trail[i].Pos, col)
	}
}

func (p *Planet) placeTrailNode(time float32) {
	p.trail = append(p.trail, &TrailNode {
		Pos: p.Pos,
		TimeCreated: time,
	})
}

func (p *Planet) killTrailNodes(time float32) {
	for i := 0; i < len(p.trail); i++ {
		if time - p.trail[i].TimeCreated >= TRAIL_NODE_DURATION {
			p.removeTrailNode(i)
		}
	}
}

func (p *Planet) removeTrailNode(i int) {
	copy(p.trail[i:], p.trail[i+1:])
	p.trail[len(p.trail)-1] = nil
	p.trail = p.trail[:len(p.trail)-1]
}

func (p *Planet) GetSpeed() float32 {
	return raymath.Vector3Length(p.Vel)
}

func (p *Planet) GetMomentum() rl.Vector3 {
	momentum := p.Vel
	raymath.Vector3Scale(&momentum, p.Mass)
	return momentum
}


func GetMass(rad float32, density float32) float32 {
	return ((4.0 * rl.Pi * (rad * rad * rad))/3.0) * density
}


type TrailNode struct {
	Pos rl.Vector3
	TimeCreated float32
}
