# Keccak-f[1600] 

## 1. Baseline vs. Pipelined Implementation (1 Permutation)

Two implementations were synthesised and compared:

- **Baseline:** Conventional Keccak-f[1600] implementation.
- **Pipelined:** Added a register after the Theta step, dividing each round into two pipeline stages.

### Synthesis Results

| Metric (1 permutation) | Baseline | Pipelined |
|---|---:|---:|
| LUT | 3249 | 2586 |
| FF | 1606 | 2861 |
| Slice | 1013 | 1004 |
| Critical Path Delay (ns) | 3.373 | 3.216 |
| Clock Frequency (MHz) | 250 | 250 |
| Fmax (MHz) | 296.47 | 310.95 |
| Latency (cycles) | 24 | 48 |
| Latency (ns) | 96 | 192 |
| Throughput (Gbps) | 16.67 | 8.33 |
| ADP (LUT·ns) | 97.248 | 192.792 |
| Power (W) | 0.503 | 0.377 |

## 2. Baseline vs. Interleaved Pipelined Implementation (2 Permutation)

- **Baseline:** Conventional Keccak-f[1600] implementation.
- **Interleaved Pipelined:** Two-stream interleaved architecture with a shared datapath and a register after Theta. The controller alternates between the two streams to improve datapath utilisation.

### Timing Analysis

Both implementations were evaluated with a fixed clock period of 4 ns (250 MHz).

| Timing Metric | Baseline | Interleaved Pipelined |
|---|---:|---:|
| Clock Period (ns) | 4.000 | 4.000 |
| Critical Path Delay (ns) | 3.373 | 3.909 |
| Setup Slack (ns) | 0.605 | 0.069 |
| Logic Delay (ns) | 1.039 | 1.163 |
| Routing Delay (ns) | 2.334 | 2.746 |
| Logic Levels | 3 | 4 |

### Timing Summary

