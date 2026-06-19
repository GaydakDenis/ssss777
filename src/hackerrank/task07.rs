use std::env;
use std::fs::File;
use std::io::{self, BufRead, Write};

fn gcd(mut x: i32, mut y: i32) -> i32 {
    while y != 0 {
        let temp = y;
        y = x % y;
        x = temp;
    }
    x
}

fn lcm(x: i32, y: i32) -> i32 {
    if x == 0 || y == 0 { 0 } else { (x * y) / gcd(x, y) }
}

fn getTotalX(a: &[i32], b: &[i32]) -> i32 {
    let mut lcm_a = a[0];
    for &num in a.iter().skip(1) {
        lcm_a = lcm(lcm_a, num);
    }

    let mut gcd_b = b[0];
    for &num in b.iter().skip(1) {
        gcd_b = gcd(gcd_b, num);
    }

    let mut count = 0;
    let mut current_multiple = lcm_a;
    
    while current_multiple <= gcd_b {
        if gcd_b % current_multiple == 0 {
            count += 1;
        }
        current_multiple += lcm_a;
    }

    count
}

fn main() {
    let stdin = io::stdin();
    let mut stdin_iterator = stdin.lock().lines();

    let mut fptr = File::create(env::var("OUTPUT_PATH").unwrap()).unwrap();

    let first_multiple_input: Vec<String> = stdin_iterator.next().unwrap().unwrap()
        .split(' ')
        .map(|s| s.to_string())
        .collect();

    let _n = first_multiple_input[0].trim().parse::<i32>().unwrap();
    let _m = first_multiple_input[1].trim().parse::<i32>().unwrap();

    let arr: Vec<i32> = stdin_iterator.next().unwrap().unwrap()
        .trim_end()
        .split(' ')
        .map(|s| s.to_string().parse::<i32>().unwrap())
        .collect();

    let brr: Vec<i32> = stdin_iterator.next().unwrap().unwrap()
        .trim_end()
        .split(' ')
        .map(|s| s.to_string().parse::<i32>().unwrap())
        .collect();

    let total = getTotalX(&arr, &brr);

    writeln!(&mut fptr, "{}", total).ok();
}
