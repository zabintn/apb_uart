class apb_functional_cov extends uvm_subscriber #(apb_seq_item);
	`uvm_component_utils(apb_functional_cov)

	apb_seq_item req;
	int bit_period=17;

	virtual apb_if apb_vif;	
	virtual uart_if uart_vif;
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "INSIDE DRIVER BUILD PHASE", UVM_LOW);
		if(!uvm_config_db#(virtual apb_if) :: get(this, "", "vif", apb_vif))
			`uvm_fatal(get_type_name(), "Not Set at Top Level");
		if(!uvm_config_db#(virtual uart_if) :: get(this, "", "vif", uart_vif))
			`uvm_fatal(get_type_name(), "Not Set at Top Level");
	endfunction


	covergroup apb_cg;
		cp_pwrite: coverpoint req.pwrite {
			bins write={1};
			bins read={0};
			}
		cp_psel: coverpoint req.psel{
			bins sel={1};
			}
		cp_penable: coverpoint req.penable{
			bins en_able={1};
			bins dis_able={0};
			}
		cp_pready: coverpoint req.pready{
			bins ready={1};
			bins not_ready={0};
			}
		cp_paddr: coverpoint req.paddr {
			bins valid={[32'h0000_0000:32'h0000_00FF]};
			bins invalid={[32'h0000_0100:$]};
			}
		cp_pslverr: coverpoint req.pslverr iff (req.psel && req.penable && req.pready) {
			bins okay = {0};
			bins error = {1};
			}
		cx_addr_err: cross cp_pwrite, cp_paddr, cp_pslverr{
			bins wr_err= binsof(cp_pwrite.write);
			bins rd_err= binsof(cp_pwrite.read);
			}
		cx_apb_phases: cross cp_psel, cp_penable{
			bins setup_phase= binsof(cp_psel.sel) && binsof(cp_penable.dis_able);
			bins access_phase= binsof(cp_psel.sel) && binsof(cp_penable.en_able);
			}	

	endgroup

	covergroup uart_cg;
		cp_reg: coverpoint req.paddr[2:0] {
               		bins thr_rbr_dll = {0};
                	bins ier_dlm     = {1};
                	bins iir_fcr     = {2};
                	bins lcr         = {3};
                	bins lsr         = {5};
        	}
        	cp_rw: coverpoint req.pwrite {
                	bins write = {1};
                	bins read  = {0};
        	}
        	cx_reg_rw: cross cp_reg, cp_rw;
	endgroup

	function new(string name= "apb_functional_cov", uvm_component parent=null);
		super.new(name, parent);
		apb_cg=new();
		uart_cg=new();
	endfunction

	
	function void write (apb_seq_item t);
		req=t;
		apb_cg.sample();
		uart_cg.sample();
	endfunction

	task run_phase(uvm_phase phase);
		apb_seq_item item;
		forever begin
			@(posedge apb_vif.pclk);
			if (apb_vif.psel) begin          // ignore idle cycles
				item=apb_seq_item::type_id::create("cov_item");
				item.paddr   = apb_vif.paddr;
				item.pwrite  = apb_vif.pwrite;
				item.psel    = apb_vif.psel;
				item.penable = apb_vif.penable;
				item.pready  = apb_vif.pready;
				item.pslverr = apb_vif.pslverr;
				write(item);
			end
		end
	endtask


	function void report_phase(uvm_phase phase);
		`uvm_info(get_full_name(), $sformatf("APB FUNCTIONAL COVERAGE=%.2f", apb_cg.get_coverage()), UVM_LOW)
		`uvm_info(get_full_name(), $sformatf("UART FUNCTIONAL COVERAGE=%.2f", uart_cg.get_coverage()), UVM_LOW)
	endfunction

endclass






