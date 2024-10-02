`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2024 02:16:07 PM
// Design Name: 
// Module Name: UART
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


module UART #(
    parameter FRAME_WIDTH = 8,     //data bits,
              SB_TICK     = 16     //stop bit ticks
)(
    input                      clk, 
    input                      reset_n,
    
    //Rx
    input                      rx,               //serial received data
    input                      rd_uart,          //enable to read from FIFO
    output [FRAME_WIDTH - 1:0] r_data,           //paralell received data 
    output                     rx_empty,         //FIFO is empty
    output                     data_vaild,
    
    //TX
    input                     tx,               //serial transmitted data
    input                     wr_uart,          //enable to write to FIFO
    input [FRAME_WIDTH - 1:0] w_data,           //paralell transmitted data
    output                    tx_full,          //FIFO is full
    
    //Baud Rate Genrator
    input [10:0]              TIMER_FINAL_VALUE
    );
    
    
    //Baud Rate Genrator
    wire baud_clk;
    Timer #(.BITS(11)) baud_rate_genrator(
        .clk(clk),
        .reset_n(reset_n),
        .FINAL_VALUE(TIMER_FINAL_VALUE),
        .done(baud_clk)
    );
    
    
    //RX
    wire                     rx_done_tick;            //enable to write to FIFO
    wire [FRAME_WIDTH - 1:0] rx_dout;                 //data to be witten in FIFO
    
    UART_RX #(.FRAME_WIDTH(FRAME_WIDTH), .SB_TICK(SB_TICK)) receiver(
        .clk(clk), 
        .reset_n(reset_n),
        .rx(rx),                        //serial received data
        .s_tick(baud_clk),              //enable to receive at same freq "baud rate" 
        .rx_dout(rx_dout),              //parallel transmitted data
        .rx_done_tick(rx_done_tick),    //rx is done
        .data_vaild(data_vaild)
    );
    
    // Instantiate the FIFO module
    Standard_FIFO #(
        .ADDR_WIDTH($clog2(FRAME_WIDTH)),  // Set address width
        .DATA_WIDTH(FRAME_WIDTH)           // Set data width
    ) rx_FIFO (
        .clk(clk),                      // Connect the clock signal
        .reset(~reset_n),               // Connect the reset signal
        .rd(rd_uart),                   // Connect the read enable signal
        .wr(rx_done_tick),              // Connect the write enable signal
        .w_data(rx_dout),               // Connect the write data input
        .r_data(r_data),                // Connect the read data output
        .empty(rx_empty),               // Connect the empty flag output
        .full()                         // Connect the full flag output
    );
    
    //TX
    wire                     tx_done_tick;
    wire                     tx_fifo_empty; //enable to read from FIFO
    wire [FRAME_WIDTH - 1:0] tx_din;         //data to be transmitted
    wire                     tx_ready;
    
    UART_TX #(.FRAME_WIDTH(FRAME_WIDTH), .SB_TICK(SB_TICK)) transmitter(
        .clk(clk), 
        .reset_n(reset_n),
        .s_tick(baud_clk),            //enable to transmit at same freq "baud rate" 
        .tx_din(tx_din),              //data to be transmitted
        .tx_start(~tx_fifo_empty),   //enable to start transmition
        .tx(tx),                      //serial transmitted data
        .tx_done_tick(tx_done_tick),  //tx is done 
        .tx_ready(tx_ready)
    );
    
    // Instantiate the FIFO module
    Standard_FIFO #(
        .ADDR_WIDTH($clog2(FRAME_WIDTH)),  // Set address width
        .DATA_WIDTH(FRAME_WIDTH)           // Set data width
    ) tx_FIFO (
        .clk(clk),                     // Connect the clock signal
        .reset(~reset_n),              // Connect the reset signal
        .rd(tx_ready),             // Connect the read enable signal
        .wr(wr_uart),                  // Connect the write enable signal
        .w_data(w_data),               // Connect the write data input
        .r_data(tx_din),               // Connect the read data output
        .empty(tx_fifo_empty),         // Connect the empty flag output
        .full(tx_full)                 // Connect the full flag output
    );
    
endmodule
