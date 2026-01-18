/*
 *  
 *  Copyright(C) 2018 Gerald Coe, Devantech Ltd <gerry@devantech.co.uk>
 * 
 *  Permission to use, copy, modify, and/or distribute this software for any purpose with or
 *  without fee is hereby granted, provided that the above copyright notice and 
 *  this permission notice appear in all copies.
 * 
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO
 *  THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. 
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL 
 *  DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 *  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN 
 *  CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 */
 
//`include "ledscan.v"

module top (
	input clk12MHz, 
	input input1,
	output output1,
	output led1, 
	output led2, 
	output led3, 
	output led4, 
	output led5, 
	output led6, 
	output led7, 
	output led8, 
	output lcol1, 
	output lcol2, 
	output lcol3, 
	output lcol4
	);

// these are the led holding registers, whatever you write to these appears on the led display
	reg [7:0] leds1;
	reg [7:0] leds2;
	reg [7:0] leds3;
	reg [7:0] leds4;
	
// The output from the ledscan module
	wire [7:0] leds;
	wire [3:0] lcol;

	parameter frequency = 1;
	parameter DIVISOR = 12000000 / frequency;

// map the output of ledscan to the port pins	
	assign { led8, led7, led6, led5, led4, led3, led2, led1 } = leds[7:0];
	assign { lcol4, lcol3, lcol2, lcol1 } = lcol[3:0];
	
// Counter register
    reg [31:0] counter = 32'b0;
	// reg led1 = 1'b1;
	// reg led2 = 1'b1;
	// reg led3 = 1'b1;
	reg r1_error = 1'b0;
	reg r2_error = 1'b0;
	reg r3_error = 1'b0;

	reg imu1_en = 2'b00;
	reg imu2_en = 2'b00;
	reg imu3_en = 2'b00;
	reg [1:0] avg_divisor = 2'b00;
	
	reg signed [7:0] imu1 = 8'b00000100;
	reg signed [7:0] imu2 = 8'b00000100;
	reg signed [7:0] imu3 = 8'b01000000;

	reg signed [7:0] result1;
	reg signed [7:0] result2;
	reg signed [7:0] result3;

	reg signed [7:0] ZERO = 8'b00000000;
	reg signed [7:0] threshold = 8'b00000100;
	reg [7:0] average;

	initial output1 = 1'b1;

// instantiate the led scan module
 	LedScan scan (
		.clk12MHz(clk12MHz), 
		.leds1(leds1),		
		.leds2(leds2),
		.leds3(leds3),
		.leds4(leds4),
		.leds(leds), 
		.lcol(lcol)
	);
 
	function [7:0] abs(input signed [7:0] num_to_invert); 
		begin
			abs = (num_to_invert < ZERO) ? (~num_to_invert + 1) : num_to_invert;
		end
	endfunction
  
  // This is where you place data in the leds matrix for display.
  // Here we put a counter on the 1st column and a simple pattern on the others
    always @ (*) begin

		result1 = abs(imu1-imu2);
		result2 = abs(imu1-imu3);
		result3 = abs(imu2-imu3);

		r1_error = (result1>threshold);
		r2_error = (result2>threshold);
		r3_error = (result3>threshold);

		imu1_en[0] = ~(r1_error & r2_error & ~r3_error);
		imu2_en[0] = ~(r1_error & ~r2_error & r3_error);
		imu3_en[0] = ~(~r1_error & r2_error & r3_error);

		avg_divisor = imu1_en + imu2_en + imu3_en; //bug - divisor is larger than should be

		average = (avg_divisor > 0) ? (((imu1&&imu1_en) + (imu2&&imu2_en) + (imu3&&imu3_en))/avg_divisor) : 8'h00;

		leds1[7:0] = {~imu1_en[0], ~imu2_en[0], ~imu3_en[0], ~avg_divisor, ~average[2:0]};
		leds2[7:0] = ~imu1;
		leds3[7:0] = ~imu2;
		leds4[7:0] = ~imu3;
    end

// increment the counter every clock, only the upper bits are mapped to the leds.	
    always @ (posedge clk12MHz) begin
		//output1 = 1'b0;
        counter = counter + 1;
	end


endmodule
