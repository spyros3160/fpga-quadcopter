library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity attitude_estimator_tb is
end entity attitude_estimator_tb;

architecture sim of attitude_estimator_tb is
    signal clk : std_logic := '0';
    signal data_valid : std_logic := '0';
    signal accel_roll_deg : signed(23 downto 0) := (others => '0');
    signal accel_pitch_deg : signed(23 downto 0) := (others => '0');
    signal gyro_x_dps : signed(23 downto 0) := (others => '0');
    signal gyro_y_dps : signed(23 downto 0) := (others => '0');
    signal roll_deg : signed(23 downto 0);
    signal pitch_deg : signed(23 downto 0);
    signal attitude_valid : std_logic;
begin
    clk <= not clk after 10 ns;

    DUT : entity work.attitude_estimator
        port map (
            clk => clk,
            data_valid => data_valid,
            accel_roll_deg => accel_roll_deg,
            accel_pitch_deg => accel_pitch_deg,
            gyro_x_dps => gyro_x_dps,
            gyro_y_dps => gyro_y_dps,
            roll_deg => roll_deg,
            pitch_deg => pitch_deg,
            attitude_valid => attitude_valid
        );

    process
        variable roll_value : integer;
        variable pitch_value : integer;
        variable previous_roll : integer;
    begin
        accel_roll_deg <= to_signed(0, 24);
        accel_pitch_deg <= to_signed(0, 24);
        gyro_x_dps <= to_signed(0, 24);
        gyro_y_dps <= to_signed(0, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;

        assert attitude_valid = '1'
            report "ERROR: attitude_valid was not asserted!"
            severity error;
        assert to_integer(roll_deg) = 0
            report "ERROR: Initial roll is not zero!"
            severity error;
        assert to_integer(pitch_deg) = 0
            report "ERROR: Initial pitch is not zero!"
            severity error;
        report "SUCCESS: Initial attitude = Roll 0°, Pitch 0°"
            severity note;
        wait for 20 ns;

        gyro_x_dps <= to_signed(256000, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        roll_value := to_integer(roll_deg);
        assert roll_value = 251
            report "ERROR: Roll complementary filter result incorrect!"
            severity error;
        report "SUCCESS: Gyro integration + complementary filter"
            severity note;
        wait for 20 ns;

        gyro_x_dps <= to_signed(0, 24);
        accel_roll_deg <= to_signed(2560, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        roll_value := to_integer(roll_deg);
        assert roll_value > 251
            report "ERROR: Roll did not move toward accelerometer angle!"
            severity error;
        assert roll_value < 2560
            report "ERROR: Roll exceeded accelerometer angle!"
            severity error;
        report "SUCCESS: Roll moves toward accelerometer estimate"
            severity note;
        wait for 20 ns;

        accel_pitch_deg <= to_signed(1280, 24);
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        pitch_value := to_integer(pitch_deg);
        assert pitch_value > 0
            report "ERROR: Pitch did not respond!"
            severity error;
        assert pitch_value < 1280
            report "ERROR: Pitch exceeded accelerometer angle!"
            severity error;
        report "SUCCESS: Pitch complementary filter response"
            severity note;
        wait for 20 ns;

        accel_roll_deg <= to_signed(-2560, 24);
        previous_roll := to_integer(roll_deg);

        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        roll_value := to_integer(roll_deg);
        assert roll_value < previous_roll
            report "ERROR: Roll did not move toward negative angle!"
            severity error;
        previous_roll := roll_value;

        wait for 20 ns;
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        roll_value := to_integer(roll_deg);
        assert roll_value < previous_roll
            report "ERROR: Roll did not continue toward negative angle!"
            severity error;
        previous_roll := roll_value;

        wait for 20 ns;
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        roll_value := to_integer(roll_deg);
        assert roll_value < previous_roll
            report "ERROR: Roll convergence failed!"
            severity error;
        previous_roll := roll_value;

        wait for 20 ns;
        data_valid <= '1';
        wait for 20 ns;
        data_valid <= '0';
        wait for 1 ns;
        roll_value := to_integer(roll_deg);
        assert roll_value < previous_roll
            report "ERROR: Roll convergence failed!"
            severity error;
        report "SUCCESS: Negative roll convergence"
            severity note;
        wait for 20 ns;

        for i in 1 to 20 loop
            data_valid <= '1';
            wait for 20 ns;
            data_valid <= '0';
            wait for 1 ns;
        end loop;

        roll_value := to_integer(roll_deg);
        assert roll_value < 0
            report "ERROR: Roll did not eventually cross zero!"
            severity error;
        assert roll_value > -2560
            report "ERROR: Roll overshot the -10° target!"
            severity error;
        report "SUCCESS: Roll converged through zero toward -10°"
            severity note;

        report "SUCCESS: All attitude estimator tests completed."
            severity note;
        wait;
    end process;
end architecture sim;
