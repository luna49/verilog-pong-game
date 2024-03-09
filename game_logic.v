module ball(
	input CLOCK_50,
	input vSyncStart,
	input [7:0] gameState,
	input [7:0] buttons,
	input collisionBallScreenLeft,
	input collisionBallScreenRight,
	input collisionBallScreenTop,
	input collisionBallScreenBottom,
	input collisionBallPlayerPaddle,
	output reg [15:0] x,
	output reg [15:0] y,
	output reg [7:0] xSpeed,
	output reg [7:0] ySpeed
);

// Ball size is 16x16 pixels
parameter
	width = 8'd16,
	height = 8'd16;

// Start ball in the middle of the screen.
initial x = 320 / 8'd2 - width / 8'd2;
initial y = 240 / 8'd2 - height / 8'd2;

initial xSpeed = 5;
initial ySpeed = 5;

reg xDirection = 0;
reg yDirection = 0;

reg [8:0] playerPaddleX = PlayerPaddle.x;
reg [8:0] playerPaddleWidth = PlayerPaddle.width;

always @(posedge CLOCK_50)
begin
	if (vSyncStart)
		begin
			if (gameState == GameState.statePlaying)
				begin
					if (xDirection)  // Ball is moving right.
						begin
							if (collisionBallScreenRight)
								begin
									xDirection <= 0;
								end
						end
					else
						begin
							if (collisionBallScreenLeft)
								begin
									xDirection <= 1;
								end
						end

					if (yDirection)  // Ball is moving down.
						begin
							if (collisionBallScreenBottom)
								begin
									// Flip ball direction to move up.
									yDirection <= 0;
								end
							else if (collisionBallPlayerPaddle)
                begin
                  // Fix ball location in case it's intersecting paddle.
                  y <= playerPaddleY[15:0] + playerPaddleHeight[15:0];

                  // Flip ball direction to move up.
                  yDirection <= 0;
                end
              else
                begin
                  // Move ball down, but prevent if from going off-screen.
                  if (y > ySpeed)
                    y <= y - ySpeed;
                  else
                    y <= 0;
                end
					else
						begin
							if (collisionBallScreenTop)
								begin
									// Flip ball direction to move down.
									yDirection <= 1;
								end
							else
								begin
									// Move ball up, but prevent if from going off-screen.
									if (y > ySpeed)
										y <= y - ySpeed;
									else
										y <= 0;
								end
						end
				end
			else
				begin
					// Move ball to the middle of the screen.
					x <= 320 / 8'd2 - width / 8'd2;
					y <= 240 / 8'd2 - height / 8'd2;
				end
		end
end

endmodule

module Collision(
	input CLOCK_50,
	input vSyncStart,
	input [15:0] ballX,
	input [15:0] ballY,
	input [7:0] ballXSpeed,
	input [7:0] ballYSpeed,
	input [15:0] playerPaddleY,
	output reg collisionBallScreenLeft = 0,
	output reg collisionBallScreenRight = 0,
	output reg collisionBallScreenTop = 0,
	output reg collisionBallScreenBottom = 0,
	output reg collisionBallPlayerPaddle = 0
);

always @(posedge CLOCK_50)
begin
	if (vSyncStart)
	begin
		if (ballX == 0)
			collisionBallScreenLeft <= 1;
		else
			collisionBallScreenLeft <= 0;
			
		if (ballX + Ball.width == 320)
			collisionBallScreenRight <= 1;
		else
			collisionBallScreenRight <= 0;

		if (ballY == 0)
			collisionBallScreenTop <= 1;
		else
			collisionBallScreenTop <= 0;

		if (ballY + Ball.height == 240)
			collisionBallScreenBottom <= 1;
		else
			collisionBallScreenBottom <= 0;
			
		if (ballY + Ball.height >= PlayerPaddle.y - ballYSpeed
			& ballX > playerPaddleX
			& ballX < playerPaddleX + PlayerPaddle.width)
			collisionBallPlayerPaddle <= 1;
		else
			collisionBallPlayerPaddle <= 0;
	end
end

endmodule