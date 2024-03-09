# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog ball.v

#load simulation using mux as the top level simulation module
vsim Ball_Position

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# Run simulation

# Test Case 1: Move paddle to the left
run 10ns
force {ps2KeyData} 8'h1C
run 50ns

# Test Case 2: Move paddle to the right
force {ps2KeyData} 8'h23
run 50ns

# Test Case 3: Move paddle to the left (ensure it doesn't go beyond the left edge)
force {ps2KeyData} 8'h1C
run 100ns

# Test Case 4: Move paddle to the right (ensure it doesn't go beyond the right edge)
force {ps2KeyData} 8'h23
run 100ns

# Test Case 5: Move paddle to the left multiple times
force {ps2KeyData} 8'h1C
run 50ns
force {ps2KeyData} 8'h1C
run 50ns

# Test Case 6: Move paddle to the right multiple times
force {ps2KeyData} 8'h23
run 50ns
force {ps2KeyData} 8'h23
run 50ns

# Test Case 7: No key pressed, paddle should remain in the middle
force {ps2KeyData} 8'h00
run 100ns

# Stop simulation
quit
