transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/Synchronizers8.sv}
vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/ripple_adder.sv}
vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/Reg_8.sv}
vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/Dreg.sv}
vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/Control.sv}
vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/adder2.sv}
vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/bit_multiplier_8.sv}

vlog -sv -work work +incdir+C:/Users/timrc/Dropbox/Fall\ 2017/ECE\ 385/Stuff_FA17/bit_multiplier_8 {C:/Users/timrc/Dropbox/Fall 2017/ECE 385/Stuff_FA17/bit_multiplier_8/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
