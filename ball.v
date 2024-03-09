// used github variables/parameters, coded the fsm

module Ball_Position #(parameter pos_MAX, parameter pos_MIN, parameter origin, parameter Ball_Speed)
(
	input 			    i_Clock,
	input				i_Reset,
	input				i_Paddle_Hit,
	input				i_Lose,
	input				i_Space,
	output			    o_Direction,
	output [10:0]       o_Pos
);

	reg [31:0] 	r_Count = 0; 		
	reg [31:0] 	r_Count_Inv = 0; 	
	reg [10:0] 	r_Pos = origin;
	reg	 [1:0]	current_state;
	reg	 [1:0]	next_state;
    reg			r_Direction = 1'b1;

	localparam
        // ball not moving
		IDLE = 2'b01,
        // ball in motion
		PLAY = 2'b10;
	
    always @(posedge i_Clock) 
    begin
        current_state <= (i_Reset) ? IDLE : next_state;
    end

    always @(posedge i_Clock)
    begin
    next_state <= current_state;  // Default assignment

    case(current_state)
        
        IDLE:
        begin
        // if space is pressed, the game begins
        next_state <= (i_Space == 1'b1) ? PLAY : IDLE;
        // if space is not pressed, the ball remains stationary at the origin (count does not start)
        if (~i_Space) 
        begin
            r_Pos <= origin;
            r_Count <= 0;
            r_Count_Inv <= 0;
        end
        
        end
        
        PLAY:
        begin
        // if the game is reset or if the player misses the ball (it goes past bottom bound), the game is reset
        next_state <= (i_Reset == 1'b1 || i_Lose == 1'b1) ? IDLE : PLAY;
        if (i_Reset == 1'b1 || i_Lose == 1'b1) 
        begin
            r_Pos <= origin;
            r_Count <= 0;
            r_Count_Inv <= 0;
        end
        else
        begin
        next_state <= PLAY;
        // if the ball hits the paddle, it should go back upwards
        if (i_Paddle_Hit == 1'b1) 
        begin
            r_Pos = (r_Direction == 1'b0) ? (r_Pos - 1) : (r_Pos + 1);
            r_Count <= 0;
            r_Count_Inv <= 0;
            r_Direction <= ~r_Direction; // Change direction after updating position
        end
        // ball moving
        else
            begin
            // if the ball does not hit the paddle, it continues moving in the current direction
            if (r_Direction == 1'b1) 
            begin
                // 1'b1 (right/up)
                r_Count <= (r_Count == Ball_Speed) ? 
                    (r_Pos < pos_MAX ? (r_Pos <= r_Pos + 1) : (r_Direction <= ~r_Direction)) : 
                    r_Count + 1;
            end 
            else 
            begin
                // 1'b0 (left/down)
                r_Count_Inv <= (r_Count_Inv == Ball_Speed) ? 
                    (r_Pos > pos_MIN ? (r_Pos <= r_Pos - 1) : (r_Direction <= ~r_Direction)) : 
                    r_Count_Inv + 1;
            end				
            end
            
            end
        end 												
            default: next_state <= IDLE;
            endcase

    end

    // returns the ball position and direction
    assign o_Pos = r_Pos;
    assign o_Direction = r_Direction;
endmodule