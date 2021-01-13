//Umair Liaqat
//11/1/2019
module line_drawer(
	input logic clk, reset,
	input logic [10:0]	x0, y0, x1, y1, //the end points of the line
	output logic [10:0]	x, y, //outputs corresponding to the pair (x, y)
	output logic color,draw
	);
	
   //Declaring local registers for calculations and for holding the coordinates.
	logic signed [11:0] error,error_temp;
	logic [11:0] deltay;
	logic [11:0] deltax;
	logic [10:0] x0_startPoint;
	logic [10:0] y0_startPoint;
	logic [10:0] x1_endPoint;
	logic [10:0] y1_endPoint;
	logic [10:0] x_corr,y_corr;
	logic [1:0] y_step;
   logic [10:0]counterx,countery;
	logic clearScreen,screenCleared,start;
	logic [10:0] Deltay;
	//counters used for clearing the screen after we have drew a line 
	counter y_counter (.clk, .reset(clearScreen), .incr(1'b1), .out(countery), .done(start));
	counter #(.MAX(640)) x_counter (.clk, .reset(clearScreen), .incr(start), .out(counterx), .done());
	
	//Modules used for calculating the absolue value, which outputs delta y and delta x.
	abs_value absy (.value(y1-y0),.out(deltay));
	abs_value absx (.value(x1-x0),.out(deltax));
	abs_value postswap (.value(y1_endPoint-y0_startPoint),.out(Deltay));
	
	//Using the delta values to check if the slope of the line is greater than 1.
	assign isSteep = deltay > deltax;
	assign DeltaX = x1_endPoint - x0_startPoint;
	
	
	//Implemeting Bershenham's line drawing algorithm using a always_ff block
	always_ff @(posedge clk)
		if (reset) begin
			clearScreen <= 0;
			x <= counterx;
			y <= countery;
			color <= 1'b0;
			screenCleared <= 1;
		end else begin
			if(screenCleared || (x_corr == x1_endPoint)) begin
				x_corr <= x0_startPoint;
				y_corr <= y0_startPoint;
				error_temp <= 0;
				error <= -(DeltaX / 2);
				screenCleared <= 0;
				color <= 1'b1;
				clearScreen <= 1'b1;
				draw <= 1'b0;
			end else begin
				draw <= 1'b1;
				if (isSteep) begin
					x <= y_corr;
					y <= x_corr;
				end else begin
					x <= x_corr;
					y <= y_corr;
				end
				x_corr <= x_corr + 1;
				if(error >= 0) begin
					if(y_step < 0)
						y_corr <= y_corr - 1;
					else
						y_corr <= y_corr + 1;
					error_temp <= -DeltaX;
					end else
					error_temp <= 0;
				error <= Deltay + error_temp + error;
			 end
		end
		

		
   //Intial values for drawing the lines.
	always_comb begin
		if (isSteep) begin
			if(y0 > y1) begin
				x0_startPoint = y1;
				x1_endPoint = y0;
				y0_startPoint = x1;
				y1_endPoint = x0;
			end else begin
				x0_startPoint = y0;
				x1_endPoint = y1;
				y0_startPoint = x0;
				y1_endPoint = x1;
			end
		end else begin
			if(x0 > x1) begin
				x0_startPoint = x1;
				x1_endPoint = x0;
				y0_startPoint = y1;
				y1_endPoint = y0;
			end else begin
				x0_startPoint = x0;
				x1_endPoint = x1;
				y0_startPoint = y0;
				y1_endPoint = y1;
			end
		end
			if (y0_startPoint < y1_endPoint)
				y_step <= 2'b01;
			else
				y_step <= 2'b11;
	end


				
endmodule

//Simulating the module in modelsim
`timescale 1 ps / 1 ps
module line_drawer_testbench();

	logic clk, reset, color;
	logic [10:0]	x0, y0, x1, y1; //the end points of the line
	logic [10:0]	x, y; //outputs corresponding to the pair (x, y)

	line_drawer dut (.clk, .reset, .x0, .y0, .x1, .y1, .x, .y, .color);

	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		x0 = 0; x1 = 100; y0 = 0; y1 = 20;reset = 1; @(posedge clk); //resets and draws line
		reset = 1; @(posedge clk);
		reset = 0; @(posedge clk);
		for (int i = 0; i < 25; i++) begin // cycles through to see line values
			@(posedge clk);
		end	
		$stop; // End the simulation.
	end
endmodule 

