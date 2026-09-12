module Bias_Rom #(parameter WIDTH=8 , No_Neuron=10)(
	input clk , rst , Ram_Rom_Valid , 
	input [$clog2(No_Neuron)-1:0] rd_addr ,
	output signed [WIDTH-1:0] B );

reg [WIDTH-1:0] B_MEM [0:No_Neuron-1] ;

integer i ;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		for (i=0 ; i<No_Neuron ; i=i+1) begin
				B_MEM[i] <= 0 ;
			end
		
	end
	
end

assign B = (Ram_Rom_Valid)? B_MEM[rd_addr] : 0 ;

endmodule
