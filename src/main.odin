
package main

import "core:fmt"
import "core:math/rand"
import "core:math"
import ray "vendor:raylib"


pingPath :: "res/ping.wav"
ping: ray.Sound
vol : f32 = .7;

pegs : []Peg;


W :: 600;
H :: 400;

gs :: 4.0;
grav :: 9.81*4;
ps : f64 : 1.0/240.0;

Circle :: struct {
   pos: [2]f64,
   rad: i32,
   col: ray.Color,
}

Peg :: struct {
   dead: bool,
   using c: Circle,
}
Ball   :: struct {
   using c: Circle,
   vel: [2]f64,
   dead: bool,
   
}
Turret :: struct  {
   pos: [2]i32,
}
tur: Turret = Turret{pos = {10, 200}}
balls : [dynamic]Ball;

mpos: [2]i32;
pewPow : = 200.0;

pew :: proc(){
   dx := f64(mpos.x - tur.pos.x)
   dy := f64(mpos.y - tur.pos.y)
   v := pewPow
   g := grav

   dist2 := dx*dx + dy*dy
   root := (v*v + g*dy)*(v*v + g*dy) - g*g*dist2

   if(root < 0){
      return // target impossible at this speed
   }

   // smaller time = flatter arc, bigger time = higher arc
   t2 := ((v*v + g*dy) - math.sqrt(root)) / (0.5*g*g)
   if(t2 <= 0){
      return
   }

   t := math.sqrt(t2)

   b : Ball
   b.pos.x = f64(tur.pos.x)
   b.pos.y = f64(tur.pos.y)

   b.vel.x = dx / t
   b.vel.y = (dy - 0.5*g*t*t) / t

   b.rad = 4
   b.col = ray.BLACK

   append(&balls, b)
}


init :: proc(){
   balls = make([dynamic]Ball);
   pegs = make([]Peg, 10);
   	for i in 0..<len(pegs) {
		pegs[i].pos.x = rand.float64_range(200, 500)
		pegs[i].pos.y = rand.float64_range(50, 350)
      pegs[i].rad = rand.int32_range(2, 8)

		c := rand.int_max(3)

		if(c == 0){ pegs[i].col = ray.RED; };
		if(c == 1){ pegs[i].col = ray.GREEN; };
		if(c == 2){ pegs[i].col = ray.BLUE; };
   }
}
rend :: proc(){
		ray.BeginDrawing()
		ray.ClearBackground(ray.RAYWHITE)
		ray.DrawText("HEWWO", 10, 10, 38, ray.PINK)
 ray.DrawCircle(tur.pos.x, tur.pos.y ,32, ray.PURPLE,);
	   for i in 0..<len(pegs) {  if(pegs[i].dead){continue;} ray.DrawCircle(i32(pegs[i].pos.x), i32(pegs[i].pos.y), f32(pegs[i].rad), pegs[i].col,);};
	   for i in 0..<len(balls) { if(balls[i].dead){continue;} ray.DrawCircle(i32(balls[i].pos.x), i32(balls[i].pos.y), f32(balls[i].rad), balls[i].col,);};
		ray.EndDrawing()

}

playPing::proc(){
   pitch := rand.float32_range(0.8, 1.25)
   ray.SetSoundPitch(ping, pitch)
   ray.PlaySound(ping)
}
col :: proc(a: Circle, b: Circle) -> (bool, f64) {
   x := a.pos.x - b.pos.x
   y := a.pos.y - b.pos.y
   r := f64(a.rad + b.rad)

   angle := math.atan2(y, x)

   return x*x + y*y <= r*r, angle
}

bounceAtAngle :: proc(v: [2]f64, ang: f64, eff: f64) -> [2]f64 {
   n: [2]f64;
   n.x = math.cos(ang);
   n.y = math.sin(ang);

   dot := v.x*n.x + v.y*n.y;

   out: [2]f64;
   out.x = v.x - 2*dot*n.x;
   out.y = v.y - 2*dot*n.y;


   return out*eff;
}

dtAc : f64 ;
tick :: proc(dt: f64){
   dtAc+=dt;
      if(ray.IsMouseButtonPressed(ray.MouseButton.LEFT)){pew();}
for ; dtAc > ps; dtAc -= ps {
      mp := ray.GetMousePosition()
      mpos.x = i32(mp.x)
      mpos.y = i32(mp.y)
      for i in 0..<len(balls) { if(balls[i].dead){continue;} 
         balls[i].vel.y+=grav*ps;
         balls[i].pos+=balls[i].vel*ps; 
         if(balls[i].pos.y>H+50){balls[i].dead=true;};
         //check collisons
         for j in 0..<len(pegs) {  if(pegs[j].dead){continue;} 
            hit, ang := col(balls[i], pegs[j])  
            if(hit){ 
               pegs[j].dead = true;
               balls[i].vel = bounceAtAngle(balls[i].vel, ang, .7);
               playPing()
            }
         }
         hit, ang := col(balls[i], Circle{ pos={W ,balls[i].pos.y}, rad=0 } )  
            if(hit){ 
               balls[i].vel = bounceAtAngle(balls[i].vel, ang, .7);
               balls[i].pos.x-=1;
               playPing()
            }
         hit, ang = col(balls[i], Circle{ pos={0 ,balls[i].pos.y}, rad=0 } )  
            if(hit){ 
               balls[i].vel = bounceAtAngle(balls[i].vel, ang, .7);
               balls[i].pos.x+=1;
               playPing()
            }

      }
   }
}
main :: proc(){
   fmt.println("Hewwo Woray.\n");
   ray.InitWindow(W ,H , "HEWWO!!!!");
   ray.SetTargetFPS(60);
   ray.InitAudioDevice()
   defer ray.CloseAudioDevice()
   ping = ray.LoadSound(pingPath)
   defer ray.UnloadSound(ping)

   ray.SetSoundVolume(ping, vol)
   defer ray.CloseWindow();
   init();
   for !ray.WindowShouldClose() {
      tick(1.0/60.0 * gs);
      rend();
   }

}
