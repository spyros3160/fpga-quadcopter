# FPGA Quadcopter 

An FPGA-based quadcopter flight controller developed in VHDL using an Altera Cyclone IV FPGA.

This project aims to implement the core flight-control logic of a quadcopter directly in programmable hardware, without using a conventional microcontroller as the flight controller.

## Project Status

🚧 **In development**

The project currently includes verified FPGA fundamentals, PWM generation, SPI communication, ICM-42688-P IMU initialization, 6-axis sensor processing, integrated attitude estimation and a verified PID controller module.

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

---
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


---

## Development Roadmap

```markdown
## Development Roadmap

### Phase 1 — FPGA Fundamentals

- [x] Quartus project creation
- [x] VHDL top-level entity
- [x] 50 MHz clock input
- [x] Counter implementation
- [x] LED output
- [x] FPGA pin assignments
- [x] Successful Quartus compilation
- [x] Hardware programming and LED test
- [x] PWM generator
- [x] PWM simulation and verification

### Phase 2 — Motor Control

- [x] Four independent PWM outputs
- [ ] ESC interface
- [ ] Bench testing with propellers removed

### Phase 3 — IMU Interface

- [x] SPI master
- [x] 16-bit SPI transactions
- [x] ICM-42688-P register read
- [x] ICM-42688-P register write
- [x] WHO_AM_I register verification
- [x] PWR_MGMT0 register write verification
- [x] IMU initialization
- [x] IMU initialization simulation
- [x] Accelerometer configuration
- [x] Gyroscope configuration
- [x] Gyro startup delay
- [x] Accelerometer data acquisition
- [x] Gyroscope data acquisition
- [x] Accelerometer data processing
- [x] Gyroscope data processing
- [x] Sensor processor ModelSim verification
- [x] Accelerometer tilt estimation
- [x] Attitude estimation and complementary filter verification
- [x] Integrated IMU processing chain ModelSim verification
- [ ] IMU hardware communication

### Phase 4 — Flight Control

- [x] Accelerometer tilt estimation
- [x] Complementary filter attitude estimation
- [ ] Attitude estimation hardware integration
- [x] PID controller module ModelSim verification
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

fpga-quadcopter/
│
├── README.md
├── LICENSE
│
├── rtl/
│   ├── fpga_quadcopter.vhd
│   ├── fpga_quadcopter_pwm.vhd
│   ├── pwm.vhd
│   ├── pwm_4ch.vhd
│   ├── spi_master.vhd
│   └── imu_controller.vhd
|   └── imu_init.vhd
|   └── imu_sensor_reader.vhd
|   └── imu_hardware_test.vhd
|   └── sensor_processor.vhd
|   └── accel_tilt_estimator.vhd
|   └── attitude_estimator.vhd
|   └── pid_controller.vhd
│
├── simulation/
│   ├── pwm_tb.vhd
│   ├── pwm_4ch_tb.vhd
│   ├── spi_master_tb.vhd
│   └── imu_controller_tb.vhd
│   └── imu_init_tb.vhd
|   └── imu_sensor_reader.tb.vhd
|   └── sensor_processor_tb.vhd
|   └── accel_tilt_estimator_tb.vhd
|   └── attitude_estimator_tb.vhd
|   └── pid_controller_tb.vhd
|
├── constraints/
├── docs/
├── hardware/
└── images/


---

## Current FPGA Design

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

The four channels are intended to provide independent control signals for the four ESCs of the quadcopter.

## IMU Controller

An IMU controller was implemented in VHDL to interface with the ICM-42688-P through the SPI Master.

The controller provides a register-level interface supporting both register READ and WRITE operations.

## IMU Initialization

An IMU initialization controller was implemented in VHDL for the ICM-42688-P.

The initialization sequence performs the following operations:

1. Read the `WHO_AM_I` register at address `0x75`
2. Verify that the returned value is `0x47`
3. Write `0x0F` to the `PWR_MGMT0` register at address `0x4E`
4. Wait 200 µs after enabling the sensor
5. Configure the accelerometer with `ACCEL_CONFIG0 = 0x26`
6. Configure the gyroscope with `GYRO_CONFIG0 = 0x06`
7. Wait for the gyroscope startup period
8. Assert the `initialization_done` signal

### Sensor Configuration

| Sensor | Configuration |
|---|---|
| Accelerometer | ±8 g |
| Accelerometer ODR | 1 kHz |
| Gyroscope | ±2000 dps |
| Gyroscope ODR | 1 kHz |

### Register Configuration

| Register | Address | Value | Function |
|---|---:|---:|---|
| WHO_AM_I | `0x75` | `0x47` | Device identification |
| PWR_MGMT0 | `0x4E` | `0x0F` | Enable accelerometer and gyroscope |
| ACCEL_CONFIG0 | `0x50` | `0x26` | ±8 g, 1 kHz |
| GYRO_CONFIG0 | `0x4F` | `0x06` | ±2000 dps, 1 kHz |

### ModelSim Verification

The complete initialization sequence was verified using a virtual ICM-42688-P SPI device.

Verified SPI transactions:

```text
WHO_AM_I      → F5 00
PWR_MGMT0     → 4E 0F
ACCEL_CONFIG0 → 50 26
GYRO_CONFIG0  → 4F 06
```

The simulation also verifies the required gyroscope startup delay before initialization is completed.

### Verification Status

- [x] WHO_AM_I verification
- [x] PWR_MGMT0 configuration
- [x] Accelerometer configuration
- [x] Gyroscope configuration
- [x] Gyroscope startup delay
- [x] Complete initialization simulation
- [ ] Physical IMU communication

## IMU Hardware Test

A dedicated hardware test top-level entity was added for physical ICM-42688-P validation.

The `imu_hardware_test` module connects the IMU initialization controller to external SPI signals:

- `SCLK`
- `MOSI`
- `MISO`
- `CS`

The `imu_ok` signal is connected to an FPGA LED. The LED is asserted when the ICM-42688-P `WHO_AM_I` register is successfully verified.

The module is intended as a hardware-validation wrapper and is kept separate from the reusable IMU RTL modules.

The current hardware test top-level does not yet include final board-specific SPI pin assignments. These will be added when the physical IMU and target development board are available.

### Hardware Test Status

- [x] Hardware test top-level
- [x] SPI signals exposed
- [x] `imu_ok` LED indication
- [ ] Physical ICM-42688-P connected
- [ ] Hardware SPI communication
- [ ] Hardware WHO_AM_I verification

## 6-Axis IMU Sensor Reader

A VHDL sensor reader was implemented for the ICM-42688-P to acquire raw 16-bit accelerometer and gyroscope data through the IMU controller.

The sensor reader acquires:

### Accelerometer

- Accelerometer X
- Accelerometer Y
- Accelerometer Z

### Gyroscope

- Gyroscope X
- Gyroscope Y
- Gyroscope Z

Each sensor axis is represented as a signed 16-bit value composed of a high byte and a low byte.

### Simulation

The complete 6-axis sensor acquisition was verified in ModelSim using a virtual ICM-42688-P SPI device.

The simulation verified:

- Accelerometer X acquisition
- Accelerometer Y acquisition
- Accelerometer Z acquisition
- Gyroscope X acquisition
- Gyroscope Y acquisition
- Gyroscope Z acquisition
- SPI register addressing
- 16-bit sensor data reconstruction
- `data_valid` generation

### Verification Status

- [x] Accelerometer X acquisition
- [x] Accelerometer Y acquisition
- [x] Accelerometer Z acquisition
- [x] Gyroscope X acquisition
- [x] Gyroscope Y acquisition
- [x] Gyroscope Z acquisition
- [x] 6-axis ModelSim verification
- [ ] Physical IMU communication
- [x] Sensor data processing

## Attitude Estimation

Two dedicated VHDL modules have been verified as the basis of the attitude-estimation chain.

### Accelerometer Tilt Estimator

The `accel_tilt_estimator` module calculates accelerometer-based roll and pitch angles from the processed accelerometer X/Y/Z values.

The implementation uses fixed-point arithmetic and FPGA-friendly approximations for `atan2` and vector magnitude.

Verified cases include:

- Level position: 0° roll / 0° pitch
- +45° roll
- -45° roll
- +45° pitch
- -45° pitch
- +90° pitch
- -90° pitch
- `angle_valid` timing

### Complementary Filter

The `attitude_estimator` module combines accelerometer tilt estimates with gyroscope angular-rate measurements.

The filter uses:

- Q16.8 sensor and output values
- Q16.16 internal attitude state
- 1 kHz sensor update rate
- 1 ms integration interval
- 98% gyroscope contribution
- 2% accelerometer contribution

The higher-precision internal Q16.16 representation preserves fractional information during gyroscope integration before conversion back to Q16.8 outputs.

ModelSim verification covers:

- Initial zero attitude
- Gyroscope integration
- Complementary filter response
- Roll response toward accelerometer estimate
- Pitch response
- Negative roll convergence
- Convergence through zero toward a negative target

Both the accelerometer tilt estimator and complementary-filter estimator passed Quartus compilation and ModelSim verification.

### Verification Status

- [x] Accelerometer tilt estimation
- [x] Accelerometer tilt ModelSim verification
- [x] Gyroscope integration
- [x] Complementary filter
- [x] Attitude estimator ModelSim verification
- [x] Integrated IMU processing chain ModelSim verification
- [ ] Physical IMU attitude estimation

## Sensor Processor

A dedicated VHDL sensor-processing module converts the raw 16-bit ICM-42688-P accelerometer and gyroscope measurements into fixed-point physical values.

The processor uses a Q16.8 fixed-point representation:

- 24-bit signed output
- 8 fractional bits
- 1.0 = 256

### Conversion

| Sensor | Configuration | Conversion |
|---|---|---|
| Accelerometer | ±8 g, 4096 LSB/g | raw / 16 |
| Gyroscope | ±2000 dps, 16.4 LSB/(dps) | raw × 640 / 41 |

The processor generates the three processed accelerometer axes, the three processed gyroscope axes, and a `processed_valid` signal.

### ModelSim Verification

The sensor processor was verified with a dedicated testbench.

Verified conversions:

```text
1 g       → Q16.8 = 256
-2 g      → Q16.8 = -512
10 dps    → Q16.8 = 2560
-50 dps   → Q16.8 = -12800
```

The Quartus compilation and ModelSim simulation completed successfully.

### Verification Status

- [x] Accelerometer conversion
- [x] Gyroscope conversion
- [x] Positive values
- [x] Negative values
- [x] processed_valid
- [x] ModelSim verification
- [ ] Physical IMU data processing


### Simulation

The complete ICM-42688-P initialization sequence was verified in ModelSim using a virtual SPI device.

The simulation verified:

- `WHO_AM_I` read and `0x47` verification
- `PWR_MGMT0 = 0x0F` write
- 200 µs delay after sensor enable
- `ACCEL_CONFIG0 = 0x26` write
- `GYRO_CONFIG0 = 0x06` write
- Gyroscope startup delay
- Initialization completion

Verified SPI transactions:

```text
F5 00
4E 0F
50 26
4F 06
```

The complete initialization sequence completed successfully in simulation.

### Verification Status

- [x] WHO_AM_I verification
- [x] PWR_MGMT0 configuration
- [x] 200 µs initialization delay
- [x] Accelerometer configuration
- [x] Gyroscope configuration
- [x] Gyroscope startup delay
- [x] Initialization state machine
- [x] ModelSim verification
- [ ] Physical IMU communication

### Supported Operations

- Register READ
- Register WRITE
- SPI Mode 0
- 16-bit SPI transactions
- MSB-first transmission

### Register Interface Verification

The controller was verified in ModelSim using a virtual ICM-42688-P device.

#### WHO_AM_I READ

- Register address: `0x75`
- Expected value: `0x47`
- SPI transaction: `0xF5 0x00`

The received value was verified as:

WHO_AM_I = 0x47

#### PWR_MGMT0 WRITE

- Register address: `0x4E`
- Test value: `0x0F`
- SPI transaction: `0x4E 0x0F`

Both register transactions completed successfully in ModelSim.

### Verification Status

- [x] Register READ
- [x] Register WRITE
- [x] WHO_AM_I verification
- [x] PWR_MGMT0 WRITE verification
- [ ] Physical IMU communication


---

## ΚΟΜΜΑΤΙ 8 — PWM Verification

```markdown
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
| `clk` | `PIN_23` | 50 MHz onboard clock |
| `pwm_out_1` | `PIN_110` | PWM Channel 1 |
| `pwm_out_2` | `PIN_111` | PWM Channel 2 |
| `pwm_out_3` | `PIN_112` | PWM Channel 3 |
| `pwm_out_4` | `PIN_113` | PWM Channel 4 |

