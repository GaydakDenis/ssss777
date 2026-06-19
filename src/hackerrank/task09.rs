use std::env;
use std::fs::File;
use std::io::{self, BufRead, Write};

fn migratoryBirds(arr: &[i32]) -> i32 {
    let mut counts = vec![0; 6];

    for &bird in arr {
        counts[bird as usize] += 1;
    }

    let mut max_count = 0;
    let mut most_frequent_id = 1;

    for id in 1..=5 {
        if counts[id] > max_count {
            max_count = counts[id];
            most_frequent_id = id;
        }
    }

    most_frequent_id as i32
}

fn main() {
    let stdin = io::stdin();
    let mut stdin_iterator = stdin.lock().lines();

    let mut fptr = File::create(env::var("OUTPUT_PATH").unwrap()).unwrap();

    let _arr_count = stdin_iterator.next().unwrap().unwrap().trim().parse::<i32>().unwrap();

    let arr: Vec<i32> = stdin_iterator.next().unwrap().unwrap()
        .trim_end()
        .split(' ')
        .map(|s| s.to_string().parse::<i32>().unwrap())
        .collect();

    let result = migratoryBirds(&arr);

    writeln!(&mut fptr, "{}", result).ok();
}
