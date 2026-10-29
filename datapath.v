`timescale 1ns/1ps
// ============================================================
// datapath.v - Khoi duong dan du lieu (Datapath)
// Bai: Dem so bit 1 trong chuoi 8 bit
// Gom: thanh ghi dich (shift register), bo dem bit 1 (ones_cnt),
//      bo dem so lan dich (bit_cnt)
// ============================================================
module datapath #(
    parameter N     = 8,   // do rong du lieu vao
    parameter CNT_W = 4    // do rong bo dem (dem duoc toi 8)
)(
    input  wire             clk,
    input  wire             rst,       // reset dong bo, muc cao
    input  wire [N-1:0]     data_in,   // chuoi bit can dem
    // Tin hieu dieu khien tu Controller
    input  wire             ld,        // nap data_in vao thanh ghi dich, xoa bo dem
    input  wire             sh,        // dich 1 bit va cong don neu bit = 1
    // Tin hieu trang thai gui ve Controller
    output wire             last_bit,  // = 1 khi dang xu ly bit cuoi cung
    // Ket qua
    output wire [CNT_W-1:0] count_out
);

    reg [N-1:0]     shreg;     // thanh ghi dich
    reg [CNT_W-1:0] ones_cnt;  // so bit 1 da dem
    reg [CNT_W-1:0] bit_cnt;   // so bit da dich

    always @(posedge clk) begin
        if (rst) begin
            shreg    <= {N{1'b0}};
            ones_cnt <= {CNT_W{1'b0}};
            bit_cnt  <= {CNT_W{1'b0}};
        end else if (ld) begin
            shreg    <= data_in;
            ones_cnt <= {CNT_W{1'b0}};
            bit_cnt  <= {CNT_W{1'b0}};
        end else if (sh) begin
            shreg    <= shreg >> 1;             // dich phai 1 bit
            ones_cnt <= ones_cnt + shreg[0];    // cong bit LSB vao bo dem
            bit_cnt  <= bit_cnt + 1'b1;
        end
    end

    assign last_bit  = (bit_cnt == N - 1);
    assign count_out = ones_cnt;

endmodule
