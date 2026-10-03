library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity accel_tilt_estimator_tb is
end entity accel_tilt_estimator_tb;

architecture sim of accel_tilt_estimator_tb is
    signal clk : std_logic := '0';
    signal data_valid : std_logic := '0';
    signal accel_x_g : signed(23 downto 0) := (others => '0');
    signal accel_y_g : signed(23 downto 0) := (others => '0');
    signal accel_z_g : signed(23 downto 0) := (others => '0');
    signal accel_roll_deg : signed(23 downto 0);
    signal accel_pitch_deg : signed(23 downto 0);
    signal angle_valid : std_logic;
begin
    clk <= not clk after 10 ns;

    DUT : entity work.accel_tilt_estimator
        port map (
            clk => clk,
            data_valid => data_valid,
            accel_x_g => accel_x_g,
            accel_y_g => accel_y_g,
            accel_z_g => accel_z_g,
            accel_roll_deg => accel_roll_deg,
            accel_pitch_deg => accel_pitch_deg,
            angle_valid => angle_valid
        );

    process
        variable roll_value : integer;
        variable pitch_value : integer;
    begin
        accel_x_g <= to_signed(0, 24);
        accel_y_g <= to_signed(0, 24);
        accel_z_g <= to_signed(256, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;

        assert angle_valid = '1'
            report "ERROR: angle_valid was not asserted!"
            severity error;
        roll_value := to_integer(accel_roll_deg);
        pitch_value := to_integer(accel_pitch_deg);
        assert roll_value = 0
            report "ERROR: Level Roll is not 0°!"
            severity error;
        assert pitch_value = 0
            report "ERROR: Level Pitch is not 0°!"
            severity error;
        report "SUCCESS: Level position -> Roll 0°, Pitch 0°"
            severity note;
        wait for 20 ns;

        accel_x_g <= to_signed(0, 24);
        accel_y_g <= to_signed(181, 24);
        accel_z_g <= to_signed(181, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        roll_value := to_integer(accel_roll_deg);
        assert roll_value = 11520
            report "ERROR: +45° Roll calculation failed!"
            severity error;
        report "SUCCESS: +45° Roll"
            severity note;
        wait for 20 ns;

        accel_x_g <= to_signed(0, 24);
        accel_y_g <= to_signed(-181, 24);
        accel_z_g <= to_signed(181, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        roll_value := to_integer(accel_roll_deg);
        assert roll_value = -11520
            report "ERROR: -45° Roll calculation failed!"
            severity error;
        report "SUCCESS: -45° Roll"
            severity note;
        wait for 20 ns;

        accel_x_g <= to_signed(-181, 24);
        accel_y_g <= to_signed(0, 24);
        accel_z_g <= to_signed(181, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        pitch_value := to_integer(accel_pitch_deg);
        assert pitch_value = 11520
            report "ERROR: +45° Pitch calculation failed!"
            severity error;
        report "SUCCESS: +45° Pitch"
            severity note;
        wait for 20 ns;

        accel_x_g <= to_signed(181, 24);
        accel_y_g <= to_signed(0, 24);
        accel_z_g <= to_signed(181, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        pitch_value := to_integer(accel_pitch_deg);
        assert pitch_value = -11520
            report "ERROR: -45° Pitch calculation failed!"
            severity error;
        report "SUCCESS: -45° Pitch"
            severity note;
        wait for 20 ns;

        accel_x_g <= to_signed(-256, 24);
        accel_y_g <= to_signed(0, 24);
        accel_z_g <= to_signed(0, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        pitch_value := to_integer(accel_pitch_deg);
        assert pitch_value = 23040
            report "ERROR: +90° Pitch calculation failed!"
            severity error;
        report "SUCCESS: +90° Pitch"
            severity note;
        wait for 20 ns;

        accel_x_g <= to_signed(256, 24);
        accel_y_g <= to_signed(0, 24);
        accel_z_g <= to_signed(0, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        pitch_value := to_integer(accel_pitch_deg);
        assert pitch_value = -23040
            report "ERROR: -90° Pitch calculation failed!"
            severity error;
        report "SUCCESS: -90° Pitch"
            severity note;
        wait for 20 ns;

        data_valid <= '0';
        wait for 20 ns;
        assert angle_valid = '0'
            report "ERROR: angle_valid should be LOW without data_valid!"
            severity error;
        report "SUCCESS: angle_valid timing"
            severity note;

        report "SUCCESS: All accelerometer tilt estimator tests completed."
            severity note;
        wait;
    end process;
end architecture sim;
