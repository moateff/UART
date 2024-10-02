`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2024 04:26:46 PM
// Design Name: 
// Module Name: FIFO
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


module FWFT_FIFO #(parameter ADDR_WIDTH = 3, DATA_WIDTH = 8)(
    input  logic                    clk,        // Clock signal to synchronize operations
    input  logic                    reset,      // Asynchronous reset signal to initialize the FIFO
    input  logic                    rd,         // Read enable signal
    input  logic                    wr,         // Write enable signal
    input  logic [DATA_WIDTH - 1:0] w_data,     // Data to write to the FIFO
    output logic [DATA_WIDTH - 1:0] r_data,     // Output data from the read operation
    output logic                    empty,      // Empty flag (1 when FIFO is empty)
    output logic                    full        // Full flag (1 when FIFO is full)
    );
    
    logic [ADDR_WIDTH - 1:0] r_addr;     // Read address
    logic [ADDR_WIDTH - 1:0] w_addr;     // Write address
    
    // Instantiate the REG_FILE module
    REG_FILE #(
        .ADDR_WIDTH(ADDR_WIDTH),   // Parameter for address width
        .DATA_WIDTH(DATA_WIDTH)    // Parameter for data width
    ) reg_file_inst (
        .w_en(wr & ~full), .*              // Connect write enable signal
    );
        
    // Instantiate the FIFO_CONTROL module
    FIFO_CONTROL #(
        .ADDR_WIDTH(ADDR_WIDTH), 
        .DATA_WIDTH(DATA_WIDTH)    
    ) fifo_control_inst (.*);
    
endmodule
