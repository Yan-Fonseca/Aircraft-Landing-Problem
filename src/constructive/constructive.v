module constructive
import models {Plane,Solution,Problem,Runway,calculate_the_viability_for_landing_in_runway}
import rand

fn calculate_value_of_index_plane(x int, y int) int {
	if y == 0 {
		return 0
	}
	mut z := x
	if z < 0 {
		z *= -1
	}
	return z % y
}

fn generate_solution(mut planes_queue_original []Plane, percentage f64, number_of_runways int, problem Problem) []Runway {
	mut planes_queue := planes_queue_original.clone()
	mut runways := []Runway{len : number_of_runways} // vetor de pistas vazio (destinado a mostrar os aviões agendados)
	mut aux_pos := 9999
	mut index_runway := 0
	mut viability_values := []int{len : number_of_runways}
	mut random_number_plane := calculate_value_of_index_plane(rand.u32(),u32(percentage * f32(planes_queue.len)))
	mut index_plane := planes_queue.len - 1 - random_number_plane

	index_runway = (rand.u32() % number_of_runways)

	runways[index_runway].planes.prepend(planes_queue[index_plane])
	runways[index_runway].planes[0].selected_time = runways[index_runway].planes[0].target_landing_time
	planes_queue.delete(index_plane)

	for planes_queue.len != 0 {
		random_number_plane = calculate_value_of_index_plane(rand.u32(),u32(percentage * f32(planes_queue.len)))
		index_plane = planes_queue.len - 1 - random_number_plane
		for runway := 0; runway < number_of_runways; runway++ {
			if runways[runway].planes.len > 0 {
				viability_values[runway] = calculate_the_viability_for_landing_in_runway(runways[runway].planes[0],planes_queue[index_plane])
			}
			else {
				viability_values[runway] = 0
			}
		}

		aux_pos = 9999
		for i := 0; i < number_of_runways; i++ {
			if viability_values[i] == 0 {
				aux_pos = 0
				index_runway = i
				break
			}
			else if viability_values[i] > 0 && aux_pos > viability_values[i] {
				aux_pos = viability_values[i]
				index_runway = i
			} 
		}

		runways[index_runway].planes.prepend(planes_queue[index_plane])
		planes_queue.delete(index_plane)
		if runways[index_runway].planes.len == 1 {
			runways[index_runway].planes[0].selected_time = runways[index_runway].planes[0].target_landing_time
		}
		else {
			runways[index_runway].planes[0].selected_time = runways[index_runway].planes[0].target_landing_time + aux_pos
		}
	}

	return runways
}

pub fn generate_initial_population(problem Problem, number_of_runways int, population_size int) []Solution {
	mut solution := Solution{
		number_of_runways : number_of_runways
		number_of_planes : problem.number_of_planes
	}
	mut population := []Solution{}
	percentage := 0.2
	
	mut planes_queue := problem.planes.clone()

	planes_queue.sort(a.target_landing_time > b.target_landing_time) // Ordenando a fila de aviões em voo pelo tempo alvo

	for counter := 0; counter < population_size; counter++ {
		solution.runways = generate_solution(mut planes_queue, percentage, number_of_runways, problem)
		solution.value_of_solution()
		solution.validate_solution()
		population.prepend(solution)
	}

	return population
}




pub fn constructive(problem Problem, number_of_runways int) Solution {
	mut solution := Solution{
		number_of_runways : number_of_runways
		number_of_planes : problem.number_of_planes
	} // Solução inicial vazia
	mut runways := []Runway{len : number_of_runways} // vetor de pistas vazio (destinado a mostrar os aviões agendados)

	mut planes_queue := problem.planes.clone()
	planes_queue.sort(a.target_landing_time > b.target_landing_time) // Ordenando a fila de aviões em voo pelo tempo alvo

	// print("Fila: ")
	// for plane in planes_queue {
	// 	print(plane.id.str() + " - ")
	// }
	// print("\n===============================\n")

	runways[0].planes.prepend(planes_queue.pop()) // adicionando o primeiro avião da fila na pista 1
	runways[0].planes[0].selected_time = runways[0].planes[0].target_landing_time

	mut viability_values := []int{len : number_of_runways}
	mut index := 0
	mut aux_pos := 9999

	for planes_queue.len != 0 {

		for runway := 0; runway < number_of_runways; runway++ {
			if runways[runway].planes.len > 0 {
				viability_values[runway] = calculate_the_viability_for_landing_in_runway(runways[runway].planes[0],planes_queue.last())
			}
			else {
				viability_values[runway] = 0
			}
		}

		// print("---------------------------------\n")
		// print("Avião na fila: " + planes_queue.last().id.str() + "\n")
		// print(viability_values)

		aux_pos = 9999
		for i := 0; i < number_of_runways; i++ {
			if viability_values[i] == 0 {
				aux_pos = 0
				index = i
				break
			}
			else if viability_values[i] > 0 && aux_pos > viability_values[i] {
				aux_pos = viability_values[i]
				index = i
			} 
		}

		runways[index].planes.prepend(planes_queue.pop())
		if runways[index].planes.len == 1 {
			runways[index].planes[0].selected_time = runways[index].planes[0].target_landing_time
		}
		else {
			runways[index].planes[0].selected_time = runways[index].planes[0].target_landing_time + aux_pos
		}
		
		// print("\npista escolhida: " + index.str() + "\n")
	}


	solution.runways = runways
	print("\n=================================\n Pistas \n=================================\n")
	for i in solution.runways {
		for j in i.planes {
			print(j.id.str() + " - ")
		}
		print("\n")
	}

	print("\n=================================\n Fila de aviões deve estar vazia! \n=================================\n")
	print(planes_queue)
	print("\n")

	return solution
}