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

module ShiftReg (
	input clk1MHz, 
	input shift_en, 
	input SPI_MISO_IN,
	output SPI_MOSI_OUT,
	output SPI_CLK,
	output [3:0] shift_count,
	output [7:0] shift_out_reg,
	output [7:0] shift_in_reg
	);

	reg [7:0] shift_out;
	reg [7:0] shift_in;
	reg [3:0] count;
	reg SPI_MOSI = 1'b0;

	assign SPI_CLK = ~clk1MHz & ~shift_en;
	//assign shift_count = count;

	always @(negedge clk1MHz) begin
		shift_out_reg <= shift_out;
		shift_in_reg <= shift_in;
		SPI_MOSI_OUT <= shift_out[7];
	end

	always @(posedge clk1MHz) begin

		if (~shift_en) begin
			shift_count <= shift_count + 1;
			shift_out <= {shift_out[6:0], 1'b1};
			shift_in <= {shift_in[6:0], SPI_MISO_IN};
		end else begin
			shift_count <= shift_count;
			shift_out <= 8'b11011001;
			shift_in <= shift_in;
		end
	end

endmodule
