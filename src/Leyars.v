module Leyars #(parameter WIDTH=8 , DEPTH=8 , No_Neuron_0=10 , No_Neuron_1=5 , No_Neuron_2=3 , No_Neuron_3=1 , IDLE = 0 , COUNT = 1 )(
        input clk , rst , IN_Valid ,
		  input signed [WIDTH-1:0] IN ,
		  input [$clog2(DEPTH)-1:0] RAM_ADDR ,
		  output [WIDTH-1:0] Final_out ,
		  output Final_Done              );



wire [WIDTH-1:0] out_0 , out_1 , out_2 ;
wire wr_en_0 , wr_en_1 , wr_en_2 ;

wire [$clog2(No_Neuron_0)-1:0] Address_0 ;
wire [$clog2(No_Neuron_1)-1:0] Address_1 ;
wire [$clog2(No_Neuron_2)-1:0] Address_2 ;


Multi_Neuron #(.WIDTH(WIDTH),.DEPTH(DEPTH),.No_Neuron(No_Neuron_0),.IDLE(IDLE),.COUNT(COUNT))
   layer_0    (.clk(clk),.rst(rst),.IN_Valid(IN_Valid),.IN(IN),.RAM_ADDR(RAM_ADDR),.out(out_0),.wr_en(wr_en_0),.Address(Address_0)) ;

Multi_Neuron #(.WIDTH(WIDTH),.DEPTH(No_Neuron_0),.No_Neuron(No_Neuron_1),.IDLE(IDLE),.COUNT(COUNT))
   layer_1    (.clk(clk),.rst(rst),.IN_Valid(wr_en_0),.IN(out_0),.RAM_ADDR(Address_0),.out(out_1),.wr_en(wr_en_1),.Address(Address_1)) ;

Multi_Neuron #(.WIDTH(WIDTH),.DEPTH(No_Neuron_1),.No_Neuron(No_Neuron_2),.IDLE(IDLE),.COUNT(COUNT))
   layer_2    (.clk(clk),.rst(rst),.IN_Valid(wr_en_1),.IN(out_1),.RAM_ADDR(Address_1),.out(out_2),.wr_en(wr_en_2),.Address(Address_2)) ;

Single_Neuron #(.WIDTH(WIDTH),.DEPTH(No_Neuron_2),.No_Neuron(No_Neuron_3))
   out_layer   (.clk(clk),.rst(rst),.IN_Valid(wr_en_2),.IN(out_2),.RAM_ADDR(Address_2),.out(Final_out),.Done(Final_Done)) ;

endmodule