module sm_tb;
parameter CNTR_WDTH = 5;

//declaring inputs as reg and outputs as wire
reg clk; //input clock
reg rst; //reset
reg act; //counter activate
reg up_dwn; //up counting or down counting signal
wire ovrflw; //overflow indicator
wire [CNTR_WDTH-1:0] count; //counter output

//instantiate the state machine
sm #(CNTR_WDTH)
   DUT (.clk(clk), .rst(rst), .act(act), .up_dwn(up_dwn), //Design Under Test
        .ovrflw(ovrflw), .count(count));

initial begin
    clk = 1'b1;
    rst = 1'b0;
    act = 1'b0;
    up_dwn = 1'b1;

 //monitor changes
 $monitor("%t: rst=%b act=%b up_dwn=%b count=%d ovrflw=%b \n", $time,rst,act,up_dwn,count,ovrflw);

 #100 rst = 1'b1; //reset after 100 time steps delay
end

always //define clock
#5 clk = ~clk;

initial begin
 //@100 start  up counting until overflow
 #100 act = 1'b1;
      up_dwn = 1'b1;

 //reset (10 cycles pulse)
 #1000 rst = 1'b0;
       act = 1'b0;
  #100 rst = 1'b1;

 //count upto 4 and then count down until overflow
 #100 act = 1'b1;
      up_dwn = 1'b1;
 #40  up_dwn = 1'b0;
end

endmodule