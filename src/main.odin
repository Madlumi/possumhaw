
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

Ball   :: struct {
   pos: [2]i32,
   rad: i32,
   col: ray.Color,
   
}
Turret :: struct  {
   pos: [2]i32,
}
tur: Turret = Turret{pos = {0, 200}}
balls : []Ball;


init :: proc(){
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
pew  :: proc(){}
rend :: proc(){
		ray.BeginDrawing()
		ray.ClearBackground(ray.RAYWHITE)
		ray.DrawText("HEWWO", 10, 10, 38, ray.PINK)
 ray.DrawCircle(tur.pos.x, tur.pos.y ,32, ray.PURPLE,);
	   for i in 0..<len(pegs) { ray.DrawCircle(pegs[i].pos.x, pegs[i].pos.y, f32(pegs[i].rad), pegs[i].col,);};
		ray.EndDrawing()

}
tick :: proc(){

}
main :: proc(){
   fmt.println("Hewwo Woray.\n");
   ray.InitWindow(600,400, "HEWWO!!!!");
   ray.SetTargetFPS(60);
   defer ray.CloseWindow();
   init();
   for !ray.WindowShouldClose() {
      tick();
      rend();
	}

}
