`default_nettype none

module tt_um_yourname_nn (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    wire rst = ~rst_n;

    wire [7:0] final_out;
    wire final_done;

    Leyars #(
        .WIDTH(8),
        .DEPTH(8),
        .No_Neuron_0(10),
        .No_Neuron_1(5),
        .No_Neuron_2(3),
        .No_Neuron_3(1)
    ) nn (
        .clk(clk),
        .rst(rst),
        .IN_Valid(uio_in[3]),
        .IN($signed(ui_in)),
        .RAM_ADDR(uio_in[2:0]),
        .Final_out(final_out),
        .Final_Done(final_done)
    );

    assign uo_out = final_out;

    assign uio_out = {7'b0, final_done};
    assign uio_oe  = 8'b0000_0001;

endmodule

`default_nettype wire