module spidermonkey
import math
import rand

import models {Solution, copy_solution, Runway}

pub struct SMO {
	pub mut:
	pop_pot int
	accuracy f64
	current_best_evaluation f64
	current_best_solution Solution
	fitness []f64
	gpoint [][]f64
	probabilities []f64
	local_limit int
	global_limit int
	iterations int = 10
	global_cost_unchanged int

	fit []f64
	min_cost []f64

	best_pos []f64

	group int = 1
	leaders_solutions []Solution
	leaders_quality []f64
	all_solutions []Solution
	func_evals int
	partitions int = 1
	max_partitions int = 6

	probability f64 = 0.2



	associated_solution []Solution

	mut:
	pop_size i64
	initial_solution Solution
	current_solution Solution
	movements_size int
}

pub fn generate_random_array(size i64, upper_bound int) []int {
	mut rands := []int{len: int(size)}
	for i := 0; i < size; i += 1 {
		rands[i] = rand.int_in_range(0, upper_bound) or {0}
	}
	return rands
}

pub fn select_movement(sol Solution, index int) (Solution, f64) {
	mut solution := copy_solution(sol)
	//println("Movement index: ${index}")
	if index == 0 {
		number_of_runways := sol.number_of_runways
		number_of_planes := sol.number_of_planes
		rands_planes := generate_random_array(2, number_of_planes)
		rands_runways := generate_random_array(1, number_of_runways)
		mut new_solution, is_valid := solution.permute_airplanes(rands_planes[0], rands_planes[1], rands_runways[0])
		mut cost := new_solution.global_cost
		if is_valid == false {
			cost = math.max_f64
		}
		return new_solution, cost
	}
	else if index == 1 {
		number_of_runways := sol.number_of_runways
		number_of_planes := sol.number_of_planes
		rands_planes := generate_random_array(1, number_of_planes)
		rands_runways := generate_random_array(1, number_of_runways)
		mut new_solution, is_valid := solution.random_reinsertion_in_runway(rands_planes[0], rands_runways[0])
		mut cost := new_solution.global_cost
		if is_valid == false {
			cost = math.max_f64
		}
		return new_solution, cost
	}
	else {
		number_of_runways := sol.number_of_runways
		number_of_planes := sol.number_of_planes
		left := generate_random_array(1, number_of_planes)[0]
		mut right := generate_random_array(1, number_of_planes)[0]
		runway := generate_random_array(1, number_of_runways)[0]
		mut new_solution, is_valid := solution.partial_inversion(runway, left, right)
		mut cost := new_solution.global_cost
		if is_valid == false {
			cost = math.max_f64
		}
		return new_solution, cost
	}
}

pub fn init(pop_pot int, iterations int) SMO {
	mut res := SMO{}
	res.pop_pot = pop_pot
	res.calculate_population_size()
	res.iterations = iterations
	res.leaders_solutions = []Solution{len: int(res.pop_size)}
	res.all_solutions = []Solution{len: int(res.pop_size)}
	res.leaders_quality = []f64{len: int(res.pop_size), init: math.max_f64}
	res.probabilities = []f64{len: int(res.pop_size)}
	return res
}

pub fn (mut smo SMO) generate_population() {
	rands := generate_random_array(smo.pop_size, 5)
	mut current_best := math.max_f64
	for i := 0; i < rands.len; i++ {
		solution, cost := select_movement(smo.initial_solution, rands[i])
		smo.all_solutions[i] = solution
		smo.all_solutions[i].global_cost = cost
		if cost < current_best {
			current_best = cost
			smo.current_best_evaluation = cost
			smo.current_solution = solution
			smo.leaders_solutions[0] = solution
			smo.leaders_quality[0] = cost
		}
	}
}

fn find_group(index int, groups int, size int) int {
	mut group := int((index - 1) / size)
	if group >= groups {
		group = groups - 1
	}
	return group
}

pub fn (mut smo SMO) print_all_lens() {
	for i := 0; i < smo.all_solutions.len; i += 1 {
		println(smo.all_solutions[i].number_of_planes)
	}
}

