module counter_6(count, clr, clk);
	input clk, clr; 
	output [5:0] count; 
 
    //Examine value of lesser bits to know when to update
    wire [5:0] d; 
    assign d[0] = count[0] ^ 1'b1; //toggle every latch
    assign d[1] = count[0] ^ count[1]; //toggle every 2nd latch
    assign d[2] = (count[0] & count[1]) ^ count[2]; //toggle every 4th latch 
    assign d[3] = (count[0] & count[1] & count[2]) ^ count[3]; //toggle every 8th latch 
    assign d[4] = (count[0] & count[1] & count[2] & count[3]) ^ count[4]; //toggle every 16th latch 
    assign d[5] = (count[0] & count[1] & count[2] & count[3] & count[4]) ^ count[5]; //toggle every 32nd latch 

    dffe_ref dff1(.clk(clk), .clr(clr), .d(d[0]), .q(count[0]), .en(1'b1)); 
	dffe_ref dff2(.clk(clk), .clr(clr), .d(d[1]), .q(count[1]), .en(1'b1)); 
	dffe_ref dff3(.clk(clk), .clr(clr), .d(d[2]), .q(count[2]), .en(1'b1)); 
	dffe_ref dff4(.clk(clk), .clr(clr), .d(d[3]), .q(count[3]), .en(1'b1)); 
    dffe_ref dff5(.clk(clk), .clr(clr), .d(d[4]), .q(count[4]), .en(1'b1));
    dffe_ref dff6(.clk(clk), .clr(clr), .d(d[5]), .q(count[5]), .en(1'b1)); 
endmodule