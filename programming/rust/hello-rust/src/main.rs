// Import env module from the standard library.
use std::env;
// Import the FromStr trait which includes the from_str method.
use std::str::FromStr;

fn main() {
    let mut numbers = Vec::new();

    // The env::args function returns an iterator, here we skip the first element
    // of the args since it's the name of the program.
    for arg in env::args().skip(1) {
        // Converting the numbers in the args from strings and adding them to
        // the numbers vector.

        // The from_str returns a Result value which can be Ok(v) or Err(e). If
        // the value is Ok the expect function simply returns the value; if it's
        // Err it prints the message inside the call (expect(msg)) and the error
        // (the format outputed is -> msg: e) and exits the program immediatly.

        numbers.push(u64::from_str(&arg).expect("error parsing argument"));
    }

    if numbers.len() == 0 {
        eprintln!("Usage: gcd NUMBER ...");
    }
    let mut d = numbers[0];
    for m in &numbers[1..] {
        d = gcd(d, *m);
    }

    println!("The greatest common divisor of {:?} is {}", numbers, d);
}

// Euclid's algorithm for greatest common divisor

fn gcd(mut n: u64, mut m: u64) -> u64 {
    assert!(n != 0 && m != 0);
    while m != 0 {
        if m < n {
            let t = m;
            m = n;
            n = t;
        }
        m = m % n;
    }
    return n;
}

#[test]
fn test_gcd() {
    assert_eq!(gcd(14, 15), 1);
    assert_eq!(gcd(2 * 3 * 5 * 11 * 17, 3 * 7 * 11 * 13 * 19), 3 * 11);
}
