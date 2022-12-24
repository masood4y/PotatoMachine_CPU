# PotatoMachine_CPU
Unpipelined, Non-Forwarding Basic "Potato Machine" CPU.
Only handles sequential instructions.


Componenets List: 
alu.sv
controller.sv
datapath.sv
idecoder.sv
multi_bit_regs.sv
ram.sv   // GIVEN TO ME 
regfile.sv   // GIVEN TO ME 
shifter.sv 


CPU.sv is the connection interface of all the components

task1.sv, task2.sv, task3.sv are just the CPU components and all files put in one file. They are all the same

Task 1 checks the implementation of the HCF instuction
Task 2 checks implementation of the STR instruction 
Task 3 checks implementation of the LDR instruction 


tb_task1.sv
tb_task2.sv
tb_task3.sv
are the respective testbenches for the tasks. They output a 1 if there are any errors 


task1.vo
task2.vo
task3.vo
are the gate level simulations for the tasks and should be all the same 


