quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb.sv fpdiv.sv f32utils.sv mantissa_op.sv esub.sv goldschmidt.sv round.sv mux.sv flopenr.sv ../Wallace/mult_cs.sv
vsim -voptargs=+acc work.tb

add wave -noupdate -divider TB
add wave -hex /tb/dividend /tb/divisor /tb/quotient

add wave -noupdate -divider GOLDSCHMIDT_DIVIDER
add wave -hex /tb/dut/div/*

add wave -noupdate -divider ROUND
add wave -hex /tb/dut/div/rne/*

run -all