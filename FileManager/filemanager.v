module filemanager
import os 

pub struct Plane {
	id int
	appearance_time int

	earliest_landing_time int
	target_landing_time int
	latest_landing_time int

	penalty_for_landing_before_target f32
	penalty_for_landing_after_target f32

	separation_time []int
}


pub struct Problem {
	number_of_planes int
	freeze_time int

	planes []Plane
}

pub fn read_data(path string) Problem {
	mut counter := 0
	lines := read_lines(path)
	for line in lines { 
		// realizar a leitura dos arquivos
	}
}