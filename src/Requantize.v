module Requantize #(
    parameter IN_WIDTH  = 18 ,   
    parameter OUT_WIDTH = 8  ,   
    parameter SHIFT     = 4      
)(
    input  signed [IN_WIDTH-1:0]  in ,
    output reg signed [OUT_WIDTH-1:0] out
);

    localparam signed [IN_WIDTH-1:0] MAX_POS = (1 <<< (OUT_WIDTH-1)) - 1 ;
    localparam signed [IN_WIDTH-1:0] MAX_NEG = -(1 <<< (OUT_WIDTH-1)) ;

    wire signed [IN_WIDTH-1:0] shifted ;
    assign shifted = in >>> SHIFT ;   

    always @(*) begin
        if (shifted > MAX_POS)
            out = MAX_POS[OUT_WIDTH-1:0] ;   
        else if (shifted < MAX_NEG)
            out = MAX_NEG[OUT_WIDTH-1:0] ;   
        else
            out = shifted[OUT_WIDTH-1:0] ;   
    end

endmodule
