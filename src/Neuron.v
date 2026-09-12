module Neuron #(parameter WIDTH=8 , No_Neuron=16) (
	input clk , rst , en ,
	input signed [WIDTH-1:0] X , W , bias ,
	output signed [(2*WIDTH) + 1:0] result ,
	output Done ,
	output [$clog2(No_Neuron)-1:0] b_addr ) ;

wire signed [2*WIDTH:0] mul ;
wire signed [(2*WIDTH) + 1:0] adder ;
reg signed  [(2*WIDTH) + 1:0] q ;
reg en_reg ;
reg signed [WIDTH-1:0] bias_reg ;

//assign b_addr = 0 ;

assign mul = (en)? X * W : 0 ;
assign adder = (en)? mul + q : 0 ;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		q <= 0 ;
		en_reg <= 0 ;
		bias_reg <= 0 ;
	end
	else begin
		en_reg <= en ;
		bias_reg <= bias ;
		if (en) begin
			q <= adder ;
		end
	end
end

assign result = (en_reg && !en)? q + bias_reg : 0 ;
assign Done   = (en_reg && !en)? 1 : 0 ;


endmodule