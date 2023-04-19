module IO_Test(
    input clock,
    input [3:0] JD,
    input [3:0] BTN,
    output [7:4] JC,
    output [15:0] LED
);

assign LED[3:0] = JD[3:0];
assign LED[7:4] = BTN[3:0];
assign JC[7:4] = LED[3:0];

// wire LED_SIGNAL = JD[0]



endmodule