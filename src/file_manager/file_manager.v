module file_manager
import os
import models {Problem, Plane}

fn find_sizes(str []string) ([]int, int) {
	mut index := 0
	mut sizes := []int{len: 2}
	mut jumps := 0
	for i := 0; i < str.len; i += 1 {
		if str[i].int() != 0 {
			sizes[index] = str[i].int()
			index += 1
		}	
		else {
			jumps += 1
		}
		if(index == 2) {
			return sizes, jumps
		}
	}
	return sizes, jumps
}

pub fn read_data(path string) Problem {
	mut problem := Problem{}
	constraints_size := 6
	view_content := os.read_file(path) or {
        panic('error reading file $path')
        return problem
    }
	mut str := view_content.replace("\u000C", "").replace("\u000A", "").trim(" ").split(" ")
	mut sizes, jumps := find_sizes(str)
	mut planes := []Plane{len: sizes[0]}
	problem.number_of_planes = sizes[0]
	problem.freeze_time = sizes[1]
	mut ct := 0
	mut pointer := 0
	for j := 0; j < sizes[0]; j += 1 {
		planes[j].separation_time = []int{len: sizes[0]}
	}
	for i := 0 + jumps + 2; i < str.len; i += 1 {
		if str[i].int() == 0 {
			continue
		}	
		if ct == 0 {
			planes[pointer].appearance_time = str[i].int()
		}
		else if ct == 1 {
			planes[pointer].earliest_landing_time = str[i].int()
		}
		else if ct == 2 {
			planes[pointer].target_landing_time = str[i].int()
		}
		else if ct == 3 {
			planes[pointer].latest_landing_time = str[i].int()
		}
		else if ct == 4 {
			planes[pointer].penalty_for_landing_before_target = str[i].f32()
		}
		else if ct == 5 {
			planes[pointer].penalty_for_landing_after_target = str[i].f32()
		}
		else {
			planes[pointer].separation_time[ct - constraints_size] = str[i].int()
		}
		ct += 1
		if ct == constraints_size + problem.number_of_planes {
			ct = 0
			pointer += 1
		}
	}
	print(planes)
	return problem
}