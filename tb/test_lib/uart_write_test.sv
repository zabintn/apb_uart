class uart_write_test extends apb_uart_base_test;
        `uvm_component_utils(uart_write_test)

        apb_directed_seq dseq;
        apb_read_seq     rdseq;
        uart_base_seq    useq;

        int div_value = 16;   
        int num_bytes = 1;    

        function new(string name="uart_write_test", uvm_component parent=null);
                super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                uvm_config_db#(int)::set(this, "env_o.agt2*", "bit_period", div_value+1);
        endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		`uvm_info(get_full_name(), "INSIDE UART WRITE TEST", UVM_LOW)
		phase.raise_objection(this);
		`uvm_info(get_full_name(), "CONFIGURING UART DUT VIA APB WRITE", UVM_LOW)
		repeat(1) begin
			dseq=apb_directed_seq::type_id::create("dseq");
			dseq.presetn=1;
			dseq.pwrite=1;
			dseq.paddr=32'h3;
			dseq.pwdata=32'h80;
			dseq.start(env_o.agt1.seqr);
		end

		repeat(1) begin
			dseq=apb_directed_seq::type_id::create("dseq");
			dseq.presetn=1;
			dseq.pwrite=1;
			dseq.paddr=32'h0;
			dseq.pwdata=div_value[7:0];
			dseq.start(env_o.agt1.seqr);
		end
		
	
		repeat(1) begin
			dseq=apb_directed_seq::type_id::create("dseq");
			dseq.presetn=1;
			dseq.pwrite=1;
			dseq.paddr=32'h1;
			dseq.pwdata=div_value[15:8];
			dseq.start(env_o.agt1.seqr);
		end		

		repeat(1) begin
			dseq=apb_directed_seq::type_id::create("dseq");
			dseq.presetn=1;
			dseq.pwrite=1;
			dseq.paddr=32'h3;
			dseq.pwdata=32'h03;
			dseq.start(env_o.agt1.seqr);
		end		

		`uvm_info(get_full_name(), "configuration done. writing bytes.", UVM_LOW)

		repeat(1) begin
			dseq=apb_directed_seq::type_id::create("dseq");
			dseq.presetn=1;
			dseq.pwrite=1;
			dseq.paddr=32'h0;
			dseq.pwdata=32'hAA;
			dseq.start(env_o.agt1.seqr);
		end

                wait(env_o.sb.pass_count == num_bytes);    // all TX bytes matched

		phase.drop_objection(this);
	endtask
endclass
