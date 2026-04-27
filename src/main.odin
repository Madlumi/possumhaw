
package main

import "core:fmt"
import "core:math/rand"
import ray "vendor:raylib"

Peg :: struct {
   pos: [2]i32,
   rad: i32,
   	col: ray.Color,
}

pegs : []Peg;


W :: 600;
H :: 400;

gs :: 10.0;
grav :: 9.81;

Ball   :: struct {
   pos: [2]f64,
   vel: [2]f64,
   rad: i32,
   alive: bool,
   col: ray.Color,
   
}
Turret :: struct  {
   pos: [2]i32,
}
tur: Turret = Turret{pos = {0, 200}}
balls : [dynamic]Ball;
pew  :: proc(){
   b : Ball;
   b.pos.x = f64(tur.pos.x);
   b.pos.y = f64(tur.pos.y);
   b.vel.x = 100;
   b.vel.y = -100;
   b.rad=4;
   b.col=ray.BLACK;
   b.alive=true;

   append(&balls, b);
}


init :: proc(){
   balls = make([dynamic]Ball);
   pegs = make([]Peg, 10);
   	for i in 0..<len(pegs) {
		pegs[i].pos.x = rand.int32_range(200, 500)
		pegs[i].pos.y = rand.int32_range(50, 350)
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
	   for i in 0..<len(pegs) { ray.DrawCircle(pegs[i].pos.x, pegs[i].pos.y, f32(pegs[i].rad), pegs[i].col,);};
	   for i in 0..<len(balls) { if(!balls[i].alive){continue;} ray.DrawCircle(i32(balls[i].pos.x), i32(balls[i].pos.y), f32(balls[i].rad), balls[i].col,);};
		ray.EndDrawing()

}

tick :: proc(dt: f64){
   if(rand.int_max(64)==1){pew();}
   for i in 0..<len(balls) { if(!balls[i].alive){continue;} 
      balls[i].vel.y+=grav;
      balls[i].pos+=balls[i].vel*dt; 
      if(balls[i].pos.y>H+50){balls[i].alive=false;};
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
