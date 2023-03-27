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
    let p: f64 = args.get(5).unwrap().parse().unwrap();
    let pf: f64 = args.get(6).unwrap().parse().unwrap();

    println!("d: {d}");
    println!("r: {r}");
    println!("i: {i}");
    println!("p: {p}");
    println!("pf: {pf}");

    // Adjust internal precision
    let internal_p = p as i32;
    let internal_pf = pf as i32;

    // Round input numbers
    let n = rne(n, internal_pf as i32);
    let d = rne(d, internal_pf as i32);

    // Determine actual quotient
    let q = n/d;

    // Print state
    println!("n: {n}");

}

fn rne(x: f64, precision: i32) -> f64 {
    let base: f64 = 2.0;
    let scale = base.powi(precision);
    (x * scale).floor() / scale
}