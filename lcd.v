`timescale 1 ns/100 ps
module lcdcontroller(
    input clock,
    input reset,
    input [8:0] rom_data,
    input [15:0] SW,
    input start,
    output rs,
    output e,
    output [7:4] d,
    output [15:0] LED,
    output reg [4:0] rom_addr
);

    // assign clk50MHz = clock;
    reg clk50MHz = 1'b0;
    wire [32:0] max_cyc;
    assign max_cyc = 32'd1 << SW[4:0];
    reg [32:0] clockCount = 0;
    always @(posedge clock) begin
        if (clockCount < max_cyc)
            clockCount <= clockCount + 1;
        else begin
            clockCount <= 0;
            clk50MHz <= ~clk50MHz;
        end
    end


    always @(posedge clk50MHz) begin  
        if (~reset) rom_addr <= 0;
        else if (ready) rom_addr <= rom_addr + 1;
    end



    wire ready;
    lcd lcd(
        .clock_50(clk50MHz),
        .reset(reset),
        .start_cmd(start | ready),
        .rom_data(rom_data),
        .ready(ready),
        .rs(rs),
        .e(e),
        .d(d),
        .LED(LED)
    );

endmodule

module lcd(
    input clock_50,
    input reset,
    input start_cmd,
    input [8:0] rom_data,
    output reg ready = 0,
    output reg rs = 0,
    output reg e = 0,
    output reg [7:4] d = 0,
    output [15:0] LED
);
    localparam SHORT_DELAY = 50;//2500;  // 50us
    localparam LONG_DELAY = 50;//110_000; //2.1ms
    reg [15:0] count = 0;

    assign LED = {clock_50, 1'b0, e, 1'b0, rs, 1'b0, d, 1'b0, count[4:0]};

    wire normal_delay;
    assign normal_delay = rom_data[8];

    always @(posedge clock_50) begin
        if (!reset | start_cmd) begin
            count <= 0;
            ready <= 0;
        end else if (count != (normal_delay ? SHORT_DELAY : LONG_DELAY)) begin
            count <= count + 1;
        end else begin
            ready <= 1;
        end

        if (rom_data != 0) begin
            // how to set bits
            if (count == 0)    rs <= rom_data[8];
            if (count == 5)    e <= 1'b1;
            if (count == 7)    d <= rom_data[7:4];
            // enable falling edge
            if (count == 20)   e <= 1'b0;
            if (count == 30)   e <= 1'b1;
            if (count == 32)   d <= rom_data[3:0];
            if (count == 45)   e <= 1'b0;
        end
    end
endmodule