module models

pub struct Plane {
	pub mut:
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
	pub mut:
	number_of_planes int
	freeze_time int

	planes []Plane
}

struct Runway {
pub mut:
	planes []Plane
pub:
	max_number_of_planes int @[required]
}

pub struct Solution {
pub mut:
	runways []Runway
pub:
	number_of_runways int @[required]
}