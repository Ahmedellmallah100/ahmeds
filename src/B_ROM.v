module B_ROM #(parameter WIDTH=8 , No_Neuron=10)(
	input clk , rst , Ram_Rom_Valid , 
	output signed [(WIDTH * No_Neuron)-1:0] B );

reg [WIDTH-1:0] B_MEM [0:No_Neuron-1] ;

integer n ;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		for (n=0 ; n<No_Neuron ; n=n+1) begin
				B_MEM[n] <= 0 ;
			end
		
	end
	
end
generate
	genvar i;
	for (i = 0; i < No_Neuron; i = i + 1) begin
		assign B[i*WIDTH +: WIDTH] = (Ram_Rom_Valid)? B_MEM[i] : 0 ;

	end
endgenerate

endmodule

