module main
import file_manager {read_data}
import constructive {constructive, generate_initial_population}

fn main() {
	problem := read_data("/home/yan/inteligencia_computacional/ALP/instances/airland1.txt")
	
	// mut solution := generate_initial_population(problem, 2, 5)
	mut solution := constructive(problem,2)
	solution.value_of_solution()
	//print("Valor da solução atual: " + solution.global_cost.str() + "\n")

	print("---------------------\n")
	print(solution)
	print("\n\n")
	solution.partial_inversion_and_random_runway(0,0,4)
	print("\n\n---------------------\n")
	print(solution)
	print("\n\n")
	solution.validate_solution()
}
