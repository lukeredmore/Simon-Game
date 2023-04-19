module AudioController(
    input        clk, 		// System Clock Input 50 Mhz
    input[3:0]   tone,	// Tone control switches
    output       audioOut);	// Audio Enable

	localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 50*MHz; // System clock frequency


	// Initialize the frequency array. FREQs[0] = 261
	reg[10:0] FREQs[0:15];
	initial begin
		$readmemh("FREQs.mem", FREQs);
	end
	
	////////////////////
	// Your Code Here //
	////////////////////
	wire [17:0] counter_limit;
	assign counter_limit = (SYSTEM_FREQ/(2*FREQs[tone])) - 1;
	
	reg clk1MHz = 1'b0;
	reg[17:0] counter = 17'd0;
	always @(posedge clk) begin
	   if (counter < counter_limit)
	       counter <= counter + 1;
	   else begin
	       counter <= 0;
	       clk1MHz <= ~clk1MHz;
	   end
	end
	
	wire [6:0] duty_cycle;
	assign duty_cycle = clk1MHz ? 7'd100 : 7'd0;
    PWMSerializer serializer1(
        .clk(clk),
        .reset(1'b0),
        .duty_cycle(duty_cycle),
        .signal(audioOut)
    );
    
endmodule