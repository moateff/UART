`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 04:21:36 AM
// Design Name: 
// Module Name: D_FF_Nbit
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


module D_FF_Nbit #(parameter N = 8)(
    input  logic           clk, 
    input  logic           reset,
    input  logic           enable,
    input  logic [N - 1:0] D,
    output logic [N - 1:0] Q
    );
    logic [N - 1:0] Q_next, Q_reg;
    
    always_ff @(negedge clk or posedge reset)
    begin
        if(reset)
            Q_reg <= 'bx;
        else if(enable)
            Q_reg <= Q_next;
        else
            Q_reg <= Q_reg;
    end
    
    always_comb
        Q_next = D;
    
    assign Q = Q_reg;
    
endmodule
