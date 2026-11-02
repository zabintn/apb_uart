class apb_read_seq extends apb_base_seq;
	`uvm_object_utils(apb_read_seq)

	rand bit [ADDR_WIDTH-1:0] paddr;

	function new(string name= "apb_read_seq");
		super.new(name);
	endfunction

	task body();
		super.body();
		req=apb_seq_item::type_id::create("req");
		start_item(req);
		req.randomize with {
			presetn==1;
			pwrite ==0;
			paddr == local::paddr;
			pwdata== '0;};
		finish_item(req);
		req.print();
	endtask
endclass
