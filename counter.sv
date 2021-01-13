module counter #(parameter BITS = 11, MAX = 480) (clk,reset,incr,out,done);

	input logic clk,reset,incr;
	output logic done;
	output logic [BITS - 1:0] out;
	logic [BITS - 1:0] count;
//Counter keeps counting until it gets to the max value which is the resolution of the monitor
//When it gets to the max value, it automatically resets the counter. 
//After its done counting till the max value, the output toggles a start value which starts counting x values 
//on the screen.
	always_ff @(posedge clk) begin
		if(reset) begin
			count <= 0;
			done <= 1'b0;
		end else if (count == MAX) begin
			count <= 0;
			done <= 1'b1;
		end else if (incr) begin
			count++;
			done <= 1'b0;
		end else
			count <= count;
	end
		assign out = count;
endmodule
