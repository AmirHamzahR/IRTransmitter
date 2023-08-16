`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2022 15:49:51
// Design Name: 
// Module Name: IRTransmitter
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


module IRTransmitter(
    input [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input RESET,
    input CLK,
    output IR_LED 
    );
    //TenHz packet
    wire SEND_PACKET;
    reg [3:0] COMMAND = 4'b0000;
     
    TenHz_cnt TenHz_count(
        .CLK(CLK),
        .SEND_PACKET(SEND_PACKET),
        .RESET(RESET)
    );
    
    IRTransmitterSM IR_SM(
        .CLK(CLK),
        .RESET(RESET),
        .COMMAND(COMMAND),
        .SEND_PACKET(SEND_PACKET),
        .IR_LED(IR_LED)
    );

    //Sequential logic for updating command
    always@(posedge CLK)begin
        if (RESET)
            COMMAND <= 4'b0000;
        else if (BUS_ADDR == 8'h90)
            COMMAND <= BUS_DATA[3:0];
    end
endmodule
