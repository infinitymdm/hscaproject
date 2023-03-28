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
    let k0: f64 = args.get(3).unwrap().parse().unwrap();
    let iterations: i32 = args.get(4).unwrap().parse().unwrap();
    let output_precision: i32 = args.get(5).unwrap().parse().unwrap();
    let internal_precision: i32 = args.get(6).unwrap().parse().unwrap();

    // Round input numbers to correct precision
    let mut n = rne(n, internal_precision);
    let mut d = rne(d, internal_precision);

    // Determine actual quotient
    let q = n/d;

    // Print state
    println!("N = {:.15}", n);
    // TODO: Display binary
    println!("D = {:.15}\n", d);
    // TODO: Display binary

    // Perform Goldschmidt iteration
    let mut k = k0;
    for i in 0..iterations {
        // We use output precision here because that's what would happen in hardware
        n = flr(n*k, output_precision);
        d = flr(d*k, output_precision);
        k = flr(2.0-d, output_precision);
        println!("i = {}, N = {:.6}, R = {:.6}", i, n, k);
        // TODO: Display binary
    }

    // Actual answer
    let rq = flr(q, internal_precision);
    // Computed answer
    let rd = flr(n, internal_precision);

    println!("Actual Answer\nRQ = {:.15}", rq);
    // TODO: Display binary
    println!("GDIV Answer\nRD = {:.15}", rd);
}

fn rne(x: f64, precision: i32) -> f64 {
    let scale = 2_f64.powi(precision);
    (x * scale).round() / scale
}

fn flr(x: f64, precision: i32) -> f64 {
    let scale = 2_f64.powi(precision);
    (x * scale).floor() / scale
}

fn to_bin(x: f64, precision: i32, radix_point_pos: i32) -> String {
    let mut s = String::new();
    if x.abs() < 2_f64.powi(-precision) {
        for _i in (-radix_point_pos+1)..precision {
            s.push('0');
        }
        return s;
    } 
    // TODO: come back to this later
    s
}