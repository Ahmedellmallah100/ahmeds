module Single_Neuron_tb();
parameter WIDTH=8 , DEPTH=8 , No_Neuron=1 ;

reg clk , rst , IN_Valid ;
reg signed [WIDTH-1:0] IN ;

wire signed [(2*WIDTH) + 1:0] out ;
wire Done ;

Single_Neuron #(.WIDTH(WIDTH),.DEPTH(DEPTH),.No_Neuron(No_Neuron))
   DUT(.clk(clk),.rst(rst),.IN_Valid(IN_Valid),.IN(IN),.out(out),.Done(Done)) ;

initial begin
	clk = 0 ;
	forever #1 clk = ~clk ;
end 

initial begin
	rst = 1 ;
	IN_Valid = 0 ;
	IN = 8'h11 ;
	@(negedge clk) ;
	rst = 0 ;
	@(negedge clk) ;
	$readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/W_MEM.txt", DUT.wrom.W_MEM) ;
    $readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/B_MEM.txt", DUT.brom.B_MEM) ;
    @(negedge clk) ;
    IN_Valid = 1 ;

    @(negedge clk) ;

	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h22 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h33 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h44 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h55 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h66 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h77 ;

	@(negedge clk) ;
	IN_Valid = 0 ;
	@(negedge clk) ;
	IN_Valid = 1 ;
	IN = 8'h88 ;
	
	@(negedge clk) ;
	IN_Valid = 0 ;

	@(posedge Done) ;
	@(negedge clk) ;
	@(negedge clk) ;
	@(negedge clk) ;
	 $stop ;

end

endmodule
