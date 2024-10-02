`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2024 03:14:37 PM
// Design Name: 
// Module Name: UART_TX
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


module UART_TX #(parameter FRAME_WIDTH = 8, SB_TICK = 16)(
    input                          clk, 
    input                          reset_n,
    input                          s_tick,          //enable to transmit at same freq "baud rate" 
    input      [FRAME_WIDTH - 1:0] tx_din,          //parallel transmitted data
    input                          tx_start,        //enable to start transmition
    output reg                     tx_ready,
    output                         tx,              //serial transmitted data
    output reg                     tx_done_tick     //tx is done 
    );
    
    localparam IDLE  = 0,
               START = 1,
               DATA  = 2, 
               STOP  = 3;

    reg [1:0]                   state_reg, state_next;
    reg [3:0]                   s_reg, s_next; //s: number of ticks
    reg [$clog2(FRAME_WIDTH):0] n_reg, n_next; //n: number of data bits
    reg [FRAME_WIDTH - 1:0]     b_reg, b_next; //b: received data bits
    reg                         tx_reg, tx_next; //tx: transmitted bit
    reg                         parity_bit;

    always @(negedge clk or negedge reset_n)
    begin
        if(~reset_n)
        begin
            state_reg  <= IDLE;
            s_reg      <= 0;
            n_reg      <= 0;
            b_reg      <= 0;
            tx_reg     <= 1'bz;
            parity_bit <= 1'b0;
            tx_done_tick = 1'b1; 
        end
        else
        begin
            state_reg  <= state_next;
            s_reg      <= s_next;
            n_reg      <= n_next;
            b_reg      <= b_next;
            tx_reg     <= tx_next;
        end
    end
    
    always @(*)
    begin
        state_next   = state_reg;
        s_next       = s_reg;
        n_next       = n_reg;
        b_next       = b_reg;
        tx_done_tick = 1'b0;
        tx_ready     = 1'b0;
        
        case(state_reg)
            IDLE:
            begin
                tx_ready = 1'b1;
                tx_next = 1'b1;
                if(tx_start)
                begin
                    s_next = 0;
                    b_next = tx_din;
                    parity_bit = 1'b0;
                    state_next = START;
                end
            end
            
            START:
            begin
                tx_next = 1'b0;
                if(s_tick)
                begin
                    if(s_reg == 15)
                    begin
                        s_next = 0;
                        n_next = 0;
                        state_next = DATA;
                    end 
                    else
                        s_next = s_reg + 1;
                end
            end
            
            DATA:
            begin
                if(n_reg == FRAME_WIDTH)
                    tx_next = parity_bit;
                else
                    tx_next = b_reg[0];
                    
                if(s_tick)
                begin
                    if(s_reg == 15)
                    begin
                        s_next = 0;
                        parity_bit = parity_bit + tx_next;
                        b_next = b_reg >> 1;
                        
                        if(n_reg == FRAME_WIDTH)
                        begin
                            state_next = STOP;
                            n_next = 0;
                        end
                        else
                            n_next = n_reg + 1;
                    end
                    else
                        s_next = s_reg + 1;
                end
            end
            
            STOP:
            begin
                tx_next = 1'b1;
                if(s_tick)
                begin
                    if(s_reg == (SB_TICK - 1))
                    begin
                        tx_done_tick = 1'b1;
                        state_next = IDLE;
                    end
                    else
                        s_next = s_reg + 1;
                end
            end
            
            default: state_next = IDLE;
        endcase
    end
     
    assign tx = tx_reg; 
      
endmodule
