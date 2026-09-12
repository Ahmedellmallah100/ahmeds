module X_RAM #(parameter WIDTH=8 , DEPTH=8)(
	input clk , rst , IN_Valid ,
	input signed [WIDTH-1:0] IN ,
	input  [$clog2(DEPTH)-1:0] RAM_ADDR ,
	output reg signed [WIDTH-1:0] X , 
	output reg X_Valid ,
	output reg [$clog2(DEPTH)-1:0] W_Addr ) ;

reg [$clog2(DEPTH)-1:0] counter , X_counter ;
reg [WIDTH-1:0] X_MEM [0:DEPTH-1] ;

integer i ;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		counter <= 0 ;
		X_counter <= 0 ;
		X_Valid <= 0 ;
		for (i=0 ; i<DEPTH ; i=i+1) begin
			X_MEM[i] <= 0 ;
		end
		
	end
	else begin
		
		if (IN_Valid) begin
			X_MEM[RAM_ADDR] <= IN ;
			counter <= counter + 1 ;
		end

		if (counter==DEPTH-1) begin
			X_Valid <= 1 ;
		end

		if (X_Valid) begin
			X_counter <= X_counter + 1 ;
			if (X_counter==DEPTH-1) begin
				X_Valid <= 0 ;
			end
		end
	end
end

always @(*) begin
	if (rst) begin
		X = 0 ;
		W_Addr = 0 ;
	end
	else begin
		if (X_Valid) begin
			X = X_MEM[X_counter] ;
			W_Addr = X_counter ;
		end
	end
end

endmodule 