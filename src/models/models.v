module models
import rand

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
	number_of_runways int
	number_of_planes int
}

// [1] Métodos das structs

pub fn calculate_the_viability_for_landing_in_runway(last_plane_in_the_runway Plane, plane_in_air Plane) int {
	time_distance_between_planes := plane_in_air.target_landing_time - last_plane_in_the_runway.selected_time
	separation_time := last_plane_in_the_runway.separation_time[plane_in_air.id]
	
	// print("\n-----------------\n time distance: " + time_distance_between_planes.str() + " | separation time: " + separation_time.str())

	if time_distance_between_planes >= separation_time {
		return 0
	}
	else if time_distance_between_planes < 0 {
		return last_plane_in_the_runway.selected_time + last_plane_in_the_runway.separation_time[plane_in_air.id] - plane_in_air.target_landing_time
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

pub fn (mut u Solution) validate_solution() bool {
	for runway in u.runways {
		for plane in runway.planes {
			if plane.selected_time < plane.earliest_landing_time || plane.selected_time > plane.latest_landing_time {
				print("[ERROR] Avião " + plane.id.str() + " fora da janela de tempo\n")
				return false
			}
		}
	}
	return true
}

// [2] Movimentos

fn calculate_random_index(number u32, length int) int {
	if length == 0 {
		return 0
	}
	return number % length
}

fn (mut u Solution) recalculate_plane_times() {
	mut dt := 0
	for mut runway in u.runways {
		for index_plane := runway.planes.len - 2; index_plane > 0; index_plane-- {
			dt = calculate_the_viability_for_landing_in_runway(runway.planes[index_plane], runway.planes[index_plane - 1])
			runway.planes[index_plane].selected_time = runway.planes[index_plane].target_landing_time + dt
		}
	}
}

// [2.1] métodos auxiliares para os movimentos

fn (mut u Solution) is_id_of_plane_valid(id_plane int, id_runway int) bool {
	if !(u.is_id_of_runway_valid(id_runway)) {
		return false
	}
	else if id_plane< 0 || id_plane >= u.runways[id_runway].planes.len {
		return false
	}
	return true
}

fn (mut u Solution) is_id_of_runway_valid(id_runway int) bool {
	if id_runway < 0 || id_runway >= u.number_of_runways {
		return false
	}
	return true
}

fn (mut u Solution) is_ids_of_planes_valid(id_plane_A int, id_plane_B int, id_runway_A int, id_runway_B int) bool {
	return u.is_id_of_plane_valid(id_plane_A, id_runway_A) && u.is_id_of_plane_valid(id_plane_B, id_runway_B)
}

fn (mut u Solution) is_ids_of_runways_valid(id_runway_A int, id_runway_B int) bool {
	return u.is_id_of_runway_valid(id_runway_A) && u.is_id_of_runway_valid(id_runway_B)
}

fn (mut u Solution) is_interval_valid(id_runway int, left int, right int) bool {
	if u.is_id_of_runway_valid(id_runway) {
		if left >= 0 || right <= u.runways[id_runway].planes.len	{
			return true
		}
	}
	return false
}


// [2.2] Implementação dos movimentos


pub fn (mut u Solution) swap_planes_between_runways(id_plane_A int, id_runway_A int, id_plane_B int, id_runway_B int) {
	if u.is_ids_of_planes_valid(id_plane_A,id_plane_B,id_runway_A,id_runway_B) && u.is_ids_of_runways_valid(id_runway_A,id_plane_B) {
		plane := u.runways[id_runway_A].planes[id_plane_A]
		u.runways[id_runway_A].planes[id_plane_A] = u.runways[id_runway_B].planes[id_plane_B]
		u.runways[id_runway_B].planes[id_plane_B] = plane
		u.recalculate_plane_times()
		u.validate_solution()
		u.value_of_solution()
	}
}

pub fn (mut u Solution) permute_airplanes(id_plane_A int, id_plane_B int, id_runway int) {
	u.swap_planes_between_runways(id_plane_A, id_runway, id_plane_B, id_runway)
}

pub fn (mut u Solution) random_reinsertion_in_runway(id_plane int, id_runway int) {
	if u.is_id_of_plane_valid(id_plane, id_runway) {
		plane := u.runways[id_runway].planes[id_plane]
		u.runways[id_runway].planes.delete(id_plane)
		index := calculate_random_index(rand.u32(),u.runways[id_runway].planes.len)
		u.runways[id_runway].planes.insert(index,plane)
		u.recalculate_plane_times()
		u.validate_solution()
		u.value_of_solution()
	}
}

pub fn (mut u Solution) random_runway_swap(id_plane int, id_runway int) {
	if u.is_id_of_plane_valid(id_plane,id_runway) {
		plane := u.runways[id_runway].planes[id_plane]
		u.runways[id_runway].planes.delete(id_plane)
		index_runway := calculate_random_index(rand.u32(),u.runways.len)
		index_plane := calculate_random_index(rand.u32(),u.runways[index_runway].planes.len)
		u.runways[index_runway].planes.insert(index_plane,plane)
		u.recalculate_plane_times()
		u.validate_solution()
		u.value_of_solution()
	}
}

pub fn (mut u Solution) partial_inversion(id_runway int, left int, right int) {
	if u.is_interval_valid(id_runway,left,right) {
		mut plane_interval := u.runways[id_runway].planes[left..right]
		u.runways[id_runway].planes.delete_many(left, right - left)
		plane_interval = plane_interval.reverse()
		u.runways[id_runway].planes.insert(left, plane_interval)
		u.recalculate_plane_times()
		u.validate_solution()
		u.value_of_solution()
	}
}


pub fn (mut u Solution) partial_inversion_and_random_runway(id_runway int, left int, right int) {
	if u.is_interval_valid(id_runway,left,right) {
		mut plane_interval := u.runways[id_runway].planes[left..right]
		u.runways[id_runway].planes.delete_many(left, right - left)
		plane_interval = plane_interval.reverse()
		index_runway := calculate_random_index(rand.u32(), u.runways.len)
		index_plane := calculate_random_index(rand.u32(),u.runways[index_runway].planes.len)
		u.runways[index_runway].planes.insert(index_plane, plane_interval)
		u.recalculate_plane_times()
		u.validate_solution()
		u.value_of_solution()
	}
}

