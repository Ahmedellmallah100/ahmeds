/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // ============================================================
  // Tiny Trainable Perceptron
  //
  // z = w1*x1 + w2*x2 + w3*x3 + w4*x4 + bias
  //
  // prediction = 1 if z >= 0
  // prediction = 0 if z < 0
  //
  // ui_in[3:0] : x1 x2 x3 x4
  // ui_in[4]   : target
  // ui_in[5]   : train_enable
  // ui_in[6]   : echo_enable
  // ============================================================


  // ------------------------------------------------------------
  // Inputs
  // ------------------------------------------------------------

  wire x1 = ui_in[0];
  wire x2 = ui_in[1];
  wire x3 = ui_in[2];
  wire x4 = ui_in[3];

  wire target       = ui_in[4];
  wire train_enable = ui_in[5];
  wire echo_enable  = ui_in[6];


  // ------------------------------------------------------------
  // Trainable weights
  //
  // 4-bit signed weights
  // ------------------------------------------------------------

  reg signed [3:0] w1;
  reg signed [3:0] w2;
  reg signed [3:0] w3;
  reg signed [3:0] w4;

  reg signed [5:0] bias;


  // ------------------------------------------------------------
  // Weighted inputs
  //
  // Since x = 0 or 1:
  //
  // x = 0 -> contribution = 0
  // x = 1 -> contribution = weight
  // ------------------------------------------------------------

  wire signed [5:0] p1;
  wire signed [5:0] p2;
  wire signed [5:0] p3;
  wire signed [5:0] p4;

  assign p1 = x1 ? w1 : 6'sd0;
  assign p2 = x2 ? w2 : 6'sd0;
  assign p3 = x3 ? w3 : 6'sd0;
  assign p4 = x4 ? w4 : 6'sd0;


  // ------------------------------------------------------------
  // Weighted Sum
  // ------------------------------------------------------------

  wire signed [5:0] z;

  assign z = p1 + p2 + p3 + p4 + bias;


  // ------------------------------------------------------------
  // Step Activation
  // ------------------------------------------------------------

  wire prediction;

  assign prediction = (z >= 0);


  // ------------------------------------------------------------
  // Error
  //
  // error = target - prediction
  //
  // Possible values:
  // -1, 0, +1
  // ------------------------------------------------------------

  wire signed [1:0] error;

  assign error = $signed({1'b0, target})
               - $signed({1'b0, prediction});


  // ------------------------------------------------------------
  // Learning rate
  //
  // We use learning_rate = 1
  //
  // Therefore:
  //
  // w = w + error*x
  // b = b + error
  // ------------------------------------------------------------


  // ------------------------------------------------------------
  // Training
  //
  // One training update happens on every rising clock
  // when train_enable = 1.
  // ------------------------------------------------------------

  always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin

      // Initial weights
      w1   <= 4'sd0;
      w2   <= 4'sd0;
      w3   <= 4'sd0;
      w4   <= 4'sd0;

      bias <= 6'sd0;

    end

    else if (train_enable) begin

      // Weight update
      if (error != 0) begin

        if (x1)
          w1 <= w1 + error;

        if (x2)
          w2 <= w2 + error;

        if (x3)
          w3 <= w3 + error;

        if (x4)
          w4 <= w4 + error;

        // Bias update
        bias <= bias + error;

      end

    end

  end


  // ------------------------------------------------------------
  // Output
  //
  // Normal mode:
  //
  // uo_out[0] = prediction
  // uo_out[6:1] = z
  //
  // Echo mode:
  //
  // uo_out = ui_in
  // ------------------------------------------------------------

  assign uo_out =
      echo_enable
      ? ui_in
      : {
          1'b0,
          z[5:0],
          prediction
        };


  // ------------------------------------------------------------
  // uio pins are not used
  // ------------------------------------------------------------

  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;


  // ------------------------------------------------------------
  // Prevent unused-input warnings
  // ------------------------------------------------------------

  wire _unused = &{ena, uio_in};

endmodule
