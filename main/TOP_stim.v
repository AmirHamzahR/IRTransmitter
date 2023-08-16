`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2022 12:03:19
// Design Name: 
// Module Name: TOP_stim
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


module TOP_stim(
);

    reg CLK;
    reg RESET;
    reg [3:0] SWITCHES;
    wire [7:0] RomData;
    wire [7:0] RomAddress;
    wire [1:0] BusInterruptsRaise;
    wire [1:0] BusInterruptsAck;
    wire BusWE;
    wire [7:0] BusData;
    wire [7:0] BusAddr;
    
    RAM uut1 (
        .CLK(CLK),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE)
    );
        
    ROM uut2 (
        .CLK(CLK),
        .DATA(RomData),
        .ADDR(RomAddress)
    );
    
    Processor uut3 (
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
    

    Timer timer(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .SWITCHES(SWITCHES),
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
    
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
        SWITCHES = 4'b0000;
        RESET = 1'b0;
        #10 RESET = 1'b1;
        #20000000 RESET = 1'b0;
        #90000000 SWITCHES = 4'b0010;
    end
endmodule
