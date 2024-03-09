// top level module
module pong
	(
		CLOCK_50,						//	On Board 50 MHz
		RESETN,
		KEY,
    	// Keyboard inputs
    	PS2_DAT,
	  	PS2_CLK,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	/*****************************************************************************
	*                          GAME SETTINGS (3RD PARTY)                         *
	*****************************************************************************/
	// 640 x 480 SCREEN; size from tinyvga referenced from github use
	parameter 		Pos_X_Max = 774;
	parameter 		Pos_X_Min = 153;
	parameter		Pos_Y_Max = 485;
	parameter 		Pos_Y_Min = 65; 

	parameter		Paddle_Speed 	= 100000; 		// smaller = faster
	parameter 		Ball_Speed		= 100000;
	parameter		Paddle_Width	= 48;	
	parameter		Paddle_Thick    = 16;
	parameter		Ball_Size		= 16;

	// Intial positions 
	parameter 	Paddle_X = 400 - Paddle_Width / 2;
	parameter 	Paddle_Y = 400;
	parameter 	Ball_X = 400 - Ball_Size / 2;
	parameter	Ball_Y = 200;

	/*****************************************************************************
	*                              GAME VARIABLES                                *
	*****************************************************************************/
	// SYSTEM
	input CLOCK_50; // 50 MHz
	input RESETN;
	input [3:0] KEY;

	// PS2
	inout PS2_DAT;
	inout PS2_CLK;
	wire [7:0] ps2_data;
	wire ps2_pressed;

	parameter character_a = 8'h1c; 	
	parameter character_d = 8'h23;
	parameter character_space = 8'h29;

	wire [3:0] connect_button; // A D MOVEMENT
	wire connect_space;

	// VGA
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]

	wire clock_25;
	assign VGA_CLK = clock_25;

	reg [10:0] screen_countH;
	reg [10:0] screen_countV;

	// referenced from github vga adaptor
	
	wire vga_hsync;
	assign vga_hsync = (screen_countH < 96) ? 1'b0 : 1'b1;
	assign VGA_HS = vga_hsync;

	wire vga_vsync;
	assign vga_vsync = (screen_countV < 2) ? 1'b0 : 1'b1;
	assign VGA_VS = vga_vsync;

	wire vga_blank;
	assign vga_blank = (screen_countV > 35 && screen_countV < 515 && screen_countH > 143 && screen_countH < 784) ? 1'b1 : 1'b0;
	assign VGA_BLANK_N = vga_blank;

	wire vga_clearH;
	assign vga_clearH = (screen_countH <= 800) ? 1'b0 : 1'b1;

	wire vga_clearV;
	assign vga_clearV = (screen_countV <= 525) ? 1'b0 : 1'b1;

	// GAME
	wire [10:0] paddle_posX;
	wire [10:0] paddle_posY;

	wire ball_direction; // 0 = up; 1 = down
	wire [10:0] ball_posX;
	wire [10:0] ball_posY;

	wire paddle_enable;
	wire ball_enable;

	wire paddle_hit;
	paddle_hit <= (((ball_posY + Ball_Size) == (paddle_posY - Paddle_Thick)) &&
				(((ball_posX + Ball_Size) >= (paddle_posX - Paddle_Length)) && ((ball_posX - Ball_Size) <= (paddle_posX + Paddle_Length))) &&
				(ball_direction == 1'b1)) ? 1'b1 : 1'b0;

	wire player_lose;
	player_lose <= ((ball_posY + Paddle_Thick) == Pos_Y_Max) ? 1'b1 : 1'b0;

	/*****************************************************************************
	*                              PS/2 KEYBOARD                                 *
	*****************************************************************************/
	// Clock divider 50 -> 25 MHz
	reg clock_divider = 0;
	always @(posedge CLOCK_50) begin
		clock_divider <= ~clock_divider;
	end
	assign clock_25 = clock_divider;

	PS2_Controller keyboard (
		// Inputs
		.CLOCK_50			(CLOCK_50),
		.reset				(RESETN),

		// Bidirectionals
		.PS2_CLK			(PS2_CLK),
		.PS2_DAT			(PS2_DAT),

		// Outputs
		.received_data		(ps2_data),
		.received_data_en	(ps2_pressed)
	);
	
  Check_Key #(.KEYA(character_a), .KEYD(character_d)) 
	A_D_KEYS 
	(
		.clock(CLOCK_50),
		.key_data(ps2_data),
		.key_pressed(ps2_pressed),
		.keyA(connect_button[1]),
		.keyD(connect_button[0]),
		.outSpace(connect_space)
	);

	/*****************************************************************************
	*                              VGA DISPLAY                                   *
	*****************************************************************************/
	// // Create an Instance of a VGA controller - there can be only one!
	// // Define the number of colours as well as the initial background
	// // image file (.MIF) for the controller.
	// vga_adapter VGA(
	// 		.resetn(RESETN),
	// 		.clock(CLOCK_50),
	// 		.colour(colour),
	// 		.x(x),
	// 		.y(y),
	// 		.plot(writeEn),
	// 		/* Signals for the DAC to drive the monitor. */
	// 		.VGA_R(VGA_R),
	// 		.VGA_G(VGA_G),
	// 		.VGA_B(VGA_B),
	// 		.VGA_HS(VGA_HS),
	// 		.VGA_VS(VGA_VS),
	// 		.VGA_BLANK(VGA_BLANK_N),
	// 		.VGA_SYNC(VGA_SYNC_N),
	// 		.VGA_CLK(VGA_CLK));
	// 	defparam VGA.RESOLUTION = "320x240";
	// 	defparam VGA.MONOCHROME = "FALSE";
	// 	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	// 	defparam VGA.BACKGROUND_IMAGE = "background.mif";

	// //Images referenced from github but not used
	// paddle pl(.address(CounterA),.clock(CLOCK_50),.data(000),.wren(0),.q(colourPlayer));
	// background bg(.address(y*320 + x),.clock(CLOCK_50),.data(000),.wren(0),.q(colourBG));
	// gameStart bg1 (.address(y*320 + x),.clock(CLOCK_50),.q(colourSTART));
	// gameOver bg2(.address(y*320 + x),.clock(CLOCK_50),.q(colourWIN));

	/*****************************************************************************
	*                              GAME LOGIC                                    *
	*****************************************************************************/
	// referenced from github calling using their variables modified for my game
	playerPaddle #(.pos_MAX(Pos_X_Max),
		.pos_MIN(Pos_X_Min),
		.origin(Paddle_X_Pos),
		.Paddle_Speed(Paddle_Speed)
		)
		Paddle_1_X
		(
		.clock(CLOCK_50),
		.key(moveButton[1:0]),
		.position(P_x)
		);

	Ball_Position	#(.pos_MAX(Pos_X_Max),
		.pos_MIN(Pos_X_Min),
		.origin(Ball_X_Pos),
		.Ball_Speed(Ball_Speed)
		)
	Ball_X
		(
		.i_Clock(r_Clock_25MHz),
		.i_Reset(i_Reset),
		.i_Paddle_Hit(1'b0),
		.i_Win(Win),
		.i_Space(w_Space),
		.o_Direction(),
		.o_Pos(P_x_Ball)
		);
										
	Ball_Position	#(.pos_MAX(Pos_Y_Max),
		.pos_MIN(Pos_Y_Min),
		.origin(Ball_Y_Pos),
		.Ball_Speed(Ball_Speed)
	)
		Ball_Y
			(
		.i_Clock(r_Clock_25MHz),
		.i_Reset(i_Reset),
		.i_Paddle_Hit(Paddle_Hit), // Pass 0 value for Y position check, only reverses in X position. Keeps Y momentum
		.i_Win(Win),
		.i_Space(spaceButton),
		.o_Direction(w_Direction),
		.o_Pos(P_y_Ball)
			);

always @ (posedge clock_25)
begin 
	screen_countH <= (vga_clearH) ? 0 : (screen_countH + 1);
end

always @ (posedge clock_25)
begin 
	screen_countV <= (vga_clearV) ? 0 : ((screen_countV == 800) ? (screen_countV + 1) : screen_countV);
end

// draw
assign ball_enable <= ((screen_countH >= (ball_posX - Ball_Size)) && (screen_countH <= (ball_posX + Ball_Size)) &&
                (screen_countV >= (ball_posY - Ball_Size)) && (screen_countV <= (ball_posY + Ball_Size))) ? 1'b1 : 1'b0;

assign paddle_enable <= ((screen_countH >= (paddle_posX - Paddle_Thick)) && (screen_countH <= (paddle_posX + Paddle_Thick)) &&
                  (screen_countV >= (paddle_posY - Paddle_Length)) && (screen_countV <= (paddle_posY + Paddle_Length))) ? 1'b1 : 1'b0;

	
assign {VGA_R, VGA_G, VGA_B} = (vga_blank == 1'b1 && (ball_enable || paddle_enable)) ? 24'b11111111_11111111_11111111 : 24'b00000000_00000000_00000000;

endmodule