**Baseline:**
```
Max Delay Paths
--------------------------------------------------------------------------------------
Slack (MET) :             0.605ns  (required time - arrival time)
  Source:                 state_reg_reg[0][4][61]/C
                            (rising edge-triggered cell FDCE clocked by clk  {rise@0.000ns fall@2.000ns period=4.000ns})
  Destination:            state_reg_reg[0][0][61]/D
                            (rising edge-triggered cell FDCE clocked by clk  {rise@0.000ns fall@2.000ns period=4.000ns})
  Path Group:             clk
  Path Type:              Setup (Max at Slow Process Corner)
  Requirement:            4.000ns  (clk rise@4.000ns - clk rise@0.000ns)
  Data Path Delay:        3.373ns  (logic 1.039ns (30.803%)  route 2.334ns (69.197%))
  Logic Levels:           3  (LUT6=3)
  Clock Path Skew:        -0.049ns (DCD - SCD + CPR)
    Destination Clock Delay (DCD):    0.924ns = ( 4.924 - 4.000 ) 
    Source Clock Delay      (SCD):    0.973ns
    Clock Pessimism Removal (CPR):    0.000ns
  Clock Uncertainty:      0.035ns  ((TSJ^2 + TIJ^2)^1/2 + DJ) / 2 + PE
    Total System Jitter     (TSJ):    0.071ns
    Total Input Jitter      (TIJ):    0.000ns
    Discrete Jitter          (DJ):    0.000ns
    Phase Error              (PE):    0.000ns

    Location             Delay type                Incr(ns)  Path(ns)    Netlist Resource(s)
  -------------------------------------------------------------------    -------------------
                         (clock clk rise edge)        0.000     0.000 r  
                                                      0.000     0.000 r  clk (IN)
                         net (fo=1605, unset)         0.973     0.973    clk
                         FDCE                                         r  state_reg_reg[0][4][61]/C
  -------------------------------------------------------------------    -------------------
                         FDCE (Prop_fdce_C_Q)         0.496     1.469 r  state_reg_reg[0][4][61]/Q
                         net (fo=1, unplaced)         0.965     2.434    dout[0][4][61]
                         LUT6 (Prop_lut6_I0_O)        0.295     2.729 r  state_reg[0][4][61]_i_4/O
                         net (fo=1, unplaced)         0.449     3.178    state_reg[0][4][61]_i_4_n_0
                         LUT6 (Prop_lut6_I5_O)        0.124     3.302 r  state_reg[0][4][61]_i_2/O
                         net (fo=3, unplaced)         0.920     4.222    state_reg[0][4][61]_i_2_n_0
                         LUT6 (Prop_lut6_I1_O)        0.124     4.346 r  state_reg[0][0][61]_i_1/O
                         net (fo=1, unplaced)         0.000     4.346    state_reg[0][0][61]_i_1_n_0
                         FDCE                                         r  state_reg_reg[0][0][61]/D
  -------------------------------------------------------------------    -------------------

                         (clock clk rise edge)        4.000     4.000 r  
                                                      0.000     4.000 r  clk (IN)
                         net (fo=1605, unset)         0.924     4.924    clk
                         FDCE                                         r  state_reg_reg[0][0][61]/C
                         clock pessimism              0.000     4.924    
                         clock uncertainty           -0.035     4.889    
                         FDCE (Setup_fdce_C_D)        0.062     4.951    state_reg_reg[0][0][61]
  -------------------------------------------------------------------
                         required time                          4.951    
                         arrival time                          -4.346    
  -------------------------------------------------------------------
                         slack                                  0.605
```
**Interleaved Pipelined:** 
```
Max Delay Paths
--------------------------------------------------------------------------------------
Slack (MET) :             0.069ns  (required time - arrival time)
  Source:                 FSM_sequential_controller_state_reg[1]/C
                            (rising edge-triggered cell FDCE clocked by clk  {rise@0.000ns fall@2.000ns period=4.000ns})
  Destination:            u_round/theta_reg_reg[0][3][1]/D
                            (rising edge-triggered cell FDCE clocked by clk  {rise@0.000ns fall@2.000ns period=4.000ns})
  Path Group:             clk
  Path Type:              Setup (Max at Slow Process Corner)
  Requirement:            4.000ns  (clk rise@4.000ns - clk rise@0.000ns)
  Data Path Delay:        3.909ns  (logic 1.163ns (29.752%)  route 2.746ns (70.2048%))
  Logic Levels:           4  (LUT3=2 LUT5=2)
  Clock Path Skew:        -0.049ns (DCD - SCD + CPR)
    Destination Clock Delay (DCD):    0.924ns = ( 4.924 - 4.000 ) 
    Source Clock Delay      (SCD):    0.973ns
    Clock Pessimism Removal (CPR):    0.000ns
  Clock Uncertainty:      0.035ns  ((TSJ^2 + TIJ^2)^1/2 + DJ) / 2 + PE
    Total System Jitter     (TSJ):    0.071ns
    Total Input Jitter      (TIJ):    0.000ns
    Discrete Jitter          (DJ):    0.000ns
    Phase Error              (PE):    0.000ns

    Location             Delay type                Incr(ns)  Path(ns)    Netlist Resource(s)
  -------------------------------------------------------------------    -------------------
                         (clock clk rise edge)        0.000     0.000 r  
                                                      0.000     0.000 r  clk (IN)
                         net (fo=6068, unset)         0.973     0.973    clk
                         FDCE                                         r  FSM_sequential_controller_state_reg[1]/C
  -------------------------------------------------------------------    -------------------
                         FDCE (Prop_fdce_C_Q)         0.496     1.469 f  FSM_sequential_controller_state_reg[1]/Q
                         net (fo=26, unplaced)        0.536     2.005    u_round/controller_state[1]
                         LUT3 (Prop_lut3_I1_O)        0.295     2.300 r  u_round/round_index[4]_i_3/O
                         net (fo=798, unplaced)       1.042     3.342    u_round/valid_1_0
                         LUT5 (Prop_lut5_I0_O)        0.124     3.466 r  u_round/theta_reg[4][4][0]_i_2/O
                         net (fo=2, unplaced)         0.676     4.142    u_round/theta_reg[4][4][0]_i_2_n_0
                         LUT5 (Prop_lut5_I1_O)        0.124     4.266 r  u_round/theta_reg[1][3][1]_i_4/O
                         net (fo=10, unplaced)        0.492     4.758    u_round/p_5870_in
                         LUT3 (Prop_lut3_I2_O)        0.124     4.882 r  u_round/theta_reg[0][3][1]_i_1/O
                         net (fo=1, unplaced)         0.000     4.882    u_round/p_771_out
                         FDCE                                         r  u_round/theta_reg_reg[0][3][1]/D
  -------------------------------------------------------------------    -------------------

                         (clock clk rise edge)        4.000     4.000 r  
                                                      0.000     4.000 r  clk (IN)
                         net (fo=6068, unset)         0.924     4.924    u_round/clk
                         FDCE                                         r  u_round/theta_reg_reg[0][3][1]/C
                         clock pessimism              0.000     4.924    
                         clock uncertainty           -0.035     4.889    
                         FDCE (Setup_fdce_C_D)        0.062     4.951    u_round/theta_reg_reg[0][3][1]
  -------------------------------------------------------------------
                         required time                          4.951    
                         arrival time                          -4.882    
  -------------------------------------------------------------------
                         slack                                  0.069    
```
### Observations
- The interleaved implementation has a longer critical path than the baseline.
- Setup slack decreased from 0.605 ns to 0.069 ns.


