module Single_Neuron #(parameter WIDTH=8 , DEPTH=8 , No_Neuron=1 )(
	input clk , rst , IN_Valid ,
	input signed [WIDTH-1:0] IN ,
	input  [$clog2(DEPTH)-1:0] RAM_ADDR ,
	output signed [(2*WIDTH) + 1:0] R_out ,
	output signed [WIDTH-1:0] out ,
	output Done) ;



wire signed [WIDTH-1:0] X , W , B ;
wire X_Valid ;
wire [$clog2(DEPTH)-1:0] W_Addr ; 
wire [$clog2(No_Neuron)-1:0] rd_addr ;
wire [(2*WIDTH) + 1:0] result ;
wire N_Done ;

assign rd_addr = 0 ;

X_RAM #(.WIDTH(WIDTH),.DEPTH(DEPTH)) ram (.clk(clk),.rst(rst),.X_Valid(X_Valid),.X(X),.IN(IN),.IN_Valid(IN_Valid),.RAM_ADDR(RAM_ADDR),.W_Addr(W_Addr)) ;
W_ROM #(.WIDTH(WIDTH),.DEPTH(DEPTH)) wrom (.clk(clk),.rst(rst),.Ram_Rom_Valid(X_Valid),.W_Addr(W_Addr),.W(W)) ;
Bias_Rom #(.WIDTH(WIDTH),.No_Neuron(No_Neuron)) brom (.clk(clk),.rst(rst),.Ram_Rom_Valid(X_Valid),.rd_addr(rd_addr),.B(B)) ;
Neuron #(.WIDTH(WIDTH),.No_Neuron(No_Neuron)) neuron (.clk(clk),.X(X),.W(W),.rst(rst),.en(X_Valid),.bias(B),.result(result),.Done(N_Done),.b_addr(rd_addr)) ;
RELU #(.WIDTH(WIDTH)) relu (.IN(result),.start(N_Done),.out(R_out),.Done(Done)) ;
Requantize #(.IN_WIDTH(2*WIDTH+2),.OUT_WIDTH(WIDTH),.SHIFT(4)) reqnt (.in(R_out),.out(out)) ;

endmodule

