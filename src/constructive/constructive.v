module constructive
import models {Plane,Solution,Problem,Runway}
import rand

pub fn generate_initial_population(problem Problem, number_of_runways int, population_size int) /*[]Solution*/ {
	//mut solution := Solution{number_of_runways : number_of_runways}
	//mut population := []Solution{len : population_size}
	percentage := 0.3

	mut runways := []Runway{len : number_of_runways} // vetor de pistas vazio (destinado a mostrar os aviões agendados)

	mut planes_queue := problem.planes.clone()
	planes_queue.sort(a.target_landing_time > b.target_landing_time) // Ordenando a fila de aviões em voo pelo tempo alvo

	mut random_number_plane := rand.u32() % u32(percentage * f32(planes_queue.len))

	runways[(rand.u32() % number_of_runways)].planes.prepend(planes_queue[planes_queue.len - 1 - random_number_plane])
	print(runways)
}

pub fn constructive(problem Problem, number_of_runways int) Solution {
	mut solution := Solution{number_of_runways : number_of_runways} // Solução inicial vazia
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
				viability_values[runway] = problem.calculate_the_viability_for_landing_in_runway(runways[runway].planes[0],planes_queue.last())
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