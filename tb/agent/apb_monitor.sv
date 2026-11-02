class apb_monitor extends uvm_monitor;
	virtual apb_if apb_vif;
	uvm_analysis_port #(apb_seq_item) item_collect_port;
	apb_seq_item mon_item;
	`uvm_component_utils(apb_monitor)

	function new(string name="apb_monitor", uvm_component parent=null);
		super.new(name, parent);
		item_collect_port=new("item_collect_port", this);
		mon_item=new();
	endfunction

	function void build_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "INSIDE UVM MONITOR BUILD PHASE", UVM_LOW);
		if (!uvm_config_db#(virtual apb_if) ::get(this, "", "vif", apb_vif))
			`uvm_fatal(get_type_name(), "Not Set at Top Level");
	endfunction

	function void connect_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "INSIDE UVM MONITOR CONNECT PHASE", UVM_LOW);
	endfunction
      task run_phase(uvm_phase phase);
                `uvm_info(get_type_name(), "INSIDE UVM MONITOR RUN PHASE", UVM_LOW);
                forever begin
                        //wait until reset deassertion

                        wait(apb_vif.presetn);

                        //wait until setup phase

                        do @(posedge apb_vif.pclk);
                        while (!(apb_vif.psel==1 && apb_vif.penable==0));

                        `uvm_info(get_type_name(), "SETUP PHASE STARTED", UVM_LOW);
                        @(negedge apb_vif.pclk);

                        mon_item.psel=apb_vif.psel;
                        mon_item.pwrite=apb_vif.pwrite;
                        mon_item.pwdata=apb_vif.pwdata;
                        mon_item.paddr=apb_vif.paddr;

                        `uvm_info(get_type_name(), $sformatf("pwdata=%0h, paddr=%0h, pwrite=%0b", mon_item.pwdata, mon_item.paddr, mon_item.pwrite), UVM_LOW);

                        //wait for access phase

                        do @(posedge apb_vif.pclk);
                        while (!(apb_vif.psel==1 && apb_vif.penable==1));

                        `uvm_info(get_type_name(), "ACCESS PHASE STARTED", UVM_LOW);
                        mon_item.penable=apb_vif.penable;

                        //wait for pready high

                        while (!apb_vif.pready)
                                @(negedge apb_vif.pclk);

                                mon_item.prdata=apb_vif.prdata;
                                mon_item.pready=apb_vif.pready;
                                mon_item.pslverr=apb_vif.pslverr;

                                `uvm_info(get_type_name(), $sformatf("prdata=%0h, pready=%0b, pslverr=%0b", mon_item.prdata, mon_item.pready, mon_item.pslverr), UVM_LOW);
                                item_collect_port.write(mon_item);

                end
        endtask	
endclass
