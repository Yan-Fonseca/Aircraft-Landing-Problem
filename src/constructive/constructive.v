module constructive
import models {Plane,Solution,Problem,Runway}



pub fn constructive(problem Problem, number_of_runways int) Solution {
	mut solution := Solution{number_of_runways : number_of_runways} // Solução inicial vazia
	//mut runways := []Runway{len : problem.number_of_planes} // vetor de pistas vazio (destinado a mostrar os aviões agendados)

	mut planes := problem.planes.clone()
	planes.sort(a.target_landing_time > b.target_landing_time) // Ordenando a fila de aviões em voo pelo tempo alvo

	for plane in planes {
		print(plane.id.str() + " - " + plane.target_landing_time.str() +"\n")
	}

	return solution
}