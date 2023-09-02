module DFF_para(d, rst, clk, cen,q);
	parameter WIDTH = 3;
	parameter RST_MODE = "SYNC";

	input [WIDTH-1 : 0] d;
	input rst,clk,cen;
	output reg [WIDTH-1 : 0] q;
	//output qbar;
	generate
		if(RST_MODE == "ASYNC") begin
			always @(posedge clk or posedge rst) begin
				if (rst) begin
					q <= {WIDTH{1'b0}};
				end
				else begin
					if(cen) begin
						q <= d;	
					end
				end
			end
		end
		else if(RST_MODE == "SYNC") begin
			always @(posedge clk) begin
				
				if (rst) begin //16/8/2023 updated to make rst have the highest priority
					q <= {WIDTH{1'b0}};
				end
				else if(cen) begin
					//else begin
						q <= d;
					//end
				end
			end
		end
	endgenerate
	//assign qbar = ~q;
endmodule