
package main

import "core:fmt"
import ray "vendor:raylib"

rend :: proc(){
		ray.BeginDrawing()
		ray.ClearBackground(ray.RAYWHITE)
		ray.DrawText("HEWWO", 10, 10, 38, ray.PINK)
		ray.EndDrawing()
}
tick :: proc(){

}
main :: proc(){
   fmt.println("Hewwo Woray.\n");
   ray.InitWindow(600,400, "HEWWO!!!!");
   ray.SetTargetFPS(60);
   for !ray.WindowShouldClose() {
      tick();
      rend();
	}

}
