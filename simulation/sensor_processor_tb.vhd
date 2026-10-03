library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sensor_processor_tb is
end entity sensor_processor_tb;

architecture sim of sensor_processor_tb is

    signal clk : std_logic := '0';
    signal data_valid : std_logic := '0';

    signal accel_x_raw : signed(15 downto 0) := (others => '0');
    signal accel_y_raw : signed(15 downto 0) := (others => '0');
    signal accel_z_raw : signed(15 downto 0) := (others => '0');

    signal gyro_x_raw : signed(15 downto 0) := (others => '0');
    signal gyro_y_raw : signed(15 downto 0) := (others => '0');
    signal gyro_z_raw : signed(15 downto 0) := (others => '0');

    signal accel_x_g : signed(23 downto 0);
    signal accel_y_g : signed(23 downto 0);
    signal accel_z_g : signed(23 downto 0);

    signal gyro_x_dps : signed(23 downto 0);
    signal gyro_y_dps : signed(23 downto 0);
    signal gyro_z_dps : signed(23 downto 0);

    signal processed_valid : std_logic;

begin

    clk <= not clk after 10 ns;

    DUT : entity work.sensor_processor
        port map (
            clk => clk,
            data_valid => data_valid,

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

    process
        variable expected : integer;
    begin

        ----------------------------------------------------------------
        -- Test 1: 1 g on Z axis
        -- 4096 LSB = 1 g
        -- Q16.8: 1 g = 256
        ----------------------------------------------------------------

        accel_x_raw <= to_signed(0, 16);
        accel_y_raw <= to_signed(0, 16);
        accel_z_raw <= to_signed(4096, 16);

        gyro_x_raw <= to_signed(0, 16);
        gyro_y_raw <= to_signed(0, 16);
        gyro_z_raw <= to_signed(0, 16);

        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';

        wait for 1 ns;

        assert processed_valid = '1'
            report "ERROR: processed_valid was not asserted!"
            severity error;

        assert to_integer(accel_z_g) = 256
            report "ERROR: Accelerometer Z conversion failed!"
            severity error;

        report "SUCCESS: 1 g -> Q16.8 = 256"
            severity note;

        wait for 20 ns;

        ----------------------------------------------------------------
        -- Test 2: -2 g on X
        -- -8192 LSB = -2 g
        -- Q16.8: -2 g = -512
        ----------------------------------------------------------------

        accel_x_raw <= to_signed(-8192, 16);
        accel_y_raw <= to_signed(0, 16);
        accel_z_raw <= to_signed(0, 16);

        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';

        wait for 1 ns;

        assert to_integer(accel_x_g) = -512
            report "ERROR: Negative accelerometer conversion failed!"
            severity error;

        report "SUCCESS: -2 g -> Q16.8 = -512"
            severity note;

        wait for 20 ns;

        ----------------------------------------------------------------
        -- Test 3: 16.4 dps on gyro X
        -- 16.4 LSB = 1 dps
        -- Therefore 164 LSB = 10 dps
        -- Q16.8: 10 dps = 2560
        ----------------------------------------------------------------

        gyro_x_raw <= to_signed(164, 16);
        data_valid <= '1';

        wait for 20 ns;
        data_valid <= '0';

        wait for 1 ns;

        assert to_integer(gyro_x_dps) = 2560
            report "ERROR: Gyroscope conversion failed!"
            severity error;

        report "SUCCESS: 10 dps -> Q16.8 = 2560"
            severity note;

        wait for 20 ns;

        ----------------------------------------------------------------
        -- Test 4: negative gyro value
        ----------------------------------------------------------------

        gyro_x_raw <= to_signed(-820, 16);
        data_valid <= '1';

        wait for 20 ns;
        data_valid <= '0';

        wait for 1 ns;

        -- -820 / 16.4 = -50 dps
        -- Q16.8 = -12800
        assert to_integer(gyro_x_dps) = -12800
            report "ERROR: Negative gyroscope conversion failed!"
            severity error;

        report "SUCCESS: -50 dps -> Q16.8 = -12800"
            severity note;

        wait for 20 ns;

        report "SUCCESS: All sensor processor tests completed."
            severity note;

        wait;

    end process;

end architecture sim;
