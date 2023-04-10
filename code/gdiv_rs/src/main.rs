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
    let internal_precision: i32 = args.get(5).unwrap().parse().unwrap();
    let external_precision: i32 = args.get(6).unwrap().parse().unwrap();
    println!("n raw bits: {:032b}", (n as f32).to_bits());
    println!("d raw bits: {:032b}", (d as f32).to_bits());

    // Round input numbers to correct precision
    let mut n = rne(n, external_precision);
    let n1 = n;
    let mut d = rne(d, external_precision);
    let d1 = d;

    // Determine actual quotient
    let q = n/d;

    // Print state
    println!("N = {:.15} = {}", n, to_bin_str(n, external_precision, 1));
    println!("D = {:.15} = {}\n", d, to_bin_str(d, external_precision, 1));

    // Perform Goldschmidt iteration
    let mut k = k0;
    for i in 0..iterations {
        n = flr(n*k, internal_precision);
        d = flr(d*k, internal_precision);
        k = flr(2.0-d-2_f64.powi(-internal_precision), internal_precision);
        //println!("i = {}, N = {:.6}, R = {:.6}", i, n, k);
        println!("i = {i}");
        println!("N = {}", to_bin_str(n, internal_precision, 2));
        println!("D = {}", to_bin_str(d, internal_precision, 2));
        println!("R = {}", to_bin_str(k, internal_precision, 2));
    }

    // Actual answer
    let rq = flr(q, external_precision);
    // Computed answer
    let rd = flr(n, external_precision);

    println!("q raw bits: {:032b}", (q as f32).to_bits());

    println!("\nActual Answer");
    println!("RQ = {:.15} = {}", rq, to_bin_str(rq, external_precision, 2));
    println!("GDIV Answer");
    println!("RD = {:.15} = {}", rd, to_bin_str(rd, external_precision, 2));

    // Error analysis
    println!("\nError Analysis");
    println!("error =  {:.15}", (rq-rd).abs());
    println!("#bits = {:.15}", (rq-rd).abs().log2());

    // Remainder
    let rem = 2_f64.powi(external_precision) * (n1 - rd*d1);
    let rrem = flr(rem, external_precision);
    println!("\nRemainder");
    println!("RREM = {rrem:.15}");
    println!("RREM = {}\n", to_bin_str(rrem, external_precision, 1))
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