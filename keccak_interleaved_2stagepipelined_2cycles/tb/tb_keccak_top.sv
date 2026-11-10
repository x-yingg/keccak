`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2026 11:13:01 AM
// Design Name: 
// Module Name: tb_keccak_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import pkg_keccak::*;

module tb_keccak_two_stream_interleaved;

    // ------------------------------------------------
    // DUT signals
    // ------------------------------------------------

    logic clk;
    logic rst_n;

    logic valid_0;
    logic valid_1;

    k_state din_0;
    k_state din_1;

    logic ready_0;
    logic ready_1;

    k_state dout_0;
    k_state dout_1;

    logic done_0;
    logic done_1;


    // ------------------------------------------------
    // DUT instantiation
    // ------------------------------------------------

    keccak_two_stream_interleaved DUT (
        .clk     (clk),
        .rst_n   (rst_n),

        .valid_0 (valid_0),
        .din_0   (din_0),
        .ready_0 (ready_0),
        .dout_0  (dout_0),
        .done_0  (done_0),

        .valid_1 (valid_1),
        .din_1   (din_1),
        .ready_1 (ready_1),
        .dout_1  (dout_1),
        .done_1  (done_1)
    );


    // ------------------------------------------------
    // Clock generation: 100 MHz
    // ------------------------------------------------

    initial clk = 0;

    always #5 clk = ~clk;


    // ------------------------------------------------
    // Main test
    // ------------------------------------------------

    initial begin

        // Initialize signals
        rst_n   = 0;

        valid_0 = 0;
        valid_1 = 0;

        din_0 = '0;
        din_1 = '1;


        // Reset
        repeat (3) @(negedge clk);

        rst_n = 1;

        $display("--------------------------------------");
        $display("Starting Keccak two-stream test");
        $display("--------------------------------------");


        // ============================================
        // 1. Send first input: Stream 0
        // ============================================

        @(negedge clk);

        wait (ready_0 == 1);

        din_0   = '0;
        valid_0 = 1;

        $display("[%0t] Sending Stream 0 input", $time);

        @(negedge clk);

        valid_0 = 0;


        // ============================================
        // 2. Send second input: Stream 1
        // ============================================

        wait (ready_1 == 1);

        @(negedge clk);

        din_1   = 1600'h1234;
        valid_1 = 1;

        $display("[%0t] Sending Stream 1 input", $time);

        @(negedge clk);

        valid_1 = 0;


        // ============================================
        // 3. Wait for both outputs
        // ============================================

        fork

            begin
                wait (done_0 == 1);

                $display("[%0t] Stream 0 completed", $time);

                $display("Stream 0 output:");
                $display("%p", dout_0);
            end

            begin
                wait (done_1 == 1);

                $display("[%0t] Stream 1 completed", $time);

                $display("Stream 1 output:");
                $display("%p", dout_1);
            end

        join


        // ============================================
        // 4. Test completed
        // ============================================

        $display("--------------------------------------");
        $display("Both streams completed successfully!");
        $display("--------------------------------------");

        #20;

        $finish;

    end


    // ------------------------------------------------
    // Timeout protection
    // ------------------------------------------------

    initial begin
        #10000;

        $display("ERROR: Simulation timeout!");

        $finish;
    end

endmodule
