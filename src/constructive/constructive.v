module constructive
import models {Plane,Solution,Problem,Runway}



pub fn constructive(problem Problem, number_of_runways int) Solution {
	mut solution := Solution{number_of_runways : number_of_runways} // Solução inicial vazia
	mut runways := []Runway{len : number_of_runways} // vetor de pistas vazio (destinado a mostrar os aviões agendados)

	mut planes_queue := problem.planes.clone()
	planes_queue.sort(a.target_landing_time > b.target_landing_time) // Ordenando a fila de aviões em voo pelo tempo alvo

	runways[0].planes.prepend(planes_queue.pop()) // adicionando o primeiro avião da fila na pista 1
	runways[0].planes[0].selected_time = runways[0].planes[0].target_landing_time

	mut viability_values := []int{len : number_of_runways}
	mut index := 0
	mut aux_pos := 9999

	for counter := 0; counter < planes_queue.len; counter++ {

		for runway := 0; runway < number_of_runways; runway++ {
			if runways[runway].planes.len > 0 {
				viability_values[runway] = problem.calculate_the_viability_for_landing_in_runway(runways[runway].planes[0],planes_queue.last())
			}
			else {
				viability_values[runway] = 0
			}
		}

		for i := 0; i < number_of_runways; i++ {
			if viability_values[i] == 0 {
				aux_pos = 0
				index = i
				break
			}
			else if viability_values[i] > 0 && viability_values[i] < aux_pos {
				aux_pos = viability_values[i]
				index = i
			} 
		}

		runways[index].planes.prepend(planes_queue.pop())
		counter -= counter
		runways[index].planes[0].selected_time = runways[index].planes[0].target_landing_time + aux_pos
	}


	solution.runways = runways
	print("\n")
	for i in solution.runways {
		for j in i.planes {
			print(j.id.str() + " - ")
		}
		print("\n")
	}

	return solution
}