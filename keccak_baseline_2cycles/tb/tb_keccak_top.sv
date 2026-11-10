`timescale 1ns / 1ps


module tb_keccak_top();
    // Testbench signals
    logic        clk;
    logic        rst_n;
    logic        start;
    k_state      din;
    k_state      dout;
    logic        done;

    // Instantiate the iterative top-level wrapper
    keccak_iterative_top uut (
        .clk   (clk),
        .rst_n (rst_n),
        .start (start),
        .din   (din),
        .dout  (dout),
        .done  (done)
    );

    // Generate Clock: 10ns period -> 100 MHz
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Stimulus process
initial begin
    rst_n = 1'b0;
    start = 1'b0;
    din   = '0;

    // Hold reset for 20 ns
    #20;
    rst_n = 1'b1;
    #20;

    // -------- Test 1 --------
    @(negedge clk);
    din   = '0;
    start = 1'b1;

    @(negedge clk);
    start = 1'b0;

    // Wait for first operation to complete
    @(posedge done);
    $display("Test 1 completed at %0t ns, dout = %h", $time, dout);

    // -------- Test 2 --------
    @(negedge clk);
    din   = 1600'h1234;  // Second input vector
    start = 1'b1;

    @(negedge clk);
    start = 1'b0;

    // Wait for second operation to complete
    @(posedge done);
    $display("Test 2 completed at %0t ns, dout = %h", $time, dout);

    #20;
    $finish;
    end
endmodule
