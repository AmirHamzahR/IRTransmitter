`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2022 21:47:39
// Design Name: 
// Module Name: ROM
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


module ROM(
    //standard signals
    input CLK,
    //BUS signals
    output reg [7:0] DATA,
    input      [7:0] ADDR
     );
    
    parameter RAMAddrWidth = 8;
    
    //Memory
    reg [7:0] ROM [2**RAMAddrWidth-1:0];
    
    // Load program
    initial $readmemh("F:/Amir_Hamzah/University_of_Edinburgh/Studies/4th_year_2ndSem/DigitalSystemsLaboratory/Assign2/Complete_Demo_ROM.txt", ROM);
    
    //single port ram
    always@(posedge CLK)
        DATA <= ROM[ADDR];
        
endmodule
