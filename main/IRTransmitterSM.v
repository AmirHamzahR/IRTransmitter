`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2022 19:39:49
// Design Name: 
// Module Name: IRTransmitterSM
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


module IRTransmitterSM(
    //Standard signal
    input RESET,
    input CLK,
    //Bus interface signals
    input [3:0] COMMAND, //The assertion pulse
    input SEND_PACKET,
    //Extra signals
    output [24:0] CLK_COUNT,
    output [24:0] PULSE_COUNT,
    output [24:0] PULSE_MAXCOUNT,
    output [24:0] PULSEFREQ,
    output CHANGESTATE,
    output CAR_PULSE,
    output[3:0] CURR_STATE,
    output [3:0] NEXT_STATE,
    output [3:0] COMMAND_BITS,
    output [3:0] COMMAND_COUNT,
    output [3:0] PACKET_UPDATE,
    output [5:0] BURSTSIZE,
    output GENERIC_PACKET,
    output [3:0] STATE_NUMBER,
    //IR LED signal
    output IR_LED
    );
    
    //Variables for pulse signal
    reg [24:0] clk_count;
    reg [24:0] pulse_count;
    reg [24:0] pulse_maxcount;
    reg [24:0] pulsefreq;
    reg changestate;
    reg car_pulse;
    
    //Variables to be fed in the pulse
    //integer pulsefreq;
    
    //Variables for state machine
    reg [3:0] curr_state;
    reg [3:0] next_state;
    reg [3:0] command_bits;
    reg generic_packet;
    reg [3:0] state_number;
    reg [5:0] BurstSize;
    
    //Parameters for the state machine for yellow
    parameter StartBurstSize        = 192;
    parameter CarSelectBurstSize    = 24;
    parameter GapSize               = 24;
    parameter AssertBurstSize       = 48;
    parameter DeAssertBurstSize     = 24;
    
    //Variables to generate IR_LED
    reg ir_led;
    
    //assign reg to I/O's
    assign CLK_COUNT = clk_count;
    assign PULSE_COUNT = pulse_count;
    assign PULSE_MAXCOUNT = pulse_maxcount;
    assign PULSEFREQ = pulsefreq;
    assign CHANGESTATE = changestate;
    assign CAR_PULSE = car_pulse;
    assign BURSTSIZE = BurstSize;
    
    //Variables to be fed in the pulse
    //integer pulsefreq;
    
    //Variables for state machine
    assign CURR_STATE = curr_state;
    assign NEXT_STATE = next_state;
    assign COMMAND_BITS = command_bits;
    assign GENERIC_PACKET = generic_packet;
    assign STATE_NUMBER = state_number;
    assign IR_LED = ir_led;
    
    /*
    Generate the pulse signal here from the main clock running at 50MHz to generate the right frequency for 
    the car in question e.g. 36KHz for BLUE coded cars
    */
    
    initial begin 
        //Initial pulse values
        pulse_maxcount  = 0; 
        clk_count       = 0;
        car_pulse       = 0;
        changestate     = 0;
        state_number    = 0;
        pulsefreq       = 0;
        
        //Starts with receiving the Ten Hz packet
        curr_state      = 4'd5;
        next_state      = 4'd5;
        pulse_count     = 0;
        generic_packet  = 0;
        
        //For BurstSize
        BurstSize = CarSelectBurstSize;
        
        //Initial command values
        command_bits         = 4'd0000;
    end
    
    //Generate the pulse for any colour coded cars
    always@(posedge CLK) begin
        if(curr_state == 5 || curr_state == 1) begin
            clk_count    <= 0;
        end
        else begin
            //One pulse
            if(clk_count == pulsefreq) begin
                car_pulse   <= ~car_pulse;
                clk_count   <= 0;
            end
            else begin
                //changestate <= 0; //not sure if it is suitable still
                clk_count   <= clk_count + 1;
            end      
        end
    end
    /* 
    Simple state machine to generate the states of the packet i.e. Start, Gaps, Right Assert or De-Assert, Left 
    Assert or De-Assert, Backward Assert or De-Assert, and Forward Assert or De-Assert 
    */
    
    //Assigning current state to next state
    always@(posedge CLK) begin
            curr_state      <= next_state;
    end
    
    //Ten Hz packet input
    always@(posedge CLK) begin
        if(SEND_PACKET == 1)
            generic_packet <= 1;
        else
            generic_packet <= 0;
    end
    
    //If a number of designated pulses are finished
    always@(posedge CLK) begin
        if(changestate)
            pulse_count <= 0;
        else begin
            if(curr_state != 5)
                pulse_count <= pulse_count + 1;
        end
    end
    always@(*)begin
        if(pulse_count == pulse_maxcount)
            changestate <= 1;
        else
            changestate <= 0;
    end
    
    //Command bits for assert and de-assert
    always@(posedge changestate) begin
        if(curr_state == 0) begin
            state_number <= 0;
            command_bits <= COMMAND;
        end
        else if(curr_state == 2) begin
            state_number <= state_number + 1;
            command_bits <= command_bits;
        end
        else if(curr_state == 3 || curr_state == 4) begin
            //shifts the bits
            state_number <= state_number + 1;
            command_bits <= command_bits >> 1;
        end
        else begin
            state_number <= state_number;
            command_bits <= command_bits;
        end
    end
    
    //Pulse frequency combinatorial logic
    always@(*)  begin
        case(BurstSize)
        //Yellow-coded car
            22      :   begin
                pulsefreq   <= 1250;
            end
        //Red-coded car
            24      :   begin
                pulsefreq   <= 1389;
            end        
        //Green-coded car
            44      :   begin
                pulsefreq   <= 1333;
            end
        //Blue-coded car
            47      :   begin
                pulsefreq   <= 1389;
            end
            default : begin
                pulsefreq   <= 0;
            end
        endcase
    end     
    
    //Combinatorial logic for the pulses of the packet
    always@(*) begin
        case(curr_state)
            //Start     : 0
            4'd0    : begin
                pulse_maxcount <= pulsefreq * StartBurstSize * 2;
            end
            //Gap       : 1
            4'd1    : begin
                pulse_maxcount <= pulsefreq * GapSize * 2;
            end
            //Select    : 2
            4'd2    : begin
                pulse_maxcount <= pulsefreq * CarSelectBurstSize * 2;
            end
            //Assert    : 3
            4'd3    : begin
                pulse_maxcount <= pulsefreq * AssertBurstSize * 2;
            end
            //De-assert : 4
            4'd4    : begin
                pulse_maxcount <= pulsefreq * DeAssertBurstSize * 2;
            end
            //TenHz     : 5
            4'd5    : begin
                pulse_maxcount <= 0;
            end
            default : begin
                pulse_maxcount <= 0;
            end
        endcase
    end
    
    //Combinatorial logic for generic packet
    always@(curr_state or changestate or generic_packet or state_number or command_bits) begin
        case(curr_state)
            //Start
            4'd0    : begin
                if(changestate) begin
                    next_state <= 4'd1;
                end
                else
                    next_state <= curr_state;
            end
            //Gap
            4'd1    : begin
                if(changestate) begin
                    //Adressed to Car select
                    if(state_number == 0)
                        next_state <= 4'd2;
                    else if (state_number < 5) begin
                        //Adressed to Assert
                        if((command_bits & 4'b0001) == 4'b0001)
                            next_state <= 4'd3;
                        //Addressed to De-Assert
                        else begin
                            next_state <= 4'd4;
                        end
                    end
                    //Addressed to TenHz
                    else
                        next_state <= 4'd5;
                end
                else
                    next_state <= curr_state;
            end
            //Car Select
            4'd2    : begin
                if(changestate)
                    next_state <= 4'd1;
                else
                    next_state <= curr_state;
            end
            //Assert
            4'd3    : begin
                if(changestate)
                    next_state <= 4'd1;
                else
                    next_state <= curr_state;
            end
            //De-Assert
            4'd4    : begin
                if(changestate)
                    next_state <= 4'd1;
                else
                    next_state <= curr_state;
            end
            //TenHz
            4'd5    : begin
                if(generic_packet)
                    next_state <= 4'd0;
                else
                    next_state <= curr_state;
            end
            default: begin
                next_state <= curr_state;
            end
        endcase
    end
    
    // Finally, tie the pulse generator with the packet state to generate IR_LED
    
    always@(*) begin
        //IR_LED is 0 during Gap and TenHz counter is executed
        if(curr_state == 1 || curr_state == 5)
            ir_led <= 0;
        else
            ir_led <= car_pulse;
    end
   
   
   
   ila_0 your_instance_name (
        .clk(CLK), // input wire clk
    
    
        .probe0(ir_led), // input wire [0:0]  probe0  
        .probe1(curr_state) // input wire [3:0]  probe1
    );
endmodule
