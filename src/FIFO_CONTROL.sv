`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2024 02:26:54 PM
// Design Name: 
// Module Name: controller
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


module FIFO_CONTROL #(parameter ADDR_WIDTH = 3, DATA_WIDTH = 8)(
    input  logic                    clk,        // Clock signal to synchronize operations
    input  logic                    reset,      // Asynchronous reset signal to initialize the FIFO
    input  logic                    rd,         // Read enable signal
    input  logic                    wr,         // Write enable signal
    output logic [ADDR_WIDTH - 1:0] r_addr,     // Read address pointer (output)
    output logic [ADDR_WIDTH - 1:0] w_addr,     // Write address pointer (output)
    output logic                    empty,      // Empty flag (1 when FIFO is empty)
    output logic                    full        // Full flag (1 when FIFO is full)
    );
    
    // Local parameters defining control modes
    localparam logic [1:0] READ       = 2'b01,   // Read operation
                           WRITE      = 2'b10,   // Write operation
                           READ_WRITE = 2'b11;   // Simultaneous read and write operation
                           
    // Write and read pointers to manage the circular FIFO
   logic [ADDR_WIDTH - 1:0] wr_ptr;   // Write pointer (rear of the FIFO)
   logic [ADDR_WIDTH - 1:0] rd_ptr;   // Read pointer (front of the FIFO)
   
   // Length keeps track of the number of elements in the FIFO (can count up to one more than ADDR_WIDTH)
   logic [ADDR_WIDTH : 0] length;     // Tracks the current number of elements in the FIFO
   
   // Sequential block to update pointers and length on the rising edge of the clock or during reset
   always_ff @(negedge clk or posedge reset)
   begin
       rd_ptr <= rd_ptr;                 // Update read pointer
       wr_ptr <= wr_ptr;                 // Update write pointer
       length <= length;                 // Update length of FIFO
       
       if(reset)    // On reset, initialize the pointers and length
       begin
           rd_ptr <= 0;                            // Initialize read pointer to 0
           wr_ptr <= 0;                           // Initialize write pointer to 0
           length <= 0;                           // Initialize FIFO length to 0 (FIFO is empty)
       end
       else    // On every clock edge, update the pointers and length
       begin
           // Based on the read and write enable signals, determine FIFO operation
           case({wr, rd})
           READ:    // Read operation
           begin
               if(~empty)   // If FIFO is not empty
               begin   
                   rd_ptr = rd_ptr + 1;       // Move the read pointer forward
                   length = length - 1;       // Decrease the length since we're reading one element
               end
           end
           WRITE:   // Write operation
           begin
               if(~full)   // If FIFO is not full
               begin
                   wr_ptr = wr_ptr + 1;       // Move the write pointer forward
                   length = length + 1;       // Increase the length since we're adding one element
               end
           end
           READ_WRITE:   // Simultaneous read and write operation
           begin
               if(~empty)   // If FIFO is not empty
               begin
                   rd_ptr = rd_ptr + 1;       // Move the read pointer forward
                   length = length - 1;       // Decrease the length since we're reading one element
               end
               if(~full)   // If FIFO is not full
               begin
                   wr_ptr = wr_ptr + 1;       // Move the write pointer forward
                   length = length + 1;       // Increase the length since we're adding one element
               end
           end
           default: ;   // Default case for no operation
           endcase 
       end
   end
      
   // Check whether the FIFO is empty or full based on the length
   assign empty = (length == 0) ? 1'b1 : 1'b0;    // Empty if length is 0
   assign full = (length == 2 ** ADDR_WIDTH) ? 1'b1 : 1'b0;    // Full if length is the maximum capacity

   // Assign the write and read pointers to the corresponding output ports
   assign w_addr = wr_ptr;
   assign r_addr = rd_ptr;   
endmodule
