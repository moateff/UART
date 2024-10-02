`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2024 04:26:46 PM
// Design Name: 
// Module Name: REG_FILE
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


module REG_FILE #(parameter ADDR_WIDTH = 3, DATA_WIDTH = 8)(
    input  logic                    clk,            // Clock signal
    input  logic                    w_en,           // Write enable signal, controls write operation
    input  logic [ADDR_WIDTH - 1:0] r_addr,         // Read address input
    input  logic [ADDR_WIDTH - 1:0] w_addr,         // Write address input
    input  logic [DATA_WIDTH - 1:0] w_data,         // Data to write to the register file
    output logic [DATA_WIDTH - 1:0] r_data          // Output data from the read operation
    );

    // Memory array for register file storage
    // Size of memory is 2^ADDR_WIDTH, each element is DATA_WIDTH bits wide
    logic [DATA_WIDTH - 1:0] memory [0:2 ** ADDR_WIDTH - 1];
    
    // Initialize memory with zeros (for simulation purposes)
    initial begin
        integer i;
        // Loop through every memory location and set it to zero
        for (i = 0; i < 2 ** ADDR_WIDTH; i = i + 1) begin
            memory[i] = {DATA_WIDTH{1'b0}};         // Initialize each memory element with zeros
        end
    end
    
    // Write logic, triggered on the rising edge of the clock
    always_ff @(negedge clk) 
    begin
        if (w_en)                                  // If write enable is high
            memory[w_addr] <= w_data;              // Write the data to the specified address
    end 

    // Continuous assignment for the read operation
    // Data at r_addr is always available at r_data
    assign r_data = memory[r_addr];

endmodule
