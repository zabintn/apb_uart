class apb_directed_seq extends apb_base_seq;
	`uvm_object_utils(apb_directed_seq)

	function new(string name= "abp_directed_seq");
		super.new(name);
	endfunction
	rand bit presetn;
	rand bit pwrite;
	rand bit [ADDR_WIDTH-1:0] paddr;
	rand bit [DATA_WIDTH-1:0] pwdata;

	task body();
		super.body();
		req=apb_seq_item::type_id::create("req");
		start_item(req);
		req.randomize with {
			presetn==local::presetn;
			paddr==local::paddr;
			pwrite==local::pwrite;
			pwdata==local::pwdata;
			};
		finish_item(req);
		req.print();
	endtask
endclass


