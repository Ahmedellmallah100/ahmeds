module Multi_Neuron_tb();
parameter WIDTH=8 , DEPTH=8 , No_Neuron=10 , IDLE = 0 , COUNT = 1 ;

reg clk , rst , IN_Valid ;
reg signed [WIDTH-1:0] IN ;
reg [$clog2(DEPTH)-1:0] RAM_ADDR ;

wire [WIDTH-1:0] out ;
wire wr_en ;

wire [$clog2(No_Neuron)-1:0] Address ;


Multi_Neuron #(.WIDTH(WIDTH),.DEPTH(DEPTH),.No_Neuron(No_Neuron),.IDLE(IDLE),.COUNT(COUNT))
   DUT(.clk(clk),.rst(rst),.IN_Valid(IN_Valid),.IN(IN),.RAM_ADDR(RAM_ADDR),.out(out),.wr_en(wr_en),.Address(Address)) ;

initial begin
	clk = 0 ;
	forever #1 clk = ~clk ;
end 

reg load_trigger ;   
reg [8*150-1:0] fname , bname ;

initial load_trigger = 0 ;

genvar k ;
generate
    for (k = 0 ; k < No_Neuron ; k = k + 1) begin : load_weights
        initial begin
            
            @(posedge load_trigger) ;   
            $sformat(fname, "D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/W_MEM/W_MEM_%0d.txt", k) ;
            $readmemb(fname, DUT.gen_neuron[k].wrom.W_MEM) ;

          //  $sformat(bname, "D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/B_MEM.txt") ;
          //  $readmemb(bname, DUT.gen_neuron[k].brom.B_MEM) ;
        end
    end
endgenerate

integer j ;
initial begin
	rst = 1 ;
	IN_Valid = 0 ;
	IN = 8'h25 ;
	RAM_ADDR = 0 ;
	@(negedge clk) ;
	rst = 0 ;
	@(negedge clk) ;
	load_trigger = 1 ;
    $readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/B_MEM.txt", DUT.brom.B_MEM) ;
    @(negedge clk) ;
    IN_Valid = 1 ;

    @(negedge clk) ;

	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h73 ;
	RAM_ADDR = 1 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h20 ;
	RAM_ADDR = 2 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h17 ;
	RAM_ADDR = 3 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h61 ;
	RAM_ADDR = 4 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'hFF ;
	RAM_ADDR = 5 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'hAA ;
	RAM_ADDR = 6 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h38 ;
	RAM_ADDR = 7 ;
	
	@(negedge clk) ;
	IN_Valid = 0 ;

	@(Address == No_Neuron-1) ;
	@(negedge clk) ;
	@(negedge clk) ;
	@(negedge clk) ;
	 $stop ;

end

endmodule

