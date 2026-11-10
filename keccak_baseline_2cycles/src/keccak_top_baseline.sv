import pkg_keccak::*;

module keccak_iterative_top (
    input  logic              clk,
    input  logic              rst_n,
    input  logic              start,          // Pulsed high to begin a new hash
    input  k_state            din,            // Initial input state
    output k_state            dout,           // Final hash output
    output logic              done            // High when 24 rounds are finished
);

    // Signals and Registers
    k_state      state_reg;
    k_state      round_out;
    logic [4:0]  round_counter;   // Counts from 0 to 23
    logic        calculating;
    logic [N-1:0] current_rc;     // Wire to hold the round constant from the generator

    // 1. Instantiate the Round Constants Generator
    keccak_round_constants_gen u_rc_gen (
        .round_number               (round_counter),
        .round_constant_signal_out  (current_rc)
    );

    // 2. Instantiate your single keccak_round module
    keccak_round u_round (
        .Round_in              (state_reg),
        .Round_constant_signal (current_rc),
        .Round_out             (round_out)
    );

    // 3. FSM / Controller Logic & Round Counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round_counter <= '0;
            calculating   <= 1'b0;
            state_reg     <= '0;
        end else begin
            if (start && !calculating) begin
                round_counter <= 5'd0;
                calculating   <= 1'b1;
                state_reg     <= din; // Load initial input on start
            end else if (calculating) begin
                state_reg     <= round_out; // Feed round output back into register
                
                if (round_counter == 5'd23) begin
                    calculating <= 1'b0;    // Finished all 24 rounds
                end else begin
                    round_counter <= round_counter + 1'b1;
                end
            end
        end
    end

    // Assign outputs
    assign dout = state_reg;
    assign done = ~calculating && (round_counter == 5'd23);

endmodule
