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
	mut solution2,is_valid := solution.group_swap(0,1,0,0,1)
	print("\n\n---------------------\n")
	print(solution2)
	print("\n\n")
	print("\n\n---------------------\n")
	print(solution)
	print("\n\n")
	solution2.validate_solution()
}
