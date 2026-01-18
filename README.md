
# Overview

The original aims of this project was to:
- Implement an SPI communication driver in digital hardware using an iCEFUN-HX8K FPGA board and MPU9250 IMUs
- Interface with an IMU and parse data
- Interface with three IMUs in parallel
- Use a voting system to filter out unreliable data

What was achieved:
- Finite state machine for successful loopback communication
- Voting system

Still left to do:
- Implement MPU9250 IMU wake-up and initialisation sequence
- Store data from IMU
- Three IMUs
- Iron out bugs in voting system that lead to incorrect division 
- Complete testbench

# System Architecture

## Top Module
- State machine for SPI transaction
- Displays debug information onto LED array
  
## SPI Clock
- Divides system clock to a lower frequency
  
## Shift Register
- Responsible for input/output of data bitwise via IO pins

## LED Scan
- Module provided by DevanTech to update LED grid array

# Images

## Loopback Communication 
Loopback communication at divided clock rate (low for demo purposes)

