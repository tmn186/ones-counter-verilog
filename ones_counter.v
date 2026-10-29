`timescale 1ns/1ps
// ============================================================
// ones_counter.v - Top-level: noi Datapath va Controller
// ============================================================
module ones_counter #(
    parameter N     = 8,
    parameter CNT_W = 4
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             start,
    input  wire [N-1:0]     data_in,
    output wire [CNT_W-1:0] count_out,
    output wire             done
);

    wire ld, sh, last_bit;

    controller u_ctrl (
        .clk      (clk),
        .rst      (rst),
        .start    (start),
        .last_bit (last_bit),
        .ld       (ld),
        .sh       (sh),
        .done     (done)
    );

    datapath #(.N(N), .CNT_W(CNT_W)) u_dp (
        .clk       (clk),
        .rst       (rst),
        .data_in   (data_in),
        .ld        (ld),
        .sh        (sh),
        .last_bit  (last_bit),
        .count_out (count_out)
    );

endmodule
