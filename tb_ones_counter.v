// ============================================================
// tb_ones_counter.v - Testbench
// Thu 5 chuoi dau vao, tu dong so sanh ket qua, xuat file VCD
// ============================================================
`timescale 1ns/1ps
module tb_ones_counter;

    localparam N = 8, CNT_W = 4;

    reg              clk = 0;
    reg              rst = 1;
    reg              start = 0;
    reg  [N-1:0]     data_in = 0;
    wire [CNT_W-1:0] count_out;
    wire             done;

    ones_counter #(.N(N), .CNT_W(CNT_W)) dut (
        .clk(clk), .rst(rst), .start(start), .data_in(data_in),
        .count_out(count_out), .done(done)
    );

    always #5 clk = ~clk;   // chu ky 10 ns

    integer errors = 0;

    task run_case(input [N-1:0] vec, input [CNT_W-1:0] expected);
        begin
            @(negedge clk);
            data_in = vec;
            start   = 1;
            wait (done == 1);
            @(negedge clk);
            if (count_out === expected)
                $display("PASS  data_in=%b  count=%0d", vec, count_out);
            else begin
                $display("FAIL  data_in=%b  count=%0d  expected=%0d", vec, count_out, expected);
                errors = errors + 1;
            end
            start = 0;
            @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("ones_counter.vcd");
        $dumpvars(0, tb_ones_counter);

        repeat (2) @(negedge clk);
        rst = 0;

        run_case(8'b00000000, 4'd0);
        run_case(8'b11111111, 4'd8);
        run_case(8'b10101010, 4'd4);
        run_case(8'b11010011, 4'd5);
        run_case(8'b10000001, 4'd2);

        if (errors == 0) $display("=== ALL TESTS PASSED ===");
        else             $display("=== %0d TEST(S) FAILED ===", errors);
        $finish;
    end

endmodule
