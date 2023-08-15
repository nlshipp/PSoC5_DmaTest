# PSoC5_DmaTest
PSoC5LP project to test DMA, FIFO and bit reversing options.

Test different implementations of a dual port fifo (both ports are connected to the CPU/DMA bus)
and DMA channels using indexed/nested DMA to bit reverse a stream of input bytes. On the PSoc5LP
device, multiple DMA channels must be chained to perform indexed DMA where the initial DMA transfer
descriptors update the configuration of following transfer descriptors. This is because
the upper 16 bits of the source and target addresses of each DMA channel are fixed at configuration
and are shared across transfer descriptors in the chain. As the DMA configuration registers are 
located at a different 64k block than RAM, a single DMA channel cannot write to both RAM and
configuration.

## Test implementations
All variations other than BitReverse_D use a memory lookup table to bit reverse input bytes. A value
is loaded into the input FIFO causing the DMA channel to start. The control DMA channel pulls the byte from
the input FIFO and updates the data DMA channel transfer descriptor read offset address to point at a specific
byte in a lookup table. The data DMA channel is then triggered and the appropriate byte is read from the
lookup table and written to the output fifo.

The input fifo's fifo_not_empty line is combined with the output fifo's fifo_not_full line with an AND
gate along with an enable line to trigger the control DMA channel. 

### BitReverse_A 
This uses two transfer descriptors split across two DMA channels and an S/R flipflop to convert the level sensitive output of the fifo DRQ
outputs to edge sensitive inputs of the DMA channel. The NRQ outputs of each DMA channel are connected
to the Set and Reset lines of the flipflop respectively.

### BitReverse_B
This is similar to version 'A' but uses a toggle flipflop to gate the level sensitive output of the fifo DRQ
outputs. The NRQ outputs are OR-ed togother and connected to the toggle input of the flipflop. This
design fails to work reliably because the NRQ outputs of the DMA channel last for two clock cycles causing
the flipflop to toggle twice.

### BitReverse_B2
This is similar to BitReverse_B, but instead of connecting the OR of the DMA NRQ outputs to the flipflop 
toggle input, instead it's connected to the clock of the flipflop and the toggle input is tied to 1. This 
solves the double clocking issue of variant B but at a slightly higher resource (macrocell and P-term) cost.

### BitReverse_C
This version uses a data output register written by the DMA channel to enable/disable the DRQ input of
the DMA channel chain. Each DMA chain has two transfer descriptors, the first TD of the ctrl_DMA chain
reads the byte from the input FIFO and stores it in the first TD of the data_DMA chain. The second TD
of the ctrl_DMA chain writes a zero to the control register, disabling the DRQ input. The NRQ output 
of the first chain then signals the data_DMA chain, which then reads the byte at the specified offset 
from the lookup table and writes it to the output FIFO. The second TD then writes a 1 to the control
register which reenables the DRQ input of the ctrl_DMA chain. 

### BitReverse_D
This final version uses a single DMA chain and cross-wired status and control registers to bit reverse
values. The single DMA chain is triggered directly from the fifo DRQ outputs. The first TD reads the
input fifo and writes the byte to the output register, then the second TD reads the output of the status
register and writes it to the output FIFO. 

## Resource consumption and speed
Of all the designs, 'D' is most likely the fastest as only one DMA channel is used. However it requires
more complicated routing as the 8 outputs of the control register must be connected to the 8 inputs of the
status register. This can be a factor when using this in large designs.

'C' possibly uses the least resources in terms of P-terms and macrocells for designs that are very 
resource constrained but at a cost of speed. Each byte requires four transfer descriptors to be 
processed.

'A' and 'B2' require more P-term and macrocell resources, but should run faster than C but most likely
slower than D.

In all cases other than 'D', the lookup table must be 256 byte page aligned.
