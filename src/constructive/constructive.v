module constructive
import models

fn verify_maxtime(planes []Plane) int {
	mut maxTime := 0
	for plane in planes {
		if plane.latest_landing_time > maxTime {
			maxTime = plane.latest_landing_time
		}
	}

	return maxTime
}

pub fn constructive(planes []Plane, number_of_runways int, dt int) Solution {
	mut solution := Solution{number_of_runways: number_of_runways}
	mut runway := Runway{max_number_of_planes: planes.len}

	mut queue := []Plane{len: planes.len}

	maxTime := verify_maxtime(planes)
	for time := 0; time < maxTime; time+=dt {
		
	}


	return solution
}