package uart_agent_pkg;
	`include "uvm_macros.svh"
	import uvm_pkg::*;
	import apb_param_pkg::*;
	
	`include "../seq_lib/uart_seq_item.sv"	
	`include "../seq_lib/uart_base_seq.sv"
	`include "../seq_lib/uart_sequencer.sv"
	`include "../agent/uart_driver.sv"
	`include "../agent/uart_monitor.sv"	
	`include "../agent/uart_agent.sv"
endpackage
