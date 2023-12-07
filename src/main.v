module main
import file_manager {read_data}
import constructive {constructive}
import models {Solution}

fn main() {
	problem := read_data("/home/yan/inteligencia_computacional/ALP/instances/airland1.txt")
	
	mut solution := constructive(problem,2)
	solution.value_of_solution()
	print("Valor da solução atual: " + solution.global_cost.str() + "\n")

	print("---------------------\n")
	solution.validate_solution()
}
