module Neuron_tb ();

parameter WIDTH=8 , No_Neuron=16 ;

reg clk , rst , en ;
reg [WIDTH-1:0] X , W , bias ;

wire [(2*WIDTH) + 1:0] result ;
wire Done ;
wire [$clog2(No_Neuron)-1:0] b_addr ;

Neuron #(.WIDTH(WIDTH)) DUT (.clk(clk),.X(X),.W(W),.rst(rst),.en(en),.bias(bias),.result(result),.Done(Done),.b_addr(b_addr)) ;

initial begin
	clk = 0 ;
	forever #1 clk = ~clk ;
end

initial begin
	rst = 1 ;
	en = 0 ;
	X = 2 ;
	W = 4 ;
	bias = 9 ;
	@(negedge clk) ;
	rst = 0 ;
	@(negedge clk) ;
	en = 1 ;
	@(negedge clk) ;

	X = 3 ;
	W = 2 ;

	@(negedge clk) ;

	X = 5 ;
	W = 9 ;

	@(negedge clk) ;

	X = 1 ;
	W = 8 ;

	@(negedge clk) ;

	X = 100 ;
	W = 67 ;

	@(negedge clk) ;

	X = 39 ;
	W = 26 ;

	@(negedge clk) ;

	X = 88 ;
	W = 199 ;

	@(negedge clk) ;

	X = 255 ;
	W = 5 ;

	@(negedge clk) ;
	en = 0 ;
	@(posedge Done) ;
	@(negedge clk) ;

	$stop ;

end

endmodule