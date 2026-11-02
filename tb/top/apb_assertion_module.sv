module apb_assertion_module (input bit pclk, 
	input logic presetn, 
	input logic pwrite, 
	input logic psel, 
	input logic penable, 
	input logic pready, 
	input logic pslverr);

	//penable will go high one clock cycle after psel
	
	sequence setup_phase;
		psel && !penable;
	endsequence

	sequence access_phase;
		psel && penable;
	endsequence
	
	property setup_to_access;
		@(posedge pclk) disable iff(!presetn)
		setup_phase |=> access_phase;
	endproperty

	access_assert: assert property (setup_to_access) else $display("SETUP PHASE TO ACESS PHASE ASSERTION FAILED AT = %0t", $time);				

	//penable can't be high when psel is low
	
	property  penable_condition;
		@(posedge pclk) disable iff(!presetn)
		penable |-> psel;
	endproperty

	penable_assert: assert property (penable_condition) else $display("PENABLE CONDITION ASSERTION FAILED AT =%0t", $time);

	//pslverr is only high after access phase
	
	sequence access_phase_done;
		psel && penable && pready;
	endsequence


	property pslverr_condition;
		@(posedge pclk) disable iff(!presetn)
		pslverr |-> access_phase_done;
	endproperty

	pslverr_assert: assert property (pslverr_condition) else $display("PSLVERR CONDITION ASSERTION FAILED AT = %0t)", $time);

endmodule
	