pub fn (mut smo SMO) local_learning() {
	for i := 0; i < smo.pop_size; i += 1 {
		group_index := find_group(i, smo.group, int(smo.pop_size / smo.group))
		random_spidermonkey_in_group := rand.int_in_range(group_index * int(smo.pop_size / smo.group), (group_index + 1) * int(smo.pop_size / smo.group)) or {group_index * int(smo.pop_size / smo.group)}
		rand_1 := rand.int_in_range(0, 5) or {2}
		first_cut := f64(f64(rand_1) / 10)
		second_cut := 0.7 - first_cut
		first_pivot := int(f64(smo.all_solutions[i].number_of_planes) * first_cut)
		second_pivot := int(f64(smo.all_solutions[i].number_of_planes) * second_cut)
		mut new_solution := Solution{
			number_of_runways : 1
			number_of_planes : smo.all_solutions[i].number_of_planes
		} // Solução inicial vazia
		mut new_runways := []Runway{len : 1}
		for j := 0; j < first_pivot; j += 1 {
			new_runways[0].planes.prepend(smo.all_solutions[random_spidermonkey_in_group].runways[0].planes[j])
		}
		mut leader_index := int(group_index * (int(smo.all_solutions[i].number_of_planes / smo.group)))

		for leader_index >= smo.pop_size {
			leader_index -= 1
		}

		for j := first_pivot; j < second_pivot; j += 1 {
			new_runways[0].planes.prepend(smo.all_solutions[leader_index].runways[0].planes[j])
		}

		for j := second_pivot; j < smo.all_solutions[i].number_of_planes; j += 1 {
			new_runways[0].planes.prepend(smo.all_solutions[i].runways[0].planes[j])
		}

		new_solution.runways = new_runways
		smo.all_solutions[i] = new_solution
		smo.all_solutions[i].value_of_solution()
	}
}

pub fn (mut smo SMO) global_leader() {
	for i := 0; i < smo.group; i += 1 {
		mut working_solution := smo.leaders_solutions[i]
		if working_solution.global_cost < smo.current_best_evaluation {
			smo.current_best_evaluation = working_solution.global_cost
			smo.current_best_solution = working_solution
		}
	}
}

pub fn (mut smo SMO) calculate_probabilities() {
	for i := 0; i < smo.pop_size; i += 1 {
		smo.probabilities[i] = ((0.9*(smo.all_solutions[i].global_cost / smo.current_best_evaluation)) + 0.1) / 100
	}
}

pub fn (mut smo SMO) global_learning() {
	for i := 0; i < smo.pop_size; i += 1 {
		if rand.f64() < smo.probabilities[i] {
			rand_1 := rand.int_in_range(0, 5) or {2}
			first_cut := f64(f64(rand_1) / 10)
			first_pivot := int(f64(smo.all_solutions[i].number_of_planes) * first_cut)
			mut new_solution := Solution{
				number_of_runways : 1
				number_of_planes : smo.all_solutions[i].number_of_planes
			} // Solução inicial vazia
			mut new_runways := []Runway{len : 1}
			if smo.all_solutions[i].runways.len == 0 || smo.current_best_solution.runways.len == 0 || smo.all_solutions[i].runways[0].planes.len == 0 || smo.current_best_solution.runways[0].planes.len == 0 {
				continue
			}
			for j := 0; j < first_pivot; j += 1 {
				new_runways[0].planes.prepend(smo.all_solutions[i].runways[0].planes[j])
			}
			for j := first_pivot; j < smo.all_solutions[i].number_of_planes; j += 1 {
				new_runways[0].planes.prepend(smo.current_best_solution.runways[0].planes[j])
			}

			new_solution.runways = new_runways
			new_solution.value_of_solution()
			if new_solution.global_cost < smo.current_best_evaluation {
				smo.current_best_solution = new_solution
				smo.current_best_evaluation = new_solution.global_cost
			}
		}
	}
}

pub fn (mut smo SMO) local_leader() {
	for i := 0; i < smo.group; i += 1 {
		for j := 0; j < smo.pop_size; j += 1 {
			group_index := find_group(j, smo.group, int(smo.pop_size / smo.group))
			mut working_solution := smo.all_solutions[j]
			mut basic_cost := working_solution.global_cost

			if working_solution.global_cost < smo.leaders_quality[group_index] {
				smo.leaders_solutions[group_index] = working_solution
				smo.leaders_quality[group_index] = basic_cost
			}
		}
	}
}

pub fn (mut smo SMO) set_initial_solution(sol Solution) {
	smo.initial_solution = sol
	smo.current_solution = sol
}

pub fn (mut smo SMO) calculate_population_size() {
	smo.pop_size = math.powi(2, smo.pop_pot)
}

pub fn (mut smo SMO) exec() {
	smo.generate_population()
	mut index := 0
	mut global_cost := smo.initial_solution.global_cost
	for smo.group < smo.max_partitions && smo.iterations > index {
		//println("Number of groups: ${smo.group}")
		if smo.global_cost_unchanged >= 5 {
			smo.group += 1
			smo.global_cost_unchanged = 0
		}
		smo.local_learning()
		smo.local_leader()
		smo.calculate_probabilities()
		smo.global_leader()
		smo.global_learning()
		if smo.current_best_evaluation == global_cost {
			smo.global_cost_unchanged += 1
		}
		else {
			global_cost = smo.current_best_evaluation
			smo.global_cost_unchanged = 0
		}
		index += 1
	}

	println("Best founded solution: ${smo.current_best_evaluation} and is valid ${smo.current_best_solution.validate_solution()}")
}
