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

//FSM3 - has modules for Shiftreg, Clkdiv (spiclk) and LedScan

module top (
	input clk12MHz, 
	input rst,
	input SPI_MISO_IN,
	output SPI_CLK_OUT,
	output SPI_MOSI_OUT,
	output SPI_CS_OUT,
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

	reg SPI_CS;
	reg SPI_CLK;
	//reg SPI_MOSI;


// these are the led holding registers, whatever you write to these appears on the led display
	reg [7:0] leds1;
	reg [7:0] leds2;
	reg [7:0] leds3;
	reg [7:0] leds4;
	
// The output from the ledscan module
	wire [7:0] leds;
	wire [3:0] lcol;

// map the output of ledscan to the port pins	
	assign { led8, led7, led6, led5, led4, led3, led2, led1 } = leds[7:0];
	assign { lcol4, lcol3, lcol2, lcol1 } = lcol[3:0];
	

	reg count_en = 1'b0;
	reg delay_en = 1'b0;
	reg [31:0] time_count = 32'h0;

	reg [7:0] shift_out_reg;
	reg [7:0] shift_in_reg;
	reg [3:0] shift_count;


	reg led1_state = 1'b1;
	reg led2_state = 1'b1;
	reg led3_state = 1'b1;
	reg state;
	reg next = 2'b00;
	parameter IDLE=2'b00, SENDING=2'b01, DELAY=2'b10;

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

	ClkDiv clkDiv (
		.clk12MHz(clk12MHz),
		.clk1MHz(clk1MHz)
	);

	ShiftReg shiftReg (
		.clk1MHz(clk1MHz),
		.SPI_CLK(SPI_CLK),
		.shift_en(count_en),
		.SPI_MISO_IN(SPI_MISO_IN),
		.SPI_MOSI_OUT(SPI_MOSI_OUT),
		.shift_count(shift_count),
		.shift_out_reg(shift_out_reg),
		.shift_in_reg(shift_in_reg)
	);
  
    always @ (*) begin
		leds1[7:0] = {~count_en, ~delay_en, 2'b11, ~shift_count};
		leds2[7:0] = shift_out_reg;
		leds3[7:0] = shift_in_reg;
		leds4[7:0] = {~time_count[7:0]};
    end

// increment the counter every clock, only the upper bits are mapped to the leds.	
    always@(*) begin
		case (state)
			IDLE: next = (!rst) ? SENDING : IDLE;
			SENDING: next = (shift_count == 4'b0111) ? DELAY : SENDING;
			DELAY: next = DELAY;
			default: next = DELAY;
		endcase
	end

	always @(posedge clk1MHz) begin
		state <= next;
		time_count <= (delay_en) ? (time_count + 1) : 32'h0;
	end

	always @(*) begin
		case (state)
			IDLE: begin		
				count_en = 1'b1;
				delay_en = 1'b0;
			end

			SENDING: begin
				count_en = 1'b0;
				delay_en = 1'b0;
			end

			DELAY: begin
				count_en = 1'b1;
				delay_en = 1'b1;
			end

			default: begin
				count_en = 1'b0;
				delay_en = 1'b1;
			end
		endcase
	end

endmodule
