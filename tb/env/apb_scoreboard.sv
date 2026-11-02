`uvm_analysis_imp_decl(_utx)   
`uvm_analysis_imp_decl(_urx)   

class apb_scoreboard extends uvm_scoreboard;
        uvm_analysis_imp #(apb_seq_item, apb_scoreboard) item_collect_export;  
        uvm_analysis_imp_utx #(uart_seq_item, apb_scoreboard) utx_export;       
        uvm_analysis_imp_urx #(uart_seq_item, apb_scoreboard) urx_export;       

        apb_seq_item item_q[$];  
        bit [7:0] exp_tx_q[$];        
        bit [7:0] exp_rx_q[$];        
        bit       dlab;               
        int pass_count;
        int fail_count;

        `uvm_component_utils(apb_scoreboard)

        function new(string name="apb_scoreboard", uvm_component parent= null);
                super.new(name, parent);
                item_collect_export=new("item_collect_export", this);
                utx_export = new("utx_export", this);                          
                urx_export = new("urx_export", this);                           
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                `uvm_info(get_type_name(), "INSIDE SCOREBOARD BUILD PHASE", UVM_LOW);
        endfunction

        function void connect_phase(uvm_phase phase);
                `uvm_info(get_type_name(), "INSIDE SCOREBOARD CONNECT PHASE", UVM_LOW);
        endfunction

        function void write(apb_seq_item req);
                `uvm_info(get_type_name(), "INSIDE SCOREBOARD WRITE FUNCTION", UVM_LOW);
                item_q.push_back(req);
        endfunction

        function void write_urx(uart_seq_item item);
                exp_rx_q.push_back(item.uart_data);
        endfunction

        function void write_utx(uart_seq_item item);
                bit [7:0] expected;
                if (exp_tx_q.size() == 0) begin
                        `uvm_error(get_type_name(), $sformatf("DUT sent %0h on tx_o but nothing was written to THR", item.uart_data));
                        fail_count++;
                end
                else begin
                        expected = exp_tx_q.pop_front();
                        if (item.uart_data !== expected) begin
                                `uvm_error(get_type_name(), $sformatf("TX MISMATCH: expected=%0h, actual=%0h", expected, item.uart_data));
                                fail_count++;
                        end
                        else begin
                                `uvm_info(get_type_name(), $sformatf("TX MATCH: %0h", expected), UVM_LOW);
                                pass_count++;
                        end
                end
        endfunction

        task run_phase(uvm_phase phase);
                apb_seq_item sb_item;
                bit [7:0] expected;

                `uvm_info(get_type_name(), "INSIDE SCOREBOARD RUN PHASE", UVM_LOW);
                pass_count=0;
                fail_count=0;
                forever begin

                        wait(item_q.size > 0);

                        if(item_q.size>0) begin
                                sb_item=item_q.pop_front();

                                if(sb_item.pwrite==1) begin
                                        `uvm_info(get_type_name(), $sformatf("WRITE: addr=%0h, data=%0h, pslverr=%0h", sb_item.paddr, sb_item.pwdata, sb_item.pslverr), UVM_LOW);
                                        if (sb_item.paddr[2:0] == 3'h3)                       // LCR write: track DLAB
                                                dlab = sb_item.pwdata[7];
                                        else if (sb_item.paddr[2:0] == 3'h0 && !dlab)         // THR write
                                                exp_tx_q.push_back(sb_item.pwdata[7:0]);
                                end
                                else if (sb_item.paddr[2:0] == 3'h0 && !dlab) begin       // RBR read
                                        if (exp_rx_q.size() == 0) begin
                                                `uvm_error(get_type_name(), "RBR read but no byte was seen on rx_i");
                                                fail_count++;
                                        end
                                        else begin
                                                expected = exp_rx_q.pop_front();
                                                if (sb_item.prdata[7:0] !== expected) begin
                                                        `uvm_error(get_type_name(), $sformatf("RX MISMATCH: expected=%0h, actual=%0h", expected, sb_item.prdata[7:0]));
                                                        fail_count++;
                                                end
                                                else begin
                                                        `uvm_info(get_type_name(), $sformatf("RX MATCH: %0h", expected), UVM_LOW);
                                                        pass_count++;
                                                end
                                        end
                                end

                                `uvm_info(get_type_name(), $sformatf("pass count=%0d, fail count=%0d", pass_count, fail_count), UVM_LOW);
                        end
                end
        endtask

        function void check_phase(uvm_phase phase);
                if (exp_tx_q.size() != 0)
                        `uvm_error(get_type_name(), $sformatf("%0d byte(s) written to THR never appeared on tx_o", exp_tx_q.size()));
                if (exp_rx_q.size() != 0)
                        `uvm_error(get_type_name(), $sformatf("%0d byte(s) seen on rx_i never read from RBR", exp_rx_q.size()));
        endfunction
endclass
