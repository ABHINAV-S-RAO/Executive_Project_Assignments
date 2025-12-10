`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2025 02:43:13 PM
// Design Name: 
// Module Name: Simulated_annealing
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


module Simulated_annealing #(
    parameter FRAC=12,
    parameter ITER_MAX=16'd2000
    )(
    input wire clk,
    input wire reset,
    input wire start,
    output reg done,
    output reg signed[15:0] best_x,//Q4.12
    output reg signed[31:0] best_cost//Q4.12
    );
    
    //FSM states
    localparam S_IDLE=3'd0;
    localparam S_INIT=3'd1;
    localparam S_GEN_NEI=3'd2;
    localparam S_COST_CURR=3'd3;
    localparam S_COST_NEW=3'd4;
    localparam S_DECIDE=3'd5;
    localparam S_UPDATE=3'd6;
    localparam S_DONE=3'd7;
    
    //Random Number Generator
    wire [15:0] rnd;
    reg lfsr_en;
    lfsr rng(.clk(clk),.reset(reset),.en(lfsr_en),.out(rnd));
    
    //registers(Q4.12)
    reg[2:0] state,next_state;
    reg signed [15:0] x_reg; 
    reg signed [15:0] new_x_reg;
    reg signed [31:0] curr_cost_reg;
    reg signed [31:0] new_cost_reg;
    reg signed [31:0] T_reg;
    reg[15:0] iter_cnt;
     
     //helper: small step from rnd(scale down)
     wire signed[15:0] step_raw={{8{rnd[7]}},rnd[7:0]};//Sign extend 8 bit to 16 bit
     wire signed[15:0] step_small=step_raw<<<2;//Reduce magnitude 
     
    //delta E
    wire signed [31:0] deltaE = new_cost_reg - curr_cost_reg;
     
    //fixed point multiply function 
    function signed[15:0] fp_mul;
    input signed [15:0] a,b;
    reg signed [31:0] tmp;
    begin 
    tmp=a*b;
    fp_mul=tmp>>>FRAC;
    end
    endfunction
    
    //cost function - E(X)=X^4-10X^2+9X (all in Q4.12)
    function[31:0] cost_fn;
    input signed[15:0] x;
    reg signed[15:0] x2;
    reg signed[15:0] x4;
    reg signed[15:0] term1,term2,term3;
    localparam signed [15:0] C10=16'sd10<<<FRAC;
    localparam signed [15:0] C9=16'sd9<<<FRAC;
    begin 
    x2=fp_mul(x,x);
    x4=fp_mul(x2,x2);
    term1=x4;
    term2=fp_mul(-C10,x2);
    term3=fp_mul(C9,x);
    cost_fn=term1+term2+term3;
    end 
    endfunction
    
    //FSM next state
    always@(*)begin 
    next_state=state;
    case(state) 
    S_IDLE: if(start) next_state=S_INIT;
    S_INIT: next_state=S_GEN_NEI;
    S_GEN_NEI: next_state=S_COST_CURR;
    S_COST_CURR: next_state=S_COST_NEW;
    S_COST_NEW: next_state=S_DECIDE;
    S_DECIDE: next_state= S_UPDATE;
    S_UPDATE: if(iter_cnt>=ITER_MAX) next_state=S_DONE; else next_state=S_GEN_NEI;
    S_DONE: if(!start) next_state=S_IDLE;
    default: next_state=S_IDLE;
    endcase
    end
    
  //---------------------------------------------------------
// Probability LUT (exp(-x)) - Q0.16 format
//---------------------------------------------------------
reg [15:0] exp_lut [0:15];
initial begin
    exp_lut[0]  = 16'd65535;
    exp_lut[1]  = 16'd24080;
    exp_lut[2]  = 16'd8865;
    exp_lut[3]  = 16'd3265;
    exp_lut[4]  = 16'd1200;
    exp_lut[5]  = 16'd440;
    exp_lut[6]  = 16'd162;
    exp_lut[7]  = 16'd59;
    exp_lut[8]  = 16'd22;
    exp_lut[9]  = 16'd8;
    exp_lut[10] = 16'd3;
    exp_lut[11] = 16'd1;
    exp_lut[12] = 16'd0;
    exp_lut[13] = 16'd0;
    exp_lut[14] = 16'd0;
    exp_lut[15] = 16'd0;
end

//---------------------------------------------------------
// Acceptance probability computation
//---------------------------------------------------------

// deltaE is 32-bit in your design
wire signed [31:0] deltaE_val = new_cost_reg - curr_cost_reg;

// absolute deltaE
wire signed [31:0] deltaE_abs = deltaE_val[31] ? -deltaE_val : deltaE_val;

// safe temperature (avoid divide-by-zero)
wire signed [31:0] T_safe = (T_reg == 0) ? 32'sd1 : T_reg;

// ratio = (deltaE_abs << FRAC) / T
wire signed [31:0] ratio_long = (deltaE_abs <<< FRAC) / T_safe;

// LUT index = upper bits of ratio
wire [3:0] lut_index = ratio_long[15:12] > 4'd15 ? 4'd15 : ratio_long[15:12];

// probability (Q0.16)
wire [15:0] accept_prob = exp_lut[lut_index];

// random accept?
wire accept_random = (rnd < accept_prob);


    
    //FSM Sequential logic
    always@(posedge clk or posedge reset)begin
    if(reset) begin
    state<=S_IDLE;
    done<=1'b0;
    iter_cnt<=16'd0;
    x_reg<=16'sd0;
    new_x_reg<=16'sd0;
    curr_cost_reg<=16'sd0;
    new_cost_reg<=16'sd0;
    T_reg<=16'sd0;
    best_x<=16'sd0;
    best_cost<=16'sh7FFF;
    lfsr_en<=1'b0;
    end
    else begin
    state<=next_state;
    //default disable LFSR ; will enable in the state that needs it 
    lfsr_en<=1'b0;
    
    case(next_state)
    S_INIT:begin
         x_reg<=16'sd5<<<FRAC;//X=5.0
         T_reg<=32'sd10<<<FRAC;//T=10.0
         best_x<=16'sd5<<<FRAC;
         best_cost<=cost_fn(16'sd5<<<FRAC);
         iter_cnt<=16'd0;
    end
    
    S_GEN_NEI:begin
        //enable LFSR for a new random number and compute neighbour
        lfsr_en<=1'b1;
        new_x_reg<=x_reg+step_small;
       end
       
    S_COST_CURR:begin
        curr_cost_reg<=cost_fn(x_reg);
    end
    
    S_COST_NEW:begin
        new_cost_reg<=cost_fn(new_x_reg);
    end
    
    S_DECIDE:begin
   // Metropolis acceptance:
   // accept if new cost is lower OR accept_random is true
        if ((deltaE < 0) || (accept_random)) begin
           x_reg <= new_x_reg;
           curr_cost_reg <= new_cost_reg;
        end

    // track global best (note: curr_cost_reg updated on accept)
        if (curr_cost_reg < best_cost) begin
            best_cost <= curr_cost_reg;
            best_x <= x_reg;
        end
        end

   
   S_UPDATE: begin
   iter_cnt<=iter_cnt+16'd1;
   //crude temperature decrease: subtract small quantity
   
   if(T_reg>(16'sd1<<<(FRAC-4)))
   T_reg<=T_reg-(16'sd1<<<(FRAC-4));
   else 
   T_reg<=0;
   end
   
   S_DONE:
   begin
   done<=1'b1;
   end
   endcase
   end 
   end 

   
    
endmodule
