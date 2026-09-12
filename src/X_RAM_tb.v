module X_RAM_tb ();

parameter WIDTH=8 , DEPTH=8 ;

reg clk , rst , X_Valid ;
reg [WIDTH-1:0] X ;

wire [WIDTH-1:0] Y ;
wire Y_Valid ;
wire [$clog2(DEPTH)-1:0] W_Addr ;

X_RAM #(.WIDTH(WIDTH),.DEPTH(DEPTH)) DUT (.clk(clk),.rst(rst),.X_Valid(X_Valid),.X(X),.Y(Y),.Y_Valid(Y_Valid),.W_Addr(W_Addr)) ;

initial begin
	clk = 0 ;
	forever #1 clk = ~clk ;
end

initial begin
	rst = 1 ;
	X_Valid = 1 ;
	X = 8'h11 ;
	@(negedge clk) ;

	rst = 0 ;
	@(negedge clk) ;

	X_Valid = 0 ;
	@(negedge clk) ;
	X_Valid = 1 ;
	X = 8'h22 ;

	@(negedge clk) ;
	X_Valid = 0 ;
	@(negedge clk) ;
	X_Valid = 1 ;
	X = 8'h33 ;

	@(negedge clk) ;
	X_Valid = 0 ;
	@(negedge clk) ;
	X_Valid = 1 ;
	X = 8'h44 ;

	@(negedge clk) ;
	X_Valid = 0 ;
	@(negedge clk) ;
	X_Valid = 1 ;
	X = 8'h55 ;

	@(negedge clk) ;
	X_Valid = 0 ;
	@(negedge clk) ;
	X_Valid = 1 ;
	X = 8'h66 ;

	@(negedge clk) ;
	X_Valid = 0 ;
	@(negedge clk) ;
	X_Valid = 1 ;
	X = 8'h77 ;

	@(negedge clk) ;
	X_Valid = 0 ;
	@(negedge clk) ;
	X_Valid = 1 ;
	X = 8'h88 ;

	@(Y == 8'h88) ;
	@(negedge clk) ;
	$stop ;
end

endmodule