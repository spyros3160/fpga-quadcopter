library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imu_processing_top is
    port (
        clk : in std_logic;
        start : in std_logic;
        roll_deg  : out signed(23 downto 0);
        pitch_deg : out signed(23 downto 0);
        attitude_valid : out std_logic;
        sclk : out std_logic;
        mosi : out std_logic;
        miso : in std_logic;
        cs   : out std_logic
    );
end entity imu_processing_top;

architecture rtl of imu_processing_top is
    signal reader_start : std_logic := '0';

    signal accel_x_raw : signed(15 downto 0);
    signal accel_y_raw : signed(15 downto 0);
    signal accel_z_raw : signed(15 downto 0);
    signal gyro_x_raw : signed(15 downto 0);
    signal gyro_y_raw : signed(15 downto 0);
    signal gyro_z_raw : signed(15 downto 0);
    signal reader_data_valid : std_logic;

    signal accel_x_g : signed(23 downto 0);
    signal accel_y_g : signed(23 downto 0);
    signal accel_z_g : signed(23 downto 0);
    signal gyro_x_dps : signed(23 downto 0);
    signal gyro_y_dps : signed(23 downto 0);
    signal gyro_z_dps : signed(23 downto 0);
    signal processed_valid : std_logic;

    signal accel_roll_deg : signed(23 downto 0);
    signal accel_pitch_deg : signed(23 downto 0);
    signal angle_valid : std_logic;
begin
    IMU_READER : entity work.imu_sensor_reader
        port map (
            clk => clk,
            start => start,
            accel_x => accel_x_raw,
            accel_y => accel_y_raw,
            accel_z => accel_z_raw,
            gyro_x => gyro_x_raw,
            gyro_y => gyro_y_raw,
            gyro_z => gyro_z_raw,
            data_valid => reader_data_valid,
            sclk => sclk,
            mosi => mosi,
            miso => miso,
            cs => cs
        );

    SENSOR_PROCESSOR : entity work.sensor_processor
        port map (
            clk => clk,
            data_valid => reader_data_valid,
            accel_x_raw => accel_x_raw,
            accel_y_raw => accel_y_raw,
            accel_z_raw => accel_z_raw,
            gyro_x_raw => gyro_x_raw,
            gyro_y_raw => gyro_y_raw,
            gyro_z_raw => gyro_z_raw,
            accel_x_g => accel_x_g,
            accel_y_g => accel_y_g,
            accel_z_g => accel_z_g,
            gyro_x_dps => gyro_x_dps,
            gyro_y_dps => gyro_y_dps,
            gyro_z_dps => gyro_z_dps,
            processed_valid => processed_valid
        );

    ACCEL_TILT : entity work.accel_tilt_estimator
        port map (
            clk => clk,
            data_valid => processed_valid,
            accel_x_g => accel_x_g,
            accel_y_g => accel_y_g,
            accel_z_g => accel_z_g,
            accel_roll_deg => accel_roll_deg,
            accel_pitch_deg => accel_pitch_deg,
            angle_valid => angle_valid
        );

    ATTITUDE : entity work.attitude_estimator
        port map (
            clk => clk,
            data_valid => angle_valid,
            accel_roll_deg => accel_roll_deg,
            accel_pitch_deg => accel_pitch_deg,
            gyro_x_dps => gyro_x_dps,
            gyro_y_dps => gyro_y_dps,
            roll_deg => roll_deg,
            pitch_deg => pitch_deg,
            attitude_valid => attitude_valid
        );
end architecture rtl;
