module main
import file_manager {read_data}
import constructive {constructive, generate_initial_population}

fn main() {
	problem := read_data("/home/iamthemage/Documentos/Aircraft-Landing-Problem/instances/airland1.txt")
	
	mut solution := generate_initial_population(problem, 2, 5)
	//mut solution := constructive(problem,2)
	//solution.value_of_solution()
	//print("Valor da solução atual: " + solution.global_cost.str() + "\n")

	//print("---------------------\n")
	//solution.validate_solution()
}
