module Multi_Neuron #(parameter WIDTH=8 , DEPTH=8 , No_Neuron=10 , IDLE = 0 , COUNT = 1)(
	input clk , rst , IN_Valid ,
	input signed [WIDTH-1:0] IN ,
	input  [$clog2(DEPTH)-1:0] RAM_ADDR ,
	output [WIDTH-1:0] out ,
	output wr_en ,
	output [$clog2(No_Neuron)-1:0] Address) ;

wire [(2*WIDTH) + 1:0] mem [0:No_Neuron-1] ;
wire signed [WIDTH-1:0] W_mem [0:No_Neuron-1] ;
wire signed [(WIDTH * No_Neuron)-1:0] B  ;

reg [WIDTH-1:0] out_mem [0:No_Neuron-1] ;

wire signed [WIDTH-1:0] X  ;
wire X_Valid ;
wire [$clog2(DEPTH)-1:0] W_Addr ; 
wire [$clog2(No_Neuron)-1:0] rd_addr [0:No_Neuron-1]  ;
wire signed [(2*WIDTH) + 1:0] result [0:No_Neuron-1]  ;
wire signed [WIDTH-1:0] mem_requant [0:No_Neuron-1] ;
wire N_Done [0:No_Neuron-1] ;
wire R_Done [0:No_Neuron-1] ;
wire [No_Neuron-1:0] R_2_count  ;
reg [$clog2(No_Neuron)-1:0] counter ;
reg cs , ns ;


wire count_en ;

assign count_en = &R_2_count ;

X_RAM #(.WIDTH(WIDTH),.DEPTH(DEPTH)) ram (.clk(clk),.rst(rst),.X_Valid(X_Valid),.X(X),.IN(IN),.IN_Valid(IN_Valid),.RAM_ADDR(RAM_ADDR),.W_Addr(W_Addr)) ;
B_ROM #(.WIDTH(WIDTH),.No_Neuron(No_Neuron)) brom (.clk(clk),.rst(rst),.Ram_Rom_Valid(X_Valid),.B(B)) ;
generate
	genvar i;
	for (i = 0; i < No_Neuron; i = i + 1) begin : gen_neuron
		assign R_2_count[i] = R_Done[i] ;
		assign rd_addr[i] = i ;

		always @(posedge clk or posedge rst) begin
			if (rst) begin
				out_mem[i] <= 0 ;
				
			end
			else  begin
				if (count_en) begin
					out_mem[i] <= mem_requant[i] ;
				end
			end
		end

		//Bias_Rom #(.WIDTH(WIDTH),.No_Neuron(No_Neuron)) brom (.clk(clk),.rst(rst),.Ram_Rom_Valid(X_Valid),.rd_addr(rd_addr[i]),.B(B_mem[i])) ;
		W_ROM #(.WIDTH(WIDTH),.DEPTH(DEPTH)) wrom (.clk(clk),.rst(rst),.Ram_Rom_Valid(X_Valid),.W_Addr(W_Addr),.W(W_mem[i])) ;
		Neuron #(.WIDTH(WIDTH),.No_Neuron(No_Neuron)) neuron (.clk(clk),.X(X),.W(W_mem[i]),.rst(rst),.en(X_Valid),.bias(B[i*WIDTH +: WIDTH]),.result(result[i]),.Done(N_Done[i]),.b_addr(rd_addr[i])) ;
		RELU #(.WIDTH(WIDTH)) relu (.IN(result[i]),.start(N_Done[i]),.out(mem[i]),.Done(R_Done[i])) ;
		Requantize #(.IN_WIDTH(2*WIDTH+2),.OUT_WIDTH(WIDTH),.SHIFT(4)) reqnt (.in(mem[i]), .out(mem_requant[i])) ;
	end
endgenerate

always @(posedge clk or posedge rst) begin
	if (rst) begin
		cs <= IDLE ;
		
	end
	else begin
		cs <= ns ;
	end
end

always @(*) begin
	case (cs)
		IDLE : ns = (count_en)? COUNT : IDLE ;
		COUNT : ns = (counter==No_Neuron-1)? IDLE : COUNT ;
		default : ns = IDLE ;
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		counter <= 0 ;
		
	end
	else begin
		case (cs) 
			IDLE : begin
				counter <= 0 ;
			end

			COUNT : begin
				counter <= counter + 1 ;
			end
		endcase
	end
end

assign out = (wr_en)? out_mem[counter] : 0 ;
assign wr_en = (cs==COUNT)? 1 : 0 ;
assign Address = counter ;

endmodule
