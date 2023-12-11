module main
import file_manager {read_data}
import constructive {constructive, generate_initial_population}
import spidermonkey {SMO, init}
import os
import time


fn main() {
	problem := read_data(os.args[1])
	start := time.now()
	// mut solution := generate_initial_population(problem, 2, 5)
	mut solution := constructive(problem,1)
	solution.value_of_solution()
	end_constructive := time.now()
	println("Solution Quality: ${solution.global_cost}")
	println("Time spent: ${end_constructive - start}")
	//println("Solution valid? ${solution.validate_solution()} Value ${solution.global_cost}")
	mut smo := init(5, 100)
	smo.set_initial_solution(solution)
	smo.exec()
	end := time.now()
	println("Time spent: ${end - end_constructive}")
}
