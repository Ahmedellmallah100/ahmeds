module W_ROM #(parameter WIDTH=8 , DEPTH=8)(
	input clk , rst , Ram_Rom_Valid ,
	input [$clog2(DEPTH)-1:0] W_Addr ,
	output signed [WIDTH-1:0] W  ) ;

reg [WIDTH-1:0] W_MEM [0:DEPTH-1] ;

integer i ;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		for (i=0 ; i<DEPTH ; i=i+1) begin
				W_MEM[i] <= 0 ;
			end
		
	end
	
end

assign W = (Ram_Rom_Valid)? W_MEM[W_Addr] : 0 ;

endmodule