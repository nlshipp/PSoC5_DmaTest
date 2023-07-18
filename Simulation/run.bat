iverilog -s fifo_TB -y ..\FifoLib.cylib\fifo -y . -D NO_INCLUDE fifo_TB.v
if %errorlevel% neq 0 goto compile_err

vvp a.out
if %errorlevel% neq 0 goto sim_err

start gtkwave fifo_TB.vcd fifo_TB.gtkw

goto exit

:compile_err
echo "Error compiling verilog"
goto exit

:sim_err
echo "Error simulating verilog"
goto exit

:exit