quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb/tb_div_rne.sv hdl/fpdiv.sv hdl/f32utils.sv hdl/mantissa_op.sv hdl/exponent_op.sv hdl/goldschmidt.sv hdl/round.sv hdl/mux.sv hdl/flopenr.sv ../Wallace/mult_cs.sv
vsim -voptargs=+acc work.tb

add wave -noupdate -divider TB
add wave -hex /tb/dividend /tb/divisor /tb/quotient

add wave -noupdate -divider GOLDSCHMIDT
add wave -hex /tb/dut/divsqrt/goldschmidt/*

run -all