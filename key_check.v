// referenced from github, changed it

module Check_Key
#(
    // Keycodes for A and D (left/right)
	parameter KEYA,
	parameter KEYD
 )

(
	input clock,
	input [7:0] key_data,
	input key_pressed,
	
	output keyA,
	output keyD,
	output outSpace
);

localparam  
	BREAK    = 8'hf0,
	c_SPACE  = 8'h29;

reg r_KeyA = 0;
reg r_KeyD = 0; 
reg [15:0] r_data = 0;
reg r_Space;

always @(posedge clock) begin
    // Save data byte by byte if key is pressed
    r_data <= (key_pressed == 1'b1) ? {r_data[7:0], key_data[7:0]} : r_data;

    // Check for KEYA
    if (r_data[7:0] == KEYA) begin
        r_KeyA <= (r_data[15:8] == BREAK) ? 1'b0 : 1'b1;
    end

    // Check for KEYD
    if (r_data[7:0] == KEYD) begin
        r_KeyD <= (r_data[15:8] == BREAK) ? 1'b0 : 1'b1;
    end

    // Check for the space bar
    r_Space <= (r_data[7:0] == c_SPACE && r_kbd_data[15:8] == BREAK) ? 1'b1 : 1'b0;
end
	
assign keyA = r_KeyA;
assign keyD = r_KeyD;
assign outSpace = r_Space;
endmodule

