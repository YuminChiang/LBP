`timescale 1ns/10ps
module LBP (
    input         	  clk       ,
    input         	  reset     ,
    output reg [13:0] RGB_addr  ,
    output reg        RGB_req   ,
    input          	  RGB_ready ,
    input  	   [23:0] RGB_data  ,
    output reg [13:0] lbp_addr  ,
    output reg        lbp_valid ,
    output reg [7:0]  lbp_data  ,
    output reg [13:0] gray_addr ,
    output reg        gray_valid,
    output reg [7:0]  gray_data ,
    output reg        finish
);

// State Definition
parameter IDLE = 3'd0, REQ = 3'd1, GRAY = 3'd2, GET_GC = 3'd3, LBP = 3'd4, DONE = 3'd5;

reg [2:0] cs, ns;

// Counter
reg [13:0] gray_addr_cnt;
reg [13:0] lbp_addr_cnt;
// 	Internal memory for gray val.
reg [7:0] gray_mem[0:16383];

reg [7:0] g0, g1, g2, g3, gc, g4, g5, g6, g7;

// State Register
always @(posedge clk or posedge reset) begin
	if (reset)
		cs <= IDLE;
	else
		cs <= ns;
end

// Next State logic
always @(*) begin
	case (cs)
		// Gray
		IDLE: ns = RGB_ready ? REQ : IDLE;
		REQ: ns = GRAY;
		GRAY: ns = (gray_addr_cnt == 14'd16383) ? LBP : REQ;
		GET_GC: ns = LBP;
		LBP: ns = (lbp_addr_cnt == 14'd16383) ? DONE : GET_GC;
		DONE: ns = DONE;
		default: ns = IDLE;
	endcase
end

//  Output logic
always @(posedge clk or posedge reset) begin
	if (reset) begin
		RGB_addr <= 0;
		RGB_req <= 0;
		gray_addr <= 0;
		gray_valid <= 0;
		gray_data <= 0;
		gray_addr_cnt <= 0;
		lbp_addr_cnt <= 0;
		lbp_addr <= 0;
		lbp_valid <= 0;
		lbp_data <= 0;
		finish <= 0;
	end 
	else begin
		case (cs)
			IDLE: begin
				RGB_req <= 0;
				gray_valid <= 0;
				lbp_data <= 0;
				finish <= 0;
			end
			REQ: begin
				RGB_req <= 1;
				RGB_addr <= gray_addr_cnt;
			end
			GRAY: begin
				RGB_req <= 0;
				gray_valid <= 1;
				gray_addr <= gray_addr_cnt;
				gray_data <= (RGB_data[23:16] + RGB_data[15:8] + RGB_data[7:0]) / 3;
				gray_mem[gray_addr_cnt] <= (RGB_data[23:16] + RGB_data[15:8] + RGB_data[7:0]) / 3;
				gray_addr_cnt <= gray_addr_cnt + 1;	
			end
			GET_GC: begin
    			gray_valid <= 0;
    			lbp_valid <= 0;
    			lbp_addr <= lbp_addr_cnt;
    			gc <= gray_mem[lbp_addr_cnt];
			end
			LBP: begin
				lbp_valid <= 1;
				lbp_addr <= lbp_addr_cnt;
				g0 <= gray_mem[lbp_addr_cnt - 129];
                g1 <= gray_mem[lbp_addr_cnt - 128];
                g2 <= gray_mem[lbp_addr_cnt - 127];
                g3 <= gray_mem[lbp_addr_cnt - 1];
                gc <= gray_mem[lbp_addr_cnt];
                g4 <= gray_mem[lbp_addr_cnt + 1];
                g5 <= gray_mem[lbp_addr_cnt + 127];
                g6 <= gray_mem[lbp_addr_cnt + 128];
                g7 <= gray_mem[lbp_addr_cnt + 129];
				lbp_data <= ((g0 >= gc) ? 8'd1 : 8'd0)   +
                         	((g1 >= gc) ? 8'd2 : 8'd0)   +
                            ((g2 >= gc) ? 8'd4 : 8'd0)   +
                            ((g3 >= gc) ? 8'd8 : 8'd0)   +
                            ((g4 >= gc) ? 8'd16 : 8'd0)  +
                            ((g5 >= gc) ? 8'd32 : 8'd0)  +
                            ((g6 >= gc) ? 8'd64 : 8'd0)  +
                            ((g7 >= gc) ? 8'd128 : 8'd0);
				lbp_addr_cnt <= lbp_addr_cnt + 1;
			end
			DONE: begin
				lbp_valid <= 0;
				finish <= 1;
			end

		endcase
	end
end

endmodule