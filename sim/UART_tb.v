`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2024 12:14:02 AM
// Design Name: 
// Module Name: UART_tb
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


module UART_tb(
    );
    // Parameters
    parameter FRAME_WIDTH = 8;
    parameter SB_TICK     = 16;
    parameter CLK_DELAY   = 5;
    
    // Testbench signals
    reg                    clk;
    reg                    reset_n;
    wire                   serial_data;
    
    // Rx signals
    reg                    rd_uart;
    wire [FRAME_WIDTH-1:0] r_data;
    wire                   rx_empty;
    wire                   data_vaild;

    // Tx signals
    reg                   wr_uart;
    reg [FRAME_WIDTH-1:0] w_data;
    wire                  tx_full;
    
    // Baud rate generator
    reg [10:0]            TIMER_FINAL_VALUE;
    
    
    // Instantiate the UART module
    UART #(FRAME_WIDTH, SB_TICK) uut (
        .clk(clk),
        .reset_n(reset_n),
        .rx(serial_data),
        .rd_uart(rd_uart),
        .r_data(r_data),
        .rx_empty(rx_empty),
        .data_vaild(data_vaild),
        .tx(serial_data),
        .wr_uart(wr_uart),
        .w_data(w_data),
        .tx_full(tx_full),
        .TIMER_FINAL_VALUE(TIMER_FINAL_VALUE)
    );
    
    // Clock generation
    always begin
        #CLK_DELAY clk = ~clk; // 200 MHz clock
    end
    
    /*
    task send_bit;
        input bit;
    begin
        @(negedge clk)
        serial_data = bit;
        #104170;
    end
    endtask
    */
    
    task send_frame;
        input [FRAME_WIDTH-1:0] data;
    begin
        @(posedge clk)
        wr_uart = 1;
        w_data = data;
        @(posedge clk)
        wr_uart = 0;
        @(negedge rx_empty);
    end
    endtask
    
    task receive_frame;
    begin
        @(posedge clk)
        rd_uart = 1;
        @(posedge clk)
        rd_uart = 0;
    end
    endtask
        
    // Initialize inputs and stimulus
    initial 
    begin
        // Initialize signals
        clk = 0;
        TIMER_FINAL_VALUE = 650;
        reset_n = 0;
        wr_uart = 0;
        rd_uart = 0;
        
        // Apply reset
        #CLK_DELAY
        reset_n = 1;
        
        // Write data to FIFO
        send_frame(8'hAA);         // parity bit = 1
        receive_frame;
        
        send_frame(8'h4C);         // parity bit = 0
        receive_frame;
        
        send_frame(8'hB9);         // parity bit = 1
        receive_frame;

        send_frame(8'hF0);         // parity bit = 0
        receive_frame;
        
        send_frame(8'h6D);         // parity bit = 1
        receive_frame;
        
        send_frame(8'hE8);         // parity bit = 0
        receive_frame;
        
        //receive_frame;
        // Check received data
        if (r_data !== 8'h6D) begin
            $display("Error: Received data is incorrect! %b", r_data);
        end else begin
            $display("Received data is correct");
        end
        
        // Check if FIFO is empty
        if (rx_empty) begin
            $display("FIFO is empty");
        end else begin
            $display("FIFO is not empty");
        end
        
        /*
        send_bit(1'b1); // Idle            
        send_bit(1'b1);
        send_bit(1'b1);
                     
        send_bit(1'b0); // Start bit
                     
        send_bit(1'b0);             
        send_bit(1'b1);             
        send_bit(1'b0);             
        send_bit(1'b1);
                     
        send_bit(1'b0);             
        send_bit(1'b1);             
        send_bit(1'b0);             
        send_bit(1'b1);
        
        send_bit(1'b1); //Parity bit
        
        send_bit(1'b1); // Idle
        
        receive_frame;
        receive_frame;
        */
     end
     
endmodule
