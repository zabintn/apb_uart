`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_test_pkg::*;


module apb_tb_top;

bit pclk;
bit presetn;

int clk_frequency_mhz;
int clk_period_ns;
initial begin
	if($value$plusargs("CLK_FREQUENCY=%d", clk_frequency_mhz)) begin
		$display("Clock frequency overwritten to %0d MHz", clk_frequency_mhz);
	end
	
	clk_period_ns=1000/clk_frequency_mhz;
end


always #(clk_period_ns/2) pclk = ~pclk;

//instantiate interface and DUT
apb_if apb_vif(pclk);
uart_if uart_vif(pclk);

initial begin
	uvm_config_db#(virtual apb_if)::set(uvm_root::get(), "*", "vif", apb_vif);
	uvm_config_db#(virtual uart_if)::set(uvm_root::get(), "*", "vif", uart_vif);
end
apb_uart_sv #(.APB_ADDR_WIDTH(DATA_WIDTH)) DUT( 
	.CLK(apb_vif.pclk),
	.RSTN(apb_vif.presetn),
	.PADDR(apb_vif.paddr),
	.PWDATA(apb_vif.pwdata),
	.PWRITE(apb_vif.pwrite),
	.PSEL(apb_vif.psel),
	.PENABLE(apb_vif.penable),
	.PRDATA(apb_vif.prdata),
	.PREADY(apb_vif.pready),
	.PSLVERR(apb_vif.pslverr),
	.rx_i(uart_vif.rx_i),
	.tx_o(uart_vif.tx_o)
	);
apb_assertion_module all_inst(.pclk(apb_vif.pclk),
	.presetn (apb_vif.presetn),
        .pwrite  (apb_vif.pwrite),
        .psel    (apb_vif.psel),
        .penable (apb_vif.penable),
        .pready  (apb_vif.pready),
        .pslverr (apb_vif.pslverr));

	
initial begin
	run_test("base_test");
end
endmodule
