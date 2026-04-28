
package main

import "core:fmt"
import "core:strings"
import "core:math/rand"
import "core:math"
import ray "vendor:raylib"


pathWosh:: "res/wosh.wav"
playerWosh: ray.Sound
pingPath :: "res/ping.wav"
ping: ray.Sound

vol : f32 = .7;
pegs : []Peg;
maxBalls : i32 : 9;
ballC : i32;
fail : bool;
level : i32;
hitt : bool;


W :: 600;
H :: 400;

gs :: 4.0;
grav :: 9.81*4;
ps : f64 : 1.0/240.0;

Circle :: struct {
   pos: [2]f64,
   rad: f32,
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

aimVel :: proc() ->  [2]f64 {
   dx := f64(mpos.x - tur.pos.x)
   dy := f64(mpos.y - tur.pos.y)
   v := pewPow
   g := grav

   dist2 := dx*dx + dy*dy
   root := (v*v + g*dy)*(v*v + g*dy) - g*g*dist2
   if(root < 0){ return {v*.50,v*.50} }

   t2 := ((v*v + g*dy) - math.sqrt(root)) / (0.5*g*g)
   if(t2 <= 0){ return  {v*.50,v*.50} }

   t := math.sqrt(t2)

   vel: [2]f64
   vel.x = dx / t
   vel.y = (dy - 0.5*g*t*t) / t

   return vel
}
drawPath :: proc(){
   vel := aimVel()

   for i in 0..<800 {
      if(i%8 < 4){ continue; }

      t0 := f64(i) * ps  * 2 
      t1 := f64(i+1) * ps * 2

      x0 := f64(tur.pos.x) + vel.x*t0
      y0 := f64(tur.pos.y) + vel.y*t0 + 0.5*grav*(t0*t0)

      x1 := f64(tur.pos.x) + vel.x*t1
      y1 := f64(tur.pos.y) + vel.y*t1 + 0.5*grav*t1*t1

      ray.DrawLine(i32(x0), i32(y0), i32(x1), i32(y1), ray.GRAY)
   }
}

pew :: proc(){
   if(fail){  level=0; newLevel(); fail = false; return;}
   if (ballC>0){ballC-=1;}else{ fail= true; return;}
   vel := aimVel()

   b : Ball;
   b.pos.x = f64(tur.pos.x);
   b.pos.y = f64(tur.pos.y);
   b.vel = vel;
   b.rad = 7;
   b.col = ray.BLACK;
   b.dead = false;

   append(&balls, b);
}


newLevel :: proc(){
   delete(balls);
   ballC=maxBalls;
   level= level+1;
   delete(pegs);
   balls = make([dynamic]Ball);
   pegs = make([]Peg, level*10);
   	for i in 0..<len(pegs) {
		pegs[i].pos.x = rand.float64_range(200, 500)
		pegs[i].pos.y = rand.float64_range(50, 350)
      pegs[i].rad = rand.float32_range(4, 32)

		c := rand.int_max(3)

		if(c == 0){ pegs[i].col = ray.RED; };
		if(c == 1){ pegs[i].col = ray.GREEN; };
		if(c == 2){ pegs[i].col = ray.BLUE; };
   }
}
init :: proc(){
   newLevel();
}
rend :: proc(){
		ray.BeginDrawing()
		ray.ClearBackground(ray.RAYWHITE)


      ray.DrawCircle(tur.pos.x, tur.pos.y ,32, ray.PURPLE,);

	   for i in 0..<len(pegs) {  if(pegs[i].rad<0){continue;} ray.DrawCircle(i32(pegs[i].pos.x), i32(pegs[i].pos.y), f32(pegs[i].rad), pegs[i].col,);};
	   for i in 0..<len(balls) { if(balls[i].dead){continue;} ray.DrawCircle(i32(balls[i].pos.x), i32(balls[i].pos.y), f32(balls[i].rad), balls[i].col,);};
      drawPath()
      if(!fail){
         //ui, balls
         os, _ := strings.repeat("o", int(ballC)); defer delete(os)
            ray.DrawText( fmt.ctprintf("=> %s", os), 10, 10, 38, ray.PURPLE)
            //ui, level
            ray.DrawText( fmt.ctprintf("Lvl: %d", level), 10, 10+40, 38, ray.PURPLE)
      }else{
         ray.DrawText( fmt.ctprintf("SCORE: %d", level), 50, 150, 72, ray.PURPLE)
      }
		ray.EndDrawing()

}

playPing::proc(){
   pitch := rand.float32_range(0.8, 1.25)
   ray.SetSoundPitch(ping, pitch)
   ray.PlaySound(ping)
   hitt=true;
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

noBalls :: proc() -> bool{
   for j in 0..<len(balls) { if(!balls[j].dead){ return false; } }
   return true;
}
noPegs :: proc() -> bool{
   for j in 0..<len(pegs) {  if(!pegs[j].dead){return false;} }
   return true;
}
dtAc : f64 ;
tick :: proc(dt: f64){
   dtAc+=dt;
   
   if(!noPegs() && noBalls()&& ray.IsMouseButtonPressed(ray.MouseButton.LEFT)){pew();}
   for ; dtAc > ps; dtAc -= ps {
   

   for j in 0..<len(pegs) { if(pegs[j].dead){ pegs[j].rad-=f32(ps)*.5 ; pegs[j].rad*=.99; } }
      mp := ray.GetMousePosition()
      mpos.x = i32(mp.x)
      mpos.y = i32(mp.y)
      for i in 0..<len(balls) { if(balls[i].dead){continue;} 
         balls[i].vel.y+=grav*ps;
         balls[i].pos+=balls[i].vel*ps; 
         //dead ball
         if(balls[i].pos.y>H+5){
            balls[i].dead=true;
            ray.PlaySound(playerWosh);
            hitt=false;
            };
         //check collisons
         if(hitt){
            hit, ang := col(balls[i], Circle{ pos={f64(tur.pos.x),f64(tur.pos.y)}, rad=32} )  
               if(hit){ 
                  balls[i].dead=true;
                  ballC+=1;
                  ray.PlaySound(playerWosh);
            hitt=false;
               }
         }
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
   if(noPegs() && noBalls()){newLevel();

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
   playerWosh= ray.LoadSound(pathWosh)
   defer ray.UnloadSound(playerWosh)

   ray.SetSoundVolume(ping, vol)
   defer ray.CloseWindow();
   init();
   for !ray.WindowShouldClose() {
      tick(1.0/60.0 * gs);
      rend();
   }

}
