`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2022 13:47:16
// Design Name: 
// Module Name: TenHz_cnt
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


module TenHz_cnt(
    input CLK,
    input RESET,
    output [24:0] COUNT,
    output SEND_PACKET
    );
    
    reg [24:0] count;
    reg generic_packet;
    parameter MAX_COUNT = 10000000;
    
    initial begin
        count = 0;
        generic_packet <= 0;
    end
    
    always@(posedge CLK) begin
        if(count == MAX_COUNT) begin
            count          <= 0;
            generic_packet <= 1;
        end    
        else begin
            count          <= count + 1;
            generic_packet <= 0;
        end
    end
    assign COUNT = count;
    assign SEND_PACKET = generic_packet;
endmodule
