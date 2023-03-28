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
    let n1 = n;
    let mut d = rne(d, internal_precision);
    let d1 = d;

    // Determine actual quotient
    let q = n/d;

    // Print state
    println!("N = {:.15} = {}", n, to_bin_str(n, internal_precision, 1));
    println!("D = {:.15} = {}\n", d, to_bin_str(d, internal_precision, 1));

    // Perform Goldschmidt iteration
    let mut k = k0;
    for i in 0..iterations {
        // We use output precision here because that's what would happen in hardware
        n = flr(n*k, output_precision);
        d = flr(d*k, output_precision);
        k = flr(2.0-d, output_precision);
        println!("i = {}, N = {:.6}, R = {:.6}", i, n, k);
        println!("i = {}, N = {}, R = {}", i, to_bin_str(n, output_precision, 2), to_bin_str(k, output_precision, 2));
    }

    // Actual answer
    let rq = flr(q, internal_precision);
    // Computed answer
    let rd = flr(n, internal_precision);

    println!("\nActual Answer");
    println!("RQ = {:.15} = {}", rq, to_bin_str(rq, internal_precision, 2));
    println!("GDIV Answer");
    println!("RD = {:.15} = {}", rd, to_bin_str(rd, internal_precision, 2));

    // Error analysis
    println!("\nError Analysis");
    println!("error =  {:.15}", (rq-rd).abs());
    println!("#bits = {:.15}", (rq-rd).abs().log2());

    // Remainder
    let rem = 2_f64.powi(internal_precision) * (n1 - rd*d1);
    let rrem = flr(rem, internal_precision);
    println!("\nRemainder");
    println!("RREM = {rrem:.15}");
    println!("RREM = {}\n", to_bin_str(rrem, internal_precision, 1))
}

fn rne(x: f64, precision: i32) -> f64 {
    let scale = 2_f64.powi(precision);
    (x * scale).round() / scale
}

fn flr(x: f64, precision: i32) -> f64 {
    let scale = 2_f64.powi(precision);
    (x * scale).floor() / scale
}

fn to_bin_str(x: f64, precision: i32, radix_point_pos: i32) -> String {
    let mut s = String::new();
    let mut x = x;
    if x.abs() < 2_f64.powi(-precision) {
        // If x is less than we can represent with the current
        // precision, display zeros
        for _each in (-radix_point_pos+1)..precision {
            s.push('0');
        }
        return s;
    } else if x < 0.0 {
        // If x is negative, take 2's complement
        x = 2_f64.powi(radix_point_pos) + x;
    }
    for i in (-radix_point_pos+1)..precision+1 {
        let diff = 2_f64.powi(-i);
        if x < diff {
            s.push('0');
        } else {
            s.push('1');
            x -= diff;
        }
        if i == 0 {
            s.push('.');
        }
    }
    return s
}