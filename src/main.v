module main
import file_manager {read_data}
import constructive {constructive}
import models {Solution}

fn main() {
	problem := read_data("/home/yan/inteligencia_computacional/ALP/instances/airland1.txt")
	
	solution := constructive(problem,2)
	
}
