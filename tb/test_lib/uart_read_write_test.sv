class uart_read_write_test extends apb_uart_base_test;
        `uvm_component_utils(uart_read_write_test)

        apb_directed_seq dseq;
        apb_read_seq     rdseq;
        uart_base_seq    useq;

        int div_value = 16;   
        int num_bytes = 3;    

        function new(string name="uart_read_write_test", uvm_component parent=null);
                super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                uvm_config_db#(int)::set(this, "env_o.agt2*", "bit_period", div_value+1);
        endfunction

        task apb_wr(bit [31:0] addr, bit [31:0] data);
                dseq = apb_directed_seq::type_id::create("dseq");
                dseq.presetn = 1;
                dseq.pwrite  = 1;
                dseq.paddr   = addr;
                dseq.pwdata  = data;
                dseq.start(env_o.agt1.seqr);
        endtask

        task apb_rd(bit [31:0] addr);
                rdseq = apb_read_seq::type_id::create("rdseq");
                rdseq.paddr = addr;
                rdseq.start(env_o.agt1.seqr);
        endtask

        task run_phase(uvm_phase phase);
                super.run_phase(phase);
                `uvm_info(get_full_name(), "INSIDE UART BASIC TEST RUN PHASE", UVM_LOW);
                phase.raise_objection(this);

                apb_wr(32'h3, 32'h80);                 // LCR: DLAB=1
                apb_wr(32'h0, div_value[7:0]);         // DLL
                apb_wr(32'h1, div_value[15:8]);        // DLM
                apb_wr(32'h3, 32'h03);                 // LCR: DLAB=0, 8 bits, no parity, 1 stop

                `uvm_info(get_full_name(), "TX PATH: WRITING BYTES TO THR", UVM_LOW);
                apb_wr(32'h0, 32'hA5);
                apb_wr(32'h0, 32'h3C);
                apb_wr(32'h0, 32'h7E);
                wait(env_o.sb.pass_count == num_bytes);    // all TX bytes matched

                `uvm_info(get_full_name(), "RX PATH: SENDING BYTES ON rx_i", UVM_LOW);
                useq = uart_base_seq::type_id::create("useq");
                useq.num_items = num_bytes;
                useq.start(env_o.agt2.seqr);
                wait(env_o.sb.exp_rx_q.size() == num_bytes);   // monitor has seen every frame

                `uvm_info(get_full_name(), "RX PATH: READING RBR", UVM_LOW);
                repeat (num_bytes) apb_rd(32'h0);
                wait(env_o.sb.pass_count == 2*num_bytes);      // all RX bytes matched 
		
		
		phase.drop_objection(this);
                `uvm_info(get_full_name(), "AFTER UART BASIC TEST", UVM_LOW);
        endtask
endclass
