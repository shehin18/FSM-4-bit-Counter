module sm //module statemachine
#(parameter CNTR_WDTH = 4) //counter with width = 4
(clk, rst, act, up_dwn, count, ovrflw);

//declaring outputs and inputs
input clk; //input clock
input rst; //reset
input act; //counter activate
input up_dwn; //up counting or down counting signal
output ovrflw; //overflow indicator
output [CNTR_WDTH-1:0] count; //counter output

//declaring as reg for always blocks
reg [CNTR_WDTH-1:0] count; //counter
reg [3:0] state, nxt_state; //registers for defining states

//declaring states as local parameters
localparam IDLE =    4'b0001; //idle state
localparam CNT_UP =  4'b0010; //up counting state
localparam CNT_DWN = 4'b0100; //down counting state
localparam OVRFLW =  4'b1000; //overflow state

//always block for different states
always @(*)
    case (state)
    IDLE : begin //idle state
        if (act) //counter activate signal
            if (up_dwn) //up counting
            nxt_state = CNT_UP;
            else //down counting
            nxt_state = CNT_DWN;
        else //counter activate signal = 0
            nxt_state = IDLE;
    end
    
    CNT_UP : begin //up counting state
        if (act) //counter activate signal
            if (up_dwn) //up counting when up_dwn = 1
                if (count == (1<<CNTR_WDTH) - 1) //1 is shifted leftwards by conter width(eg: here 1'b1 changes to 5'b10000)
                                                 //and this digit is substracted by 1(count = 5'b10000 - 1'b1 = 4'b1111)
                nxt_state = OVRFLW; //after max count next state will be overflow
                else
                nxt_state = CNT_UP; //go to up count
            else //down counting when up_dwn = 0
                if (count == 4'b0000) //count = 0
                nxt_state = OVRFLW; //after min count next state will be overflow
                else
                nxt_state = CNT_DWN; //go to down count
        else //counter activate signal = 0
            nxt_state = IDLE; //go to idle stage
    end

    CNT_DWN : begin //up counting state
        if (act) //counter activate signal
            if (!up_dwn) //down counting when up_dwn = 0
                if (count == 'b0) //count = 0 
                nxt_state = OVRFLW; //after min count next state will be overflow
                else
                nxt_state = CNT_DWN; //go to down count
            else //up counting when up_dwn = 1
                if (count == (1<<CNTR_WDTH) - 1) //1 is shifted leftwards by conter width(eg: here 1'b1 changes to 5'b10000)
                                                 //and this digit is substracted by 1(count = 5'b10000 - 1'b1 = 4'b1111)
                nxt_state = OVRFLW; //after max count next state will be overflow
                else
                nxt_state = CNT_UP; //go to up count
        else //counter activate signal = 0
            nxt_state = IDLE; //go to idle stage
    end

    OVRFLW : begin //overflow state
        nxt_state = OVRFLW; //next state will be overflow
    end

    default : begin //default case
    nxt_state = 'bx; //dont care condition
    $display("%t : State machine not initialized\n",$time); //error message
    end

endcase

always @(posedge clk or negedge rst) begin //async reset always block
    if (!rst) //active low reset
    state <= IDLE;
    else
    state <= nxt_state;
end

always @(posedge clk or negedge rst) begin //async reset always block
    if (!rst)
    count <= 'b0; //count reset
    else
        if (state == CNT_UP) //if up counting state
        count <= count + 1'b1; //increment counter
        else if (state == CNT_DWN) //if down counting state
        count <= count - 1'b1; //decrement counter
end

assign ovrflw = (state == OVRFLW) ? 1'b1 : 1'b0; //ovrflw = 1 if current state is overflow

endmodule