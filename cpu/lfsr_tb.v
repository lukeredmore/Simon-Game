`timescale 1ns/100ps

module lfsr_tb();
    reg clock = 0;
    wire [6:0] rand_out;
    wire [3:0] rand_encoding;

    lfsr DUT(
        .clk(clock),
        .rand_4_bit_encoding(rand_encoding),
        .rand_out(rand_out));

    reg [9:0] i = 0;
    //initial begin
      //  i = 0;
        //clock = 0;
        //rst_n = 0;
        //#1000
        //rst_n = 1;
    //end
    always
        #10 clock = ~clock; 

    always @(posedge clock) begin
        $display("%d (%b)", rand_out[1:0], rand_encoding);
        i <= i + 1;
        if (i > 1000)
            $finish;
    end

endmodule

//iverilog lfsr_tb.v lfsr.v && vvp a.out && rm a.out