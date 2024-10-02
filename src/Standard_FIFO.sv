`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 04:25:40 AM
// Design Name: 
// Module Name: Standard_FIFO
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


module Standard_FIFO #(parameter ADDR_WIDTH = 3, DATA_WIDTH = 8)(
    input  logic                    clk,        // Clock signal to synchronize operations
    input  logic                    reset,      // Asynchronous reset signal to initialize the FIFO
    input  logic                    rd,         // Read enable signal
    input  logic                    wr,         // Write enable signal
    input  logic [DATA_WIDTH - 1:0] w_data,     // Data to write to the FIFO
    output logic [DATA_WIDTH - 1:0] r_data,     // Output data from the read operation
    output logic                    empty,      // Empty flag (1 when FIFO is empty)
    output logic                    full        // Full flag (1 when FIFO is full)
    );
    
    logic [DATA_WIDTH - 1:0] data;
    
    // Instantiate the FIFO module
    FWFT_FIFO #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) fwft_fifo_inst (        
        .r_data(data), .*
    );
 
    D_FF_Nbit #(
        .N(DATA_WIDTH)
    ) D_FF_inst (
        .clk(clk), 
        .reset(reset),
        .enable(rd & ~empty),
        .D(data),
        .Q(r_data)
    );
    
endmodule
