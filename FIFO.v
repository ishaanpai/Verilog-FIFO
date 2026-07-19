module top #(
    parameter width = 16,
    parameter depth = 32
)(
    input RCLK, LCLK, WRDV, RDEN,
    input [width-1:0] WRDAT,
    output reg F, AF, E, AE,
    output reg [width-1:0] RDDAT
);

	reg [width-1:0] mem [0:depth-1];
	
	reg [5:0] wr_ptr_bin = 0;
    reg [5:0] rd_ptr_bin = 0;
	
	wire [5:0] wr_ptr_grey;
    wire [5:0] rd_ptr_grey;
	
	assign wr_ptr_grey = wr_ptr_bin ^ (wr_ptr_bin >> 1);
	assign rd_ptr_grey = rd_ptr_bin ^ (rd_ptr_bin >> 1);
	
	wire [5:0] wr_ptr_grey_sync_1, wr_ptr_grey_sync2;
    wire [5:0] rd_ptr_grey_sync_1, rd_ptr_grey_sync_2;
	
endmodule