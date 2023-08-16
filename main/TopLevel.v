`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2022 11:00:15
// Design Name: 
// Module Name: TopLevel
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


module TopLevel(
    input CLK,
    input RESET,
    output IR_LED
    );
    
    wire [7:0] RomData;
    wire [7:0] RomAddress;
    wire [1:0] BusInterruptsRaise;
    wire [1:0] BusInterruptsAck;
    wire BusWE;
    wire [7:0] BusData;
    wire [7:0] BusAddr;
    
   Processor processor(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE),
        .ROM_ADDRESS(RomAddress),
        .ROM_DATA(RomData),
        .BUS_INTERRUPTS_RAISE(BusInterruptsRaise),
        .BUS_INTERRUPTS_ACK(BusInterruptsAck)
    ); 
    
    ROM rom(
        .CLK(CLK),
        .ADDR(RomAddress),
        .DATA(RomData)
    ); 
    
    RAM ram(
        .CLK(CLK),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE)
    );
    
    Timer timer(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE),
        .BUS_INTERRUPT_RAISE(BusInterruptsRaise[1]),
        .BUS_INTERRUPT_ACK(BusInterruptsAck[1])
    );
    
    IRTransmitter ir_transmitter(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_ADDR(BusAddr),
        .BUS_DATA(BusData),
        .IR_LED(IR_LED)
    );  
    
endmodule
