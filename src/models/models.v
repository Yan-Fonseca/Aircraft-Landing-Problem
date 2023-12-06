module models

pub struct Plane {
	pub mut:
	id int
	appearance_time int

	selected_time int

	earliest_landing_time int
	target_landing_time int
	latest_landing_time int

	penalty_for_landing_before_target f32
	penalty_for_landing_after_target f32

	separation_time []int
}

pub struct Problem {
	pub mut:
	number_of_planes int
	freeze_time int

	planes []Plane
}

pub struct Runway {
pub mut:
	planes []Plane
pub:
	max_number_of_planes int @[required]
}

pub struct Solution {
pub mut:
	runways []Runway
	global_cost f64
pub:
	number_of_runways int @[required]
}

// Métodos

pub fn (u Problem) calculate_the_viability_for_landing_in_runway(last_plane_in_the_runway Plane, plane_in_air Plane) int {
	time_distance_between_planes := plane_in_air.target_landing_time - last_plane_in_the_runway.selected_time
	separation_time := last_plane_in_the_runway.separation_time[plane_in_air.id]
	
	if time_distance_between_planes >= separation_time {
		return 0
	}

	return (last_plane_in_the_runway.selected_time + separation_time) - plane_in_air.target_landing_time
}

pub fn (mut u Solution) value_of_solution() {
	mut value := 0.0

	for runway in u.runways {
		for plane in runway.planes {
			if plane.selected_time < plane.target_landing_time {
				value += (plane.target_landing_time - plane.selected_time) * plane.penalty_for_landing_before_target
			}
			else if plane.selected_time > plane.target_landing_time {
				value += (plane.selected_time - plane.target_landing_time) * plane.penalty_for_landing_after_target
			}
		}
	}

	u.global_cost = value
}

pub fn (mut u Solution) validate_solution() {
	for runway in u.runways {
		for plane in runway.planes {
			print("id:" + plane.id.str() + " - Target time: " + plane.target_landing_time.str() + " - selected: " + plane.selected_time.str() + "\n")
		}
		print("======================================\n")
	}
}