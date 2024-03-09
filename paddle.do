# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog paddle.v

#load simulation using mux as the top level simulation module
vsim paddle

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# Run simulation

module tb_Ball_Position;

    reg i_Clock;
    reg i_Reset;
    reg i_Paddle_Hit;
    reg i_Lose;
    reg i_Space;

    wire o_Direction;
    wire [10:0] o_Pos;

    parameter pos_MAX = 10'd100; // You can adjust these values based on your design requirements
    parameter pos_MIN = 10'd0;
    parameter origin = 10'd50;
    parameter Ball_Speed = 32'd5; // You can adjust the speed

    Ball_Position #(pos_MAX, pos_MIN, origin, Ball_Speed)
        uut (.i_Clock(i_Clock), .i_Reset(i_Reset), .i_Paddle_Hit(i_Paddle_Hit),
             .i_Lose(i_Lose), .i_Space(i_Space), .o_Direction(o_Direction),
             .o_Pos(o_Pos));

    // Clock generation
    initial begin
        i_Clock = 0;
        forever #5 i_Clock = ~i_Clock; // Assuming a 5ns clock period, adjust as needed
    end

    // Test scenario
    initial begin
        // Initialize inputs
        i_Reset = 1'b0;
        i_Paddle_Hit = 1'b0;
        i_Lose = 1'b0;
        i_Space = 1'b0;

        // Apply reset
        #10 i_Reset = 1'b1;
        #10 i_Reset = 1'b0;

        // Wait for a few clock cycles
        #50

        // Start the game (press space)
        i_Space = 1'b1;

        // Simulate game loop
        repeat (100) begin
            #10; // Apply inputs or wait for clock cycles
        end

        // End simulation
        $finish;
    end

endmodule
