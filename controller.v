`timescale 1ns/1ps
// ============================================================
// controller.v - Khoi dieu khien (Controller) - FSM 4 trang thai
// S_IDLE  : cho tin hieu start
// S_LOAD  : nap du lieu vao datapath (ld = 1)
// S_SHIFT : dich va dem 8 lan (sh = 1), thoat khi last_bit = 1
// S_DONE  : bao done = 1, giu ket qua, cho start ve 0
// ============================================================
module controller (
    input  wire clk,
    input  wire rst,
    input  wire start,     // bat dau dem
    input  wire last_bit,  // trang thai tu datapath
    output reg  ld,        // dieu khien datapath
    output reg  sh,
    output reg  done       // bao hoan thanh
);

    localparam S_IDLE  = 2'd0,
               S_LOAD  = 2'd1,
               S_SHIFT = 2'd2,
               S_DONE  = 2'd3;

    reg [1:0] state;       // thanh ghi trang thai
    reg [1:0] next_state;

    // Thanh ghi trang thai
    always @(posedge clk) begin
        if (rst) state <= S_IDLE;
        else     state <= next_state;
    end

    // Logic trang thai ke tiep
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:  if (start)    next_state = S_LOAD;
            S_LOAD:                next_state = S_SHIFT;
            S_SHIFT: if (last_bit) next_state = S_DONE;
            S_DONE:  if (!start)   next_state = S_IDLE;
            default:               next_state = S_IDLE;
        endcase
    end

    // Logic ngo ra (Moore)
    always @(*) begin
        ld   = 1'b0;
        sh   = 1'b0;
        done = 1'b0;
        case (state)
            S_LOAD:  ld   = 1'b1;
            S_SHIFT: sh   = 1'b1;
            S_DONE:  done = 1'b1;
            default: ;
        endcase
    end

endmodule
