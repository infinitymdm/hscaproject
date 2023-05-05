quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb_sqrt.sv fpdiv.sv f32utils.sv mantissa_op.sv exponent_op.sv goldschmidt.sv round.sv mux.sv flopenr.sv ../Wallace/mult_cs.sv
vsim -voptargs=+acc work.tb

add wave /tb/dut/divsqrt/sctrl/signal

add wave -noupdate -divider TB
add wave -hex /tb/radicand /tb/result

add wave -noupdate -divider MANTISSA_OP
add wave -hex /tb/dut/divsqrt/*

add wave -noupdate -divider GOLDSCHMIDT_DIVIDER
add wave -hex /tb/dut/divsqrt/goldschmidt/*

run -all