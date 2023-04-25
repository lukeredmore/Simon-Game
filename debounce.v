module debouncetest(
    input clock, 
	input reset,
	input [3:0] BTN,
	input [15:0] SW,
	input [3:0] JD,
	output [15:0] LED,
	output rs,
	output e,
    output [7:4] d,
	output audioOut,
	output reg audioEn = 0,
	output reg [7:4] JC = 0
);

    reg [4:0] btn_rise_count = 0;
    reg [4:0] btn_rise_count_DB = 0;
    reg [4:0] btn_rise_count_DB2 = 0;
    assign LED[14:0] = {btn_rise_count, btn_rise_count_DB, btn_rise_count_DB2};

    reg btn_0_hi = 0;
    reg btn_0_hi_DB = 0;
    reg btn_0_hi_DB2 = 0;
    always @(posedge clock) begin
        if (btn_0_hi != BTN[0]) begin// button changed
            btn_rise_count <= btn_rise_count + 1;
            btn_0_hi <= BTN[0];
        end

        if (btn_0_hi_DB != BTN_0_DB) begin// button_db changed
            btn_rise_count_DB <= btn_rise_count_DB + 1;
            btn_0_hi_DB <= BTN_0_DB;
        end
        
        if (btn_0_hi_DB2 != BTN_0_DB2) begin// button_db changed
            btn_rise_count_DB2 <= btn_rise_count_DB2 + 1;
            btn_0_hi_DB2 <= BTN_0_DB2;
        end
    end

    wire BTN_0_DB, BTN_0_DB2;
    debounce Debouncer(.pb_1(BTN[0]), .clk(clock), .pb_out(BTN_0_DB));
    simpleDebounce SimpleDebouncer(
        .in(BTN[0]),
        .clock(clock),
        .out(BTN_0_DB2)
    );
endmodule

module simpleDebounce(
    input in, 
    input clock, 
    output reg out);

    reg [31:0] cycles_since_change = 0;
    always @(posedge clock) begin
        if (in != out & cycles_since_change > 1_000_000) begin
            out <= in;
            cycles_since_change <= 0;
        end else cycles_since_change <= cycles_since_change + 1;
    end
endmodule

//fpga4student.com: FPGA projects, Verilog projects, VHDL projects
// Verilog code for button debouncing on FPGA
// debouncing module without creating another clock domain
// by using clock enable signal 
module debounce(input pb_1,clk,output pb_out);
wire slow_clk_en;
wire Q1,Q2,Q2_bar,Q0;
clock_enable u1(clk,slow_clk_en);
my_dff_en d0(clk,slow_clk_en,pb_1,Q0);

my_dff_en d1(clk,slow_clk_en,Q0,Q1);
my_dff_en d2(clk,slow_clk_en,Q1,Q2);
assign Q2_bar = ~Q2;
assign pb_out = Q1 & Q2_bar;
endmodule
// Slow clock enable for debouncing button 
module clock_enable(input Clk_100M,output slow_clk_en);
    reg [26:0]counter=0;
    always @(posedge Clk_100M)
    begin
       counter <= (counter>=249999)?0:counter+1;
    end
    assign slow_clk_en = (counter == 249999)?1'b1:1'b0;
endmodule
// D-flip-flop with clock enable signal for debouncing module 
module my_dff_en(input DFF_CLOCK, clock_enable,D, output reg Q=0);
    always @ (posedge DFF_CLOCK) begin
  if(clock_enable==1) 
           Q <= D;
    end
endmodule