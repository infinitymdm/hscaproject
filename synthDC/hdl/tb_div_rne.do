quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb_div_rne.sv fpdiv.sv f32utils.sv mantissa_op.sv exponent_op.sv goldschmidt.sv round.sv mux.sv flopenr.sv ../Wallace/mult_cs.sv
vsim -voptargs=+acc work.tb

add wave -noupdate -divider TB
add wave -hex /tb/dividend /tb/divisor /tb/quotient

add wave -noupdate -divider GOLDSCHMIDT
add wave -hex /tb/dut/divsqrt/goldschmidt/*

run -all