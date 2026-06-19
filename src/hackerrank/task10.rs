use std::env;
use std::fs::File;
use std::io::{self, BufRead, Write};
use std::collections::HashSet;

fn sockMerchant(_n: i32, ar: &[i32]) -> i32 {
    let mut unmatched_socks = HashSet::new();
    let mut pairs_count = 0;

    for &sock in ar {
        if unmatched_socks.contains(&sock) {
            unmatched_socks.remove(&sock);
            pairs_count += 1;
        } else {
            unmatched_socks.insert(sock);
        }
    }

    pairs_count
}

fn main() {
    let stdin = io::stdin();
    let mut stdin_iterator = stdin.lock().lines();

    let mut fptr = File::create(env::var("OUTPUT_PATH").unwrap()).unwrap();

    let n = stdin_iterator.next().unwrap().unwrap().trim().parse::<i32>().unwrap();

    let ar: Vec<i32> = stdin_iterator.next().unwrap().unwrap()
        .trim_end()
        .split(' ')
        .map(|s| s.to_string().parse::<i32>().unwrap())
        .collect();

    let result = sockMerchant(n, &ar);

    writeln!(&mut fptr, "{}", result).ok();
}
