`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2024 02:34:06 PM
// Design Name: 
// Module Name: Timer
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


module Timer #(parameter BITS = 4)(
    input              clk, 
    input              reset_n, 
    input [BITS - 1:0] FINAL_VALUE,
    output             done
    );
    
    reg [BITS - 1:0] Q_next, Q_reg;
    
    always @(negedge clk or negedge reset_n)
    begin
        if(~reset_n)
            Q_reg <= 'b0;
        else
            Q_reg <= Q_next;
    end
    
    assign done = Q_reg == FINAL_VALUE;
    
    always @(*)
        Q_next = done? 'b0: Q_reg + 1;
        
endmodule
