# FPGA Quadcopter

An FPGA-based quadcopter flight controller developed in VHDL using an Altera Cyclone IV FPGA.

This project aims to implement the core flight-control logic of a quadcopter directly in programmable hardware, without using a conventional microcontroller as the flight controller.

## Project Status

🚧 **In development**

The project currently starts with the implementation and verification of basic FPGA functionality.

The first hardware test uses the 50 MHz onboard clock of the DSD-i1 development board to drive an LED through a VHDL-based counter.

## Hardware

### FPGA Development Board

**DSD-i1 Digital System Design Development Board**

- FPGA: Altera Cyclone IV E EP4CE6E22C8
- FPGA resources: 6,272 Logic Elements
- Onboard clock: 50 MHz
- FPGA development: Quartus Prime
- HDL: VHDL

## Planned Architecture

The final flight controller is planned to contain the following hardware modules:

```text
                     FPGA
                      │
          ┌───────────┼───────────┐
          │           │           │
         SPI         PWM         UART
          │           │           │
         IMU        ESC × 4    Telemetry
          │           │
          ▼           ▼
   Sensor Processing  │
          │           │
          ▼           │
  Attitude Estimation │
          │           │
          ▼           │
      PID Control     │
     Roll/Pitch/Yaw   │
          │           │
          ▼           │
      Motor Mixer     │
          │           │
          ▼           ▼
             PWM × 4
                │
             ESC × 4
                │
            Motors × 4
