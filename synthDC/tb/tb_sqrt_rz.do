quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb/tb_sqrt_rz.sv hdl/fpdiv.sv hdl/f32utils.sv hdl/mantissa_op.sv hdl/exponent_op.sv hdl/goldschmidt.sv hdl/round.sv hdl/mux.sv hdl/flopenr.sv ../Wallace/mult_cs.sv
vsim -voptargs=+acc work.tb

add wave /tb/dut/divsqrt/sctrl/signal

add wave -noupdate -divider TB
add wave -hex /tb/radicand /tb/result

add wave -noupdate -divider MANTISSA_OP
add wave -hex /tb/dut/divsqrt/*

add wave -noupdate -divider GOLDSCHMIDT_DIVIDER
add wave -hex /tb/dut/divsqrt/goldschmidt/*

run -all