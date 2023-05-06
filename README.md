#### Marcus Mellor
# HSCA Spring 2023 Project

This repository contains my work on the FPDIV Goldscmidt divider and square root module.

The files are organized as follows:
* SystemVerilog files, testbenches, and .DO files are in the `hdl` directory.
* Previously submitted memos are in the `memos` directory. 
* Dependencies provided by Dr. Stine are in the `Wallace` and `fptests` directories.
* Two Rust programs I wrote while learning single-precision floating point format and Goldschmidt division are found in the `f32unpack` and `gdiv_rs` directories. 
* Diagrams and a detailed description of the sequence of operations for division and square root are found in `FPDIV_diagrams.drawio.pdf`.

## Testbenches

To run the provided testbenches, navigate to the `hdl` directory and run `vsim -do [testbench].do`. The provided testbench names and configurations are listed below.
Each testbench writes internal states to the console and writes results to a corresponding file in the `hdl` directory.

| File Name      | Operation   | Rounding Mode         |
| -------------- | ----------- | --------------------- |
| tb_div_rne.do  | Division    | Round to nearest even |
| tb_div_rz.do   | Division    | Round towards zero    |
| tb_sqrt_rne.do | Square Root | Round to nearest even |
| tb_sqrt_rz.do  | Square Root | Round towards zero    |