`timescale 1ns/1ps

module Simulated_annealing_tb;

    reg clk;
    reg reset;
    reg start;

    wire done;
    wire signed [15:0] best_x;
    wire signed [15:0] best_cost;

    // DUT
    Simulated_annealing uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .best_x(best_x),
        .best_cost(best_cost)
    );

    // clock generation
    always #5 clk = ~clk;   // 100MHz clock (10ns period)

    initial begin
        $display(" ---- SIMULATED ANNEALING (VERILOG) TB STARTED ----");
        clk = 0;
        reset = 1;
        start = 0;

        #50 reset = 0;   // release reset

        #50;
        start = 1;       // start pulse
        #10 start = 0;

        // print header
        $display(" time       | best_x      best_cost ");

        // monitor changes
        forever begin
            #100;   // print every 100ns
            $display(" %8dns | x=%d  cost=%d", $time, best_x, best_cost);
        end
    end

    // detect DONE and finish simulation
    always @(posedge done) begin
        $display(" ---- ALGORITHM FINISHED ----");
        $display(" Final best_x   = %d", best_x);
        $display(" Final best_cost= %d", best_cost);
        #50 $finish;
    end

endmodule
