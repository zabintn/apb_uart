import apb_param_pkg::*;
interface apb_if(input bit pclk);
	logic presetn;
	logic [ADDR_WIDTH-1:0] paddr;
	logic [DATA_WIDTH-1:0] pwdata;
	logic [DATA_WIDTH-1:0] prdata;
	logic pwrite;
	logic psel;
	logic penable;
	logic pready;
	logic pslverr;
endinterface
