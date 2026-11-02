package apb_env_pkg;
	`include "uvm_macros.svh"
	import uvm_pkg::*;
	import apb_agent_pkg::*;
	import apb_param_pkg::*;
	import uart_agent_pkg::*;
	`include "../env/apb_functional_cov.sv"
	`include "../env/apb_scoreboard.sv"
	`include "../env/apb_env.sv"
endpackage
