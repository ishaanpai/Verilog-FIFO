`timescale 1ns / 1ns
`include "FIFO.v"

module tb_top;

    parameter width = 16;
    parameter depth = 32;

    // Inputs to UUT (reg)
    reg LCLK;
    reg RCLK;
    reg WRDV;
    reg RDEN;
    reg [width-1:0] WRDAT;

    // Outputs from UUT (wire)
    wire F;
    wire E;
    wire [width-1:0] RDDAT;

    // Instantiate UUT (Note: Removed AF/AE since we removed them from your FIFO.v)
    top #(
        .width(width),
        .depth(depth)
    ) uut (
        .LCLK(LCLK),
        .RCLK(RCLK),
        .WRDV(WRDV),
        .RDEN(RDEN),
        .WRDAT(WRDAT),
        .F(F),
        .E(E),
        .RDDAT(RDDAT)
    );

    // 1. Simple, continuous clock generators (using distinct asynchronous speeds)
    always #5 LCLK = (LCLK === 1'b0) ? 1'b1 : 1'b0;
    always #7 RCLK = (RCLK === 1'b0) ? 1'b1 : 1'b0;

    // Helper integer for the manual unrolled generation
    integer idx;

    // 2. Linear Test Sequence
    initial begin
        // Initialize everything strictly to 0
        LCLK  = 0;
        RCLK  = 0;
        WRDV  = 0;
        RDEN  = 0;
        WRDAT = 0;

        // Open wave dump files
        $dumpfile("FIFO_tb.vcd");
        $dumpvars(0, tb_top);
        
        #20; // Let the system settle

        $display("--- STEP 1: FILLING UP THE FIFO COMPLETELY (32 WRITES) ---");

        // We will manually burst 35 items. 
        // The first 32 should succeed, the last 3 should hit the Full flag barrier.
        for (idx = 1; idx <= 35; idx = idx + 1) begin
            WRDAT = idx; // Inject a distinct counter pattern (1, 2, 3...)
            WRDV  = 1;
            #10;         // Hold for 1 LCLK cycle
            WRDV  = 0;
            #10;         // Pause 1 cycle between entries
            
            if (F == 1) begin
                $display("[%0t ns] FIFO Reported FULL at write attempt #%0d!", $time, idx);
            end
        end

        #50; // Give it a breather to let Gray codes synchronize fully

        $display("--- STEP 2: READING OUT 5 WORDS TO FREE UP SPACE ---");
        // Read 5 elements out. This will drop the full flag and advance rd_ptr to 5.
        for (idx = 0; idx < 5; idx = idx + 1) begin
            RDEN = 1;
            #14; // Hold for roughly 1 RCLK cycle
            RDEN = 0;
            $display("[%0t ns] READ SUCCESS: Data popped out = %d", $time, RDDAT);
            #14;
        end

        #50; // Wait for the new read pointer to safely cross the domain border back to LCLK

        $display("--- STEP 3: WRITING AGAIN TO WRAP AROUND (LAP 2) ---");
        // Now address 0, 1, 2, 3, and 4 are empty. 
        // These next writes will overwrite those physical slots.
        
        WRDAT = 16'hAAAA; // Will go into physical memory slot 0
        WRDV  = 1;
        #10;
        WRDV  = 0;
        #10;
        $display("[%0t ns] Wrote AAAA (Wrapping around to slot 0)", $time);

        WRDAT = 16'hBBBB; // Will go into physical memory slot 1
        WRDV  = 1;
        #10;
        WRDV  = 0;
        #10;
        $display("[%0t ns] Wrote BBBB (Wrapping around to slot 1)", $time);

        #50;

        $display("--- Hardcoded Wraparound Test Complete ---");
        $finish;
    end

endmodule