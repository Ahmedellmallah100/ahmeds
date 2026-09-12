module W_ROM_tb();

parameter WIDTH=8 , DEPTH=8 ;

reg clk , rst , Ram_Rom_Valid ;
reg [$clog2(DEPTH)-1:0] W_Addr ;
wire [WIDTH-1:0] W ;


W_ROM #(.WIDTH(WIDTH),.DEPTH(DEPTH)) DUT (.clk(clk),.rst(rst),.Ram_Rom_Valid(Ram_Rom_Valid),.W_Addr(W_Addr),.W(W)) ;

initial begin
	clk = 0 ;
	forever #1 clk = ~clk ;
end

initial begin
    rst = 1 ;
    Ram_Rom_Valid = 1 ;
    W_Addr = 0 ;
    @(negedge clk) ;
    rst = 0 ;
    @(negedge clk) ;
    $readmemb("D:/important/kareem_wassem/projects/IRS_FPGA_Controller/AI_Accelerator_1/W_MEM.txt", DUT.W_MEM) ;
    @(negedge clk) ;
    W_Addr = 1 ;
    @(negedge clk) ;
    W_Addr = 2 ;
    @(negedge clk) ;
    W_Addr = 3 ;
    @(negedge clk) ;
    W_Addr = 4 ;
    @(negedge clk) ;
    W_Addr = 5 ;
    @(negedge clk) ;
    W_Addr = 6 ;
    @(negedge clk) ;
    W_Addr = 7 ;
    @(negedge clk) ;
    Ram_Rom_Valid = 0 ;
    @(negedge clk) ;
    $stop ;
end
endmodule