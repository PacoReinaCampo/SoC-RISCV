###################################################################################
##                                            __ _      _     _                  ##
##                                           / _(_)    | |   | |                 ##
##                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |                 ##
##               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |                 ##
##              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |                 ##
##               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|                 ##
##                  | |                                                          ##
##                  |_|                                                          ##
##                                                                               ##
##                                                                               ##
##              Architecture                                                     ##
##              QueenField                                                       ##
##                                                                               ##
###################################################################################

###################################################################################
##                                                                               ##
## Copyright (c) 2019-2020 by the author(s)                                      ##
##                                                                               ##
## Permission is hereby granted, free of charge, to any person obtaining a copy  ##
## of this software and associated documentation files (the "Software"), to deal ##
## in the Software without restriction, including without limitation the rights  ##
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     ##
## copies of the Software, and to permit persons to whom the Software is         ##
## furnished to do so, subject to the following conditions:                      ##
##                                                                               ##
## The above copyright notice and this permission notice shall be included in    ##
## all copies or substantial portions of the Software.                           ##
##                                                                               ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   ##
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ##
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     ##
## THE SOFTWARE.                                                                 ##
##                                                                               ##
## ============================================================================= ##
## Author(s):                                                                    ##
##   Paco Reina Campo <pacoreinacampo@queenfield.tech>                           ##
##                                                                               ##
###################################################################################

# Remove Submodule
git rm -rf dbg
git rm -rf dma
git rm -rf gpio
git rm -rf mpi
git rm -rf mpram
git rm -rf msi
git rm -rf noc
git rm -rf spram
git rm -rf uart

git rm -rf pu

# Update Submodule
git submodule update --init --recursive --remote

# Add Submodule
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-DBG.git dbg
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-DMA.git dma
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-GPIO.git gpio
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-MPI.git mpi
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-MPRAM.git mpram
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-MSI.git msi
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-NoC.git noc
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-SPRAM.git spram
git submodule add --force https://github.com/PacoReinaCampo/MPSoC-UART.git uart

git submodule add --force https://github.com/PacoReinaCampo/PU-RISCV.git pu
