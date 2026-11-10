import pkg_keccak::*;

module keccak_two_stream_interleaved (
    input  logic             clk,
    input  logic             rst_n,

    // Stream 0
    input  logic             valid_0,
    input  k_state           din_0,
    output logic             ready_0,
    output k_state           dout_0,
    output logic             done_0,

    // Stream 1
    input  logic             valid_1,
    input  k_state           din_1,
    output logic             ready_1,
    output k_state           dout_1,
    output logic             done_1
);

    // ------------------------------------------------
    // Controller states
    // ------------------------------------------------

    typedef enum logic [1:0] {
        WAIT_A,
        WAIT_B,
        RUN,
        DRAIN
    } controller_state_t;

    controller_state_t controller_state;

    // ------------------------------------------------
    // Shared datapath registers
    // ------------------------------------------------

    k_state       state_reg;
    k_state       round_in;
    k_state       round_out;

    logic [4:0]   round_index;
    logic         active_stream;

    logic [N-1:0] current_rc;
    logic [N-1:0] phase2_rc;

    // ------------------------------------------------
    // Pipeline metadata
    // ------------------------------------------------

    logic         phase1_valid;
    logic         phase1_stream;
    logic [4:0]   phase1_round;

    logic         phase2_valid;
    logic         phase2_stream;
    logic [4:0]   phase2_round;

    // ------------------------------------------------
    // Handshake signals
    // ------------------------------------------------

    logic accept_a;
    logic accept_b;

    // ------------------------------------------------
    // Output registers
    // ------------------------------------------------

    k_state dout_0_reg;
    k_state dout_1_reg;

    assign dout_0 = dout_0_reg;
    assign dout_1 = dout_1_reg;


    // ------------------------------------------------
    // 1. Ready signals
    // ------------------------------------------------

    assign ready_0 = (controller_state == WAIT_A) ||
                     (controller_state == DRAIN);

    assign ready_1 = (controller_state == WAIT_B);

    assign accept_a = valid_0 && ready_0;
    assign accept_b = valid_1 && ready_1;


    // ------------------------------------------------
    // 2. Input MUX and pipeline scheduling
    // ------------------------------------------------

    always_comb begin

        // Default: feedback state
        round_in      = state_reg;

        phase1_valid  = 1'b0;
        phase1_stream = 1'b0;
        phase1_round  = 5'd0;

        case (controller_state)

            // Accept first input
            WAIT_A: begin
                if (accept_a) begin
                    round_in      = din_0;
                    phase1_valid  = 1'b1;
                    phase1_stream = 1'b0;
                    phase1_round  = 5'd0;
                end
            end

            // Accept second input
            WAIT_B: begin
                if (accept_b) begin
                    round_in      = din_1;
                    phase1_valid  = 1'b1;
                    phase1_stream = 1'b1;
                    phase1_round  = 5'd0;
                end
            end

            // Alternate between Stream 0 and Stream 1
            RUN: begin
                round_in      = state_reg;
                phase1_valid  = 1'b1;
                phase1_stream = active_stream;
                phase1_round  = round_index;
            end

            // Previous Stream 1 is finishing.
            // A new Stream 0 input can already be accepted.
            DRAIN: begin
                if (accept_a) begin
                    round_in      = din_0;
                    phase1_valid  = 1'b1;
                    phase1_stream = 1'b0;
                    phase1_round  = 5'd0;
                end
            end

            default: begin
                round_in = state_reg;
            end

        endcase
    end


    // ------------------------------------------------
    // 3. Round constant generator
    // ------------------------------------------------

    keccak_round_constants_gen u_rc_gen (
        .round_number              (phase1_round),
        .round_constant_signal_out (current_rc)
    );


    // ------------------------------------------------
    // 4. Align round constant with theta pipeline
    // ------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase2_rc <= '0;
        else
            phase2_rc <= current_rc;
    end


    // ------------------------------------------------
    // 5. Shared Keccak round datapath
    // ------------------------------------------------

    keccak_round u_round (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .Round_in              (round_in),
        .Round_constant_signal (phase2_rc),
        .Round_out             (round_out)
    );


    // ------------------------------------------------
    // 6. Main controller and feedback
    // ------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            controller_state <= WAIT_A;

            state_reg        <= '0;

            round_index      <= '0;
            active_stream    <= 1'b0;

            phase2_valid       <= 1'b0;
            phase2_stream      <= 1'b0;
            phase2_round       <= '0;

            dout_0_reg       <= '0;
            dout_1_reg       <= '0;

            done_0           <= 1'b0;
            done_1           <= 1'b0;

        end else begin

            // Done signals are one-cycle pulses
            done_0 <= 1'b0;
            done_1 <= 1'b0;


            // ----------------------------------------
            // Pipeline metadata
            // ----------------------------------------

            phase2_valid <= phase1_valid;

            if (phase1_valid) begin
                phase2_stream <= phase1_stream;
                phase2_round  <= phase1_round;
            end


            // ----------------------------------------
            // Capture completed Phase 2 result
            // ----------------------------------------

            if (phase2_valid) begin

                if (phase2_round == 5'd23) begin

                    // Final round of Stream 0
                    if (phase2_stream == 1'b0) begin
                        dout_0_reg <= round_out;
                        done_0     <= 1'b1;
                    end

                    // Final round of Stream 1
                    else begin
                        dout_1_reg <= round_out;
                        done_1     <= 1'b1;
                    end

                end else begin

                    // Feedback into the shared state register
                    state_reg <= round_out;

                end

            end


            // ----------------------------------------
            // Controller
            // ----------------------------------------

            case (controller_state)

                // First input accepted
                WAIT_A: begin

                    if (accept_a) begin
                        controller_state <= WAIT_B;
                        round_index      <= 5'd0;
                    end

                end


                // Second input accepted
                WAIT_B: begin

                    if (accept_b) begin

                        controller_state <= RUN;

                        // Next operation: Stream 0, Round 1
                        active_stream <= 1'b0;
                        round_index   <= 5'd1;

                    end

                end


                // Alternate between both streams
                RUN: begin

                    if (active_stream == 1'b0) begin

                        // Stream 0 operation completed.
                        // Next: Stream 1, same round.
                        active_stream <= 1'b1;

                    end else begin

                        // Stream 1 operation completed.
                        // Next: Stream 0, next round.
                        active_stream <= 1'b0;

                        if (round_index == 5'd23) begin

                            // Both streams have submitted Round 23.
                            controller_state <= DRAIN;

                        end else begin

                            round_index <= round_index + 1'b1;

                        end

                    end

                end


                // Wait for the final Stream 1 output
                DRAIN: begin

                    if (phase2_valid &&
                        phase2_stream &&
                        (phase2_round == 5'd23)) begin

                        // A new pair can begin immediately.
                        if (accept_a)
                            controller_state <= WAIT_B;
                        else
                            controller_state <= WAIT_A;

                    end

                end


                default: begin
                    controller_state <= WAIT_A;
                end

            endcase

        end
    end

endmodule