module Leyars_tb();
parameter WIDTH=8 , DEPTH=8 , No_Neuron_0=10 , No_Neuron_1=5 , No_Neuron_2=3 , No_Neuron_3=1 , IDLE = 0 , COUNT = 1 ;

reg clk , rst , IN_Valid ;
reg signed [WIDTH-1:0] IN ;
reg [$clog2(DEPTH)-1:0] RAM_ADDR ;

wire [WIDTH-1:0] Final_out ;
wire wr_en , Final_Done ;





Leyars #(.WIDTH(WIDTH),.DEPTH(DEPTH),.No_Neuron_0(No_Neuron_0),.No_Neuron_1(No_Neuron_1),
	     .No_Neuron_2(No_Neuron_2),.No_Neuron_3(No_Neuron_3),.IDLE(IDLE),.COUNT(COUNT))
   DUT  (.clk(clk),.rst(rst),.IN_Valid(IN_Valid),.IN(IN),.RAM_ADDR(RAM_ADDR),.Final_out(Final_out),.Final_Done(Final_Done)) ;

initial begin
	clk = 0 ;
	forever #1 clk = ~clk ;
end 

reg load_trigger ;   
reg [8*150-1:0] fname_0 , fname_1 , fname_2 ;

initial load_trigger = 0 ;

genvar k , j , n ;
generate
    for (k = 0 ; k < No_Neuron_0 ; k = k + 1) begin : load_weights_0
        initial begin
            @(posedge load_trigger) ;   
            $sformat(fname_0, "D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/W_MEM/W_MEM_0/W_MEM_%0d.txt", k) ;
            $readmemb(fname_0, DUT.layer_0.gen_neuron[k].wrom.W_MEM) ;
        end
    end
    for (j = 0 ; j < No_Neuron_1 ; j = j + 1) begin : load_weights_1
        initial begin
            @(posedge load_trigger) ;   
            $sformat(fname_1, "D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/W_MEM/W_MEM_1/W_MEM_%0d.txt", j) ;
            $readmemb(fname_1, DUT.layer_1.gen_neuron[j].wrom.W_MEM) ;
        end
    end
    for (n = 0 ; n < No_Neuron_2 ; n = n + 1) begin : load_weights_2
        initial begin
            @(posedge load_trigger) ;   
            $sformat(fname_2, "D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/W_MEM/W_MEM_2/W_MEM_%0d.txt", n) ;
            $readmemb(fname_2, DUT.layer_2.gen_neuron[n].wrom.W_MEM) ;
        end
    end
endgenerate


initial begin
	rst = 1 ;
	IN_Valid = 0 ;
	IN = 8'h25 ;
	RAM_ADDR = 0 ;
	@(negedge clk) ;
	rst = 0 ;
	@(negedge clk) ;
	load_trigger = 1 ;
    $readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/B_MEM/B_MEM_0.txt", DUT.layer_0.brom.B_MEM) ;
    $readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/B_MEM/B_MEM_1.txt", DUT.layer_1.brom.B_MEM) ;
    $readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/B_MEM/B_MEM_2.txt", DUT.layer_2.brom.B_MEM) ;
    $readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/B_MEM/B_MEM_3.txt", DUT.out_layer.brom.B_MEM) ;
    $readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/W_MEM/W_MEM_3/W_MEM_0.txt", DUT.out_layer.wrom.W_MEM) ;
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

	@(posedge Final_Done) ;
	@(negedge clk) ;
	@(negedge clk) ;
	@(negedge clk) ;
	 $stop ;

end

endmodule


