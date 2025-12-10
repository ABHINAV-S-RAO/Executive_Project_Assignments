`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2025 02:43:13 PM
// Design Name: 
// Module Name: lfsr
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


module lfsr(
    input wire clk,
    input wire reset,
    input wire en,
    output reg[15:0] out
    );
    reg[15:0] r;
    wire feedback=r[15]^r[13]^r[12]^r[10];//a common tap set
    
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            r<=16'hACE1;//any non zero seed 
            out<=16'hACE1;
        end 
        else if(en) begin
            r<={r[14:0],feedback};
            out<={r[14:0], feedback};
        end
    end
    
endmodule
