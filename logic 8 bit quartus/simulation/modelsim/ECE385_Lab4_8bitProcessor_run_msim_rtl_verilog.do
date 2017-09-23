transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/Synchronizers8.sv}
vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/Router8.sv}
vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/Reg_8.sv}
vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/HexDriver8.sv}
vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/Control8.sv}
vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/compute8.sv}
vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/Register_unit8.sv}
vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/Processor_8.sv}

vlog -sv -work work +incdir+C:/ECE\ 385\ -\ tchia2\ -shung5/Stuff_FA17-master/Stuff_FA17-master/logic\ 8\ bit\ quartus {C:/ECE 385 - tchia2 -shung5/Stuff_FA17-master/Stuff_FA17-master/logic 8 bit quartus/testbench_8.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench_8

add wave *
view structure
view signals
run 1000 ns