I/O standard:

- 3.3-V LVCMOS

## SPI Master

Implemented a reusable 16-bit SPI Master in VHDL for communication with the ICM-42688-P IMU.

### Features

- SPI Mode 0
- 1 MHz SPI clock
- MSB-first transmission
- 16-bit SPI transactions
- Start/done control
- CS, SCLK, MOSI and MISO signals
- Generic FPGA clock and SPI clock frequency

### Verification

The SPI Master was simulated in ModelSim using a virtual SPI slave.

Verified:

- MOSI transmission
- MISO reception
- 16-bit SPI transfers
- CS control
- SPI clock generation
- Transfer completion

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


## Integrated IMU Processing Chain

The `imu_processing_top` module integrates the IMU processing path from SPI sensor acquisition through sensor conversion, accelerometer tilt estimation and complementary-filter attitude estimation.

### ModelSim Integration Test

The virtual ICM-42688-P test uses a static orientation of approximately +45 degrees roll:

- Accelerometer X = 0 g
- Accelerometer Y = approximately +0.707 g
- Accelerometer Z = approximately +0.707 g
- Gyroscope X/Y/Z = 0 dps

The test performs 200 complete IMU acquisitions and waits for `attitude_valid` after each acquisition.

### Result

The complete integration test passed:

```text
200 IMU samples processed
Final Roll  = 11296 Q16.8 = 44.125 degrees
Final Pitch = 0 Q16.8 = 0 degrees
+45 degree roll integration test passed
Complete IMU attitude chain verified
```

The expected roll range is 42 to 46 degrees, so the measured 44.125 degrees is within the verification limits.

### Verification Status

- [x] SPI to sensor-reader integration
- [x] Raw accelerometer and gyroscope processing
- [x] Accelerometer tilt estimation
- [x] Complementary-filter attitude estimation
- [x] 200-sample integrated ModelSim verification
- [x] +45 degree roll verification
- [ ] Physical ICM-42688-P communication
- [ ] Physical IMU attitude estimation


## Current IMU Integration Files

The current integrated IMU verification uses:

- `rtl/imu_processing_top.vhd` - top-level integration of the IMU processing chain
- `simulation/imu_processing_top_tb.vhd` - ModelSim integration testbench
- `rtl/imu_sensor_reader.vhd` - 6-axis raw sensor acquisition
- `rtl/sensor_processor.vhd` - fixed-point sensor conversion
- `rtl/accel_tilt_estimator.vhd` - accelerometer roll/pitch estimation
- `rtl/attitude_estimator.vhd` - complementary-filter attitude estimation


## PID Controller

A reusable PID controller was implemented in VHDL as the next flight-control building block after the verified IMU attitude-estimation chain.

The controller uses the existing Q16.8 fixed-point representation:

- 24-bit signed setpoint
- 24-bit signed measurement
- 24-bit signed control output
- 8 fractional bits
- 1.0 = 256

