package apb_test_pkg;
	`include "uvm_macros.svh"
	import uvm_pkg::*;
	import apb_agent_pkg::*;
	import uart_agent_pkg::*;
	import apb_env_pkg::*;
	`include "../test_lib/apb_base_test.sv"
	`include "../test_lib/uart_read_write_test.sv"
	`include "../test_lib/uart_write_test.sv"
	`include "../test_lib/uart_read_test.sv"
endpackage
