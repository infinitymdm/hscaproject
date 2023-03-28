use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    // Fail if not enough args
    let expected_args_size: usize = 7;
    if &args.len() < &expected_args_size {
        panic!("Usage: gdiv numerator denominator initial-value iterations prec prec_f");
    }

    // Read in args
    let n: f64 = args.get(1).unwrap().parse().unwrap();
    let d: f64 = args.get(2).unwrap().parse().unwrap();
    let r: f64 = args.get(3).unwrap().parse().unwrap();
    let i: i32 = args.get(4).unwrap().parse().unwrap();
    let p: usize = args.get(5).unwrap().parse().unwrap();
    let pf: usize = args.get(6).unwrap().parse().unwrap();

    // Adjust internal precision
    let ip = p as i32;
    let ipf = pf as i32;

    // Round input numbers
    let n = rne(n, ipf);
    let d = rne(d, ipf);

    // Determine actual quotient
    let q = n/d;

    // Print state
    println!("N = {:.15} = 1.{:pf$b}", n, (n-1.0) as i64);
    println!("D = {:.15} = 1.{:pf$b}", d, (d-1.0) as i64);

}

fn rne(x: f64, precision: i32) -> f64 {
    let scale = 2_f64.powi(precision);
    (x * scale).round() / scale
}