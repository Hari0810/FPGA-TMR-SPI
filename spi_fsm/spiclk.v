
module ClkDiv (
	input clk12MHz, 
	output clk1MHz
	);

	reg clk = 1'b0;

	parameter frequency = 2;
	parameter DIVISOR = 12000000 / frequency;
	
    reg [31:0] counter = 32'b0;

	always @(posedge clk12MHz) begin
		counter <= counter + 1;
		clk1MHz <= clk;
		if (((counter*2) % (DIVISOR)) == 0) clk <= ~clk;
	end

endmodule
