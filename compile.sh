#!/bin/bash

topModule="tb_sram_bist"
subModule="sram.v sram_bist.v tb_sram_bist.v"

iverilog -s $topModule -o test $subModule
vvp ./test