The controller implements:

- Proportional term
- Integral term
- Derivative term
- Error calculation: `setpoint - measurement`
- Reset of the internal integral and previous-error state
- 24-bit signed output limiting
- `data_valid` / `output_valid` handshake

### Initial Simulation Parameters

The first verification uses:

| Parameter | Value |
|---|---:|
| Kp | 256 |
| Ki | 10 |
| Kd | 50 |

These are initial simulation values and are not final flight-tuning parameters.

### ModelSim Verification

The dedicated `pid_controller_tb.vhd` testbench verifies independent PID responses after resetting the controller before each test.

Verified cases:

```text
Zero error at 0°       → output = 0
+10° error             → output = 3160
-10° error             → output = -3160
+2° error              → output = 632
Zero error at +10°     → output = 0
```

The testbench completed successfully with:

```text
SUCCESS: All PID controller tests passed.
```

The PID RTL also passed Quartus compilation before ModelSim verification.

### Verification Status

- [x] PID controller RTL
- [x] Quartus compilation
- [x] Positive error response
- [x] Negative error response
- [x] Small-error response
- [x] Integral/derivative state reset between verification cases
- [x] ModelSim verification
- [ ] Roll PID integration
- [ ] Pitch PID integration
- [ ] Yaw PID integration
- [ ] Motor mixer integration
