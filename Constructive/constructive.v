module constructive
import models

struct Runway {
pub mut:
	planes []Plane
pub:
	max_number_of_planes int @[required]
}

pub struct Solution {
pub mut:
	runways []Runway
pub:
	number_of_runways int @[required]
}

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