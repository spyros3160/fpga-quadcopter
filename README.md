# FPGA Quadcopter

An FPGA-based quadcopter flight controller developed in VHDL using an Altera Cyclone IV FPGA.

This project aims to implement the core flight-control logic of a quadcopter directly in programmable hardware, without using a conventional microcontroller as the flight controller.

## Project Status

🚧 **In development**

The project currently starts with the implementation and verification of basic FPGA functionality.

The first hardware test uses the 50 MHz onboard clock of the DSD-i1 development board to drive an LED through a VHDL-based counter.

## Hardware

### Current Development Board

**DSD-i1 Digital System Design Development Board**

- FPGA: Altera Cyclone IV E EP4CE6E22C8
- FPGA resources: 6,272 Logic Elements
- Onboard clock: 50 MHz
- FPGA development tool: Quartus Prime 20.1 Lite
- HDL: VHDL

### Future Development Board

**Terasic DE10-Lite**

- FPGA: Intel MAX 10 10M50DAF484C7G
- Approximately 50,000 Logic Elements
- Onboard USB-Blaster
- 3.3 V GPIO
- FPGA development tool: Quartus Prime
- HDL: VHDL

The VHDL modules are being designed to remain portable between the DSD-i1 Cyclone IV FPGA and the future DE10-Lite MAX 10 FPGA.

Board-specific pin assignments and constraints will be kept separate from the reusable RTL design.

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
            Motors × 4## Development Roadmap

### Phase 1 — FPGA Fundamentals

- [x] Quartus project creation
- [x] VHDL top-level entity
- [x] 50 MHz clock input
- [x] Counter implementation
- [x] LED output
- [x] FPGA pin assignments
- [x] Successful Quartus compilation
- [ ] Hardware programming and LED test
- [x] PWM generator
- [x] PWM simulation and verification

### Phase 2 — Motor Control

- [ ] Four independent PWM outputs
- [ ] ESC interface
- [ ] Bench testing with propellers removed

### Phase 3 — IMU Interface

- [ ] SPI master
- [ ] IMU communication
- [ ] Accelerometer data processing
- [ ] Gyroscope data processing

### Phase 4 — Flight Control

- [ ] Attitude estimation
- [ ] Roll PID controller
- [ ] Pitch PID controller
- [ ] Yaw PID controller
- [ ] Quadrotor motor mixer

### Phase 5 — System Integration

- [ ] Radio receiver interface
- [ ] Failsafe logic
- [ ] UART telemetry
- [ ] Full flight-controller integration
- [ ] Ground testing
- [ ] Flight testing

## Repository Structure

```text
fpga-quadcopter/
│
├── README.md
├── LICENSE
│
├── rtl/
│   ├── fpga_quadcopter.vhd
│   └── pwm.vhd
│
├── simulation/
│   └── pwm_tb.vhd
│
├── constraints/
├── docs/
├── hardware/
└── images/


### 2️⃣ Current FPGA Design → PWM Verification

```markdown
## Current FPGA Design

The current VHDL design implements a simple clock divider/counter.

The 50 MHz onboard clock is counted and the LED state is toggled every 25,000,000 clock cycles, producing a visible blinking signal.

This first design is used as a hardware verification step before implementing the more complex flight-controller modules.

## PWM Generator

The PWM generator is implemented as a reusable VHDL module.

The design uses a 50 MHz clock and generates a 50 Hz PWM signal with a 20 ms period.

The pulse width is configurable from 1000 μs to 2000 μs.

Typical values used during simulation:

- 1000 μs
- 1500 μs
- 2000 μs

The PWM module uses generic parameters for the clock frequency and PWM period, allowing the same RTL module to be reused with different FPGA clock frequencies.

### 4-Channel PWM

A four-channel PWM controller was developed using structural VHDL.

The existing `pwm` module is instantiated four times to generate four independent PWM outputs:

- PWM Channel 1
- PWM Channel 2
- PWM Channel 3
- PWM Channel 4

The four channels are intended to provide independent control signals for the four ESCs of the quadcopter..

## PWM Verification

The PWM generator was first verified using ModelSim.

The simulation confirmed:

- 1000 μs pulse width
- 1500 μs pulse width
- 2000 μs pulse width
- 20 ms PWM period
- 50 Hz PWM frequency

The 4-channel PWM controller was then verified using a dedicated ModelSim testbench.

The simulation confirmed four independent PWM outputs with different pulse widths.

The 4-channel design was also compiled using Quartus Prime and programmed onto the DSD-i1 development board.

Hardware testing confirmed the operation of all four PWM outputs.

The PWM outputs were assigned to the following DSD-i1 FPGA pins:

- `PWM1 → PIN_110`
- `PWM2 → PIN_111`
- `PWM3 → PIN_112`
- `PWM4 → PIN_113`

The 1500 μs pulse width and 20 ms period were measured using ModelSim waveform cursors.

## FPGA Pin Assignments

The current hardware test uses the following DSD-i1 FPGA pins:

| Signal | FPGA Pin | Function |
|--------|----------|----------|
| `clk`  | `PIN_23` | 50 MHz onboard clock |
| `pwm_out_1` | `PIN_110` | PWM Channel 1 |
| `pwm_out_2` | `PIN_111` | PWM Channel 2 |
| `pwm_out_3` | `PIN_112` | PWM Channel 3 |
| `pwm_out_4` | `PIN_113` | PWM Channel 4 |

I/O standard:

- 3.3-V LVCMOS
I/O standard:

- 3.3-V LVCMOS

## Technologies

- VHDL
- Structural VHDL
- Intel/Altera FPGA
- Cyclone IV E
- MAX 10
- Quartus Prime
- ModelSim
- Digital Logic Design
- SPI
- PWM
- UART
- PID Control
- FPGA-based Control Systems
- Hardware Verification

## Safety

Motor and ESC testing will initially be performed without propellers.

Flight-control development will be verified through simulation and controlled hardware testing before any flight testing.

## Author

**Spyros Plakoutsis**

GitHub: [@spyros3160](https://github.com/spyros3160)
