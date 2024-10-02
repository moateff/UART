`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2024 03:15:06 PM
// Design Name: 
// Module Name: UART_RX
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


module UART_RX #(parameter FRAME_WIDTH = 8, SB_TICK = 16)(
    input                          clk, 
    input                          reset_n,
    input                          rx,                 //serial received data
    input                          s_tick,             //enable to receive at same freq "baud rate" 
    output     [FRAME_WIDTH - 1:0] rx_dout,            //parallel transmitted data
    output reg                     rx_done_tick,       //rx is done
    output reg                     data_vaild
    );
    
    localparam IDLE  = 0, 
               START = 1, 
               DATA  = 2, 
               STOP  = 3;
    
    reg [1:0]                   state_reg, state_next;
    reg [3:0]                   s_reg, s_next; //s: number of ticks
    reg [$clog2(FRAME_WIDTH):0] n_reg, n_next; //n: number of data bits
    reg [FRAME_WIDTH - 1:0]     b_reg, b_next; //b: received data bits
    reg                         parity_bit;
    reg                         w_parity;
    
    always @(negedge clk or negedge reset_n)
    begin
        if(~reset_n)
        begin
            state_reg    <= IDLE;
            s_reg        <= 0;
            n_reg        <= 0;
            b_reg        <= 0;
            parity_bit   <= 0;
        end
        else
        begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
        end
    end
    
    always @(*)
    begin
        state_next   = state_reg;
        s_next       = s_reg;
        n_next       = n_reg;
        b_next       = b_reg;
        rx_done_tick = 1'b0;
        data_vaild   = 1'b0;
        
        case(state_reg)
            IDLE:
            begin
                if(~rx)
                begin
                    s_next = 0;
                    parity_bit = 1'b0;
                    state_next = START;
                end
            end
            
            START:
            begin
                if(s_tick)
                begin
                    if(s_reg == 7)
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
                if(s_tick)
                begin
                    if(s_reg == 15)
                    begin
                        s_next = 0;
                        
                        if(n_reg == FRAME_WIDTH)
                        begin
                            w_parity = (rx == parity_bit);
                            state_next = STOP;
                        end
                        else
                        begin
                            b_next = b_reg >> 1;
                            b_next[FRAME_WIDTH - 1] = rx;
                            parity_bit = parity_bit + rx;
                        end
                        n_next = n_reg + 1;
                    end
                    else
                        s_next = s_reg + 1;
                end
            end
            
            STOP:
            begin
                n_next = 0;
                if(s_tick)
                begin
                    if(s_reg == (SB_TICK - 1))
                    begin
                        data_vaild = w_parity;
                        rx_done_tick = 1'b1;
                        state_next = IDLE;
                    end
                    else
                        s_next = s_reg + 1;
                end
            end
            default: state_next = IDLE;
        endcase
    end
    
    assign rx_dout = b_reg;
    
endmodule
