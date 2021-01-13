//Umair Liaqat
//11/1/2019
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	//Decalring variables
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	logic [10:0] count;
	logic reset,draw,color;

	input CLOCK_50;
		output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	logic [31:0] clk;
	parameter whichClock = 15;
   clock_divider cdiv (CLOCK_50, clk);
	
	logic [10:0] x0, y0, x1, y1, x, y;
	
	//A counter to count upto 1700s which acts as a timer for the animation.
	counter #(.BITS(11), .MAX(1000)) switch (.clk(clk[whichClock]), .reset(~KEY[0]), .incr(1'b1), .out(count), .done());
	
	VGA_framebuffer fb(.clk50(CLOCK_50), .reset(1'b0), .x, .y,
				.pixel_color(color), .pixel_write(1'b1),
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));
		
		//The line drawer module.
		line_drawer lines (.clk(CLOCK_50), .reset(~KEY[0] | reset),
				.x0, .y0, .x1, .y1, .x, .y, .color, .draw);
	
	//This block animates a line on the screen after every 100 seconds. It toggles the reset on and off 
	//by clearing the screen and then drawing the lines again.
	always_comb begin
		if(count < 100) begin
			x0 = 320;
			y0 = 240;
			x1 = 320;
			y1 = 290;
			reset = 1'b0;
		end else if (count < 200) begin
			x0 = 320;
			y0 = 240;
			x1 = 320;
			y1 = 290;
			reset = 1'b1;
		end else if (count < 300) begin
			x0 = 320;
			y0 = 240;
			x1 = 350;
			y1 = 270;
			reset = 1'b0;
		end else if (count < 400) begin
			x0 = 320;
			y0 = 240;
			x1 = 350;
			y1 = 270;
			reset = 1'b1;
		
		end else if (count < 500) begin
			x0 = 320;
			y0 = 240;
			x1 = 370;
			y1 = 240;
			reset = 1'b0;
		end else if (count < 600) begin
			x0 = 320;
			y0 = 240;
			x1 = 370;
			y1 = 240;
			reset = 1'b1;
		end else if (count < 700) begin
			x0 = 320;
			y0 = 240;
			x1 = 350;
			y1 = 210;
			reset = 1'b0;
		end else if (count < 800) begin
			x0 = 320;
			y0 = 240;
			x1 = 350;
			y1 = 210;
			reset = 1'b1;
		end else if (count < 900) begin
			x0 = 320;
			y0 = 240;
			x1 = 320;
			y1 = 190;
			reset = 1'b0;
		end else if (count < 1000) begin
			x0 = 320;
			y0 = 240;
			x1 = 320;
			y1 = 190;
			reset = 1'b1;
		end
		
	end
	
endmodule

//clock divider module
module clock_divider (clock, divided_clocks);
	input logic clock;
	output logic [31:0] divided_clocks = 0;

	always_ff @(posedge clock) begin
	divided_clocks <= divided_clocks + 1;
	end

endmodule 

//Simulating the module in modelsim
`timescale 1 ps / 1 ps
module DE1_SoC_testbench();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	

	logic CLOCK_50;
	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .CLOCK_50, 
	.VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		KEY[0] = 1; @(posedge CLOCK_50);
		KEY[0] = 0; @(posedge CLOCK_50);
		KEY[0] = 1; KEY[1] = 0; @(posedge CLOCK_50);
		KEY[0] = 1; KEY[1] = 1; @(posedge CLOCK_50); 
		for (int i = 0; i < 1000; i++) begin
			@(posedge CLOCK_50);
		end	
		$stop; // End the simulation.
	end
endmodule