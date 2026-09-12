module RELU #(parameter WIDTH = 8)(
	input signed [(2*WIDTH) + 1:0] IN ,
	input start ,
	output signed [(2*WIDTH) + 1:0] out ,
	output Done) ;

assign out = (!start)? 0 : (IN > 0)? IN : 0  ;
assign Done = (start)? 1 : 0 ;

endmodule
