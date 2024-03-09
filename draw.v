module draw(
	input CLOCK_50,
	input visibleArea,
	input [7:0] gameState,
	input [15:0] screenX,
	input [15:0] screenY,
	input [15:0] ballX,
	input [15:0] ballY,
	input [15:0] playerPaddleX,
	output reg [2:0] screenPixel
);

// Colors
localparam
	black = 3'b000,
	white = 3'b111;

reg [2:0] gameOverBackgroundColor = white;
reg [2:0] backgroundColor = black;

reg [7:0] digitX;
reg [7:0] digitY;

reg [2:0] ballPixel;
reg [2:0] playerPaddlePixel;
reg [2:0] computedPixel;

always @(posedge CLOCK_50)
begin
	if (visibleArea)
	begin
		if (screenX >= ballX
			& screenX < ballX + Ball.width
			& screenY >= ballY
			& screenY < ballY + Ball.height)
			ballPixel <= white;
		else
			ballPixel <= black;

		if (screenX >= PlayerPaddle.x
			& screenX < PlayerPaddle.x + PlayerPaddle.width
			& screenY >= playerPaddleY
			& screenY < playerPaddleY + PlayerPaddle.height)
			playerPaddlePixel <= cyan;
		else
			playerPaddlePixel <= black;

		if (screenX >= ComputerPaddle.x
			& screenX < ComputerPaddle.x + ComputerPaddle.width
			& screenY >= computerPaddleY
			& screenY < computerPaddleY + ComputerPaddle.height)
			computerPaddlePixel <= cyan;
		else
			computerPaddlePixel <= black;


		computedPixel <= ballPixel | playerPaddlePixel;

		if (computedPixel == black)  // Black gets replaced by background color.
			if (gameState == GameState.stateGameOver)
				// Produce a checkerboard dither pattern with black and background color.
				// Makes background "dim" when game is over.
				if (screenX[0] + screenY[0])
					screenPixel <= gameOverBackgroundColor;
				else
					screenPixel <= black;
			else
				screenPixel <= backgroundColor;
		else
			screenPixel <= computedPixel;
	end
end

endmodule

module GameState(
	input CLOCK_50,
	input vSyncStart,
	input [7:0] buttons,
	input collisionBallScreenBottom,
	output reg [7:0] state = stateGameOver
);

// Game states
parameter
	stateGameOver = 8'd0,
	statePlaying = 8'd1,
	statePlayerScored = 8'd2;

reg startButtonReleased = 0;
reg [15:0] count = 0;

always @(posedge pixelClock)
begin
	if (vSyncStart)
	begin
		case(state)
			stateGameOver:
				begin
					// Wait until button is not pressed before checking to see if it's pressed.
					// This way we don't skip the game-over state if button is already held down.
					if (~buttons[NesController.buttonStart])
						startButtonReleased <= 1;

					if (startButtonReleased & buttons[NesController.buttonStart])
							state <= statePlaying;
						end
				end
			statePlaying:
				begin
					if (collisionBallScreenLeft)
						begin
							count <= 0;
							state <= stateComputerScored;
						end

					if (collisionBallScreenRight)
						begin
							count <= 0;
							state <= statePlayerScored;
						end
				end
			statePlayerScored:
				begin
					if (count == 0)
						begin
							count <= count + 1'b1;
						end
					else
						begin
							if (count < 60 * 2)
								begin
									count <= count + 1'b1;
								end
							else
								begin
									if (buttons[NesController.buttonA])
										state <= statePlaying;
								end
						end
				end
		endcase
	end
end

endmodule