module models

pub struct Plane {
pub mut:
	selected_time int
pub:
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