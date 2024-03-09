// modified github code; not part of my demo

module playerPaddle #(parameter pos_MAX, parameter pos_MIN, parameter origin, parameter Paddle_Speed)
(
    input clock,
    input [1:0] key,
    output [10:0] position
);

reg  [31:0] r_Count = 0;
reg  [31:0] r_Count_Inv = 0;
reg  [10:0] r_Pos = origin;

always @(posedge clock)
begin
if(i_Switch[0] == 1'b1)
				begin
				r_Count <= (r_Count == Paddle_Speed) ? 
                	((r_Pos <= pos_MAX) ? (r_Pos <= r_Pos + 1) : r_Pos) : 
                	(r_Count + 1); 	
				end
				
			else if (i_Switch[1] == 1'b1)
				begin
				r_Count_Inv <= (r_Count_Inv == Paddle_Speed) ? 
					((r_Pos > pos_MIN) ? (r_Pos <= r_Pos - 1) : r_Pos) : 
					(r_Count_Inv + 1);
				end
end

endmodule