package pkg_keccak;

    parameter int NUM_PLANE             = 5;
    parameter int NUM_COLS             = 5;
    parameter int unsigned N            = 64;
    parameter int unsigned IN_BUF_SIZE  = 64;
    parameter int unsigned OUT_BUF_SIZE = 64;


    typedef logic   [N-1:0]             k_lane;
    typedef k_lane  [NUM_COLS-1:0]     k_plane;
    typedef k_plane [NUM_PLANE-1:0]     k_state;

    // With 'automatic', if two different blocks call ABS() at the same time,
    // their inputs and temporary variables are safely isolated.
    function automatic int ABS (int numberIn);
        ABS = (numberIn < 0) ? -numberIn : numberIn;
    endfunction
endpackage

