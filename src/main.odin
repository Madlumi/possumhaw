
package main

import "core:fmt"
import "core:math/rand"
import "core:math"
import ray "vendor:raylib"


pegs : []Peg;


W :: 600;
H :: 400;

gs :: 10.0;
grav :: 9.81;

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
tur: Turret = Turret{pos = {0, 200}}
balls : [dynamic]Ball;

mpos: [2]i32;
pewPow : = 200.0;
pew  :: proc(){
   d: [2]i32
   d.x = mpos.x - tur.pos.x
   d.y = mpos.y - tur.pos.y
   l := math.sqrt(f64(d.x*d.x + d.y*d.y))

   b : Ball;
   b.pos.x = f64(tur.pos.x);
   b.pos.y = f64(tur.pos.y);
   b.vel.x = f64(d.x)/l*pewPow;
   b.vel.y = f64(d.y)/l*pewPow;
   b.rad=4;
   b.col=ray.BLACK;

   append(&balls, b);
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

col::proc(a: Circle, b: Circle) -> bool{
   x := a.pos.x - b.pos.x
   y := a.pos.y - b.pos.y
   r := f64(a.rad + b.rad)

   return (x*x + y*y <= r*r)
}

tick :: proc(dt: f64){
   mp := ray.GetMousePosition()
   mpos.x = i32(mp.x)
   mpos.y = i32(mp.y)
   if(ray.IsMouseButtonPressed(ray.MouseButton.LEFT)){pew();}
   for i in 0..<len(balls) { if(balls[i].dead){continue;} 
      balls[i].vel.y+=grav;
      balls[i].pos+=balls[i].vel*dt; 
      if(balls[i].pos.y>H+50){balls[i].dead=true;};
      //check collisons
      for j in 0..<len(pegs) {  if(pegs[j].dead){continue;} 
         if(col(balls[i],pegs[j])){pegs[j].dead=true;}
      }
   }
}
main :: proc(){
   fmt.println("Hewwo Woray.\n");
   ray.InitWindow(W ,H , "HEWWO!!!!");
   ray.SetTargetFPS(60);
   defer ray.CloseWindow();
   init();
   for !ray.WindowShouldClose() {
      tick(1.0/60.0 * gs);
      rend();
	}

}
