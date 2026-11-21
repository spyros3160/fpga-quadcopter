library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pid_motor_control_tb is
end entity pid_motor_control_tb;

architecture sim of pid_motor_control_tb is

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal data_valid : std_logic := '0';

    signal roll_setpoint  : signed(23 downto 0) := (others => '0');
    signal pitch_setpoint : signed(23 downto 0) := (others => '0');
    signal yaw_setpoint   : signed(23 downto 0) := (others => '0');

    signal roll_measurement  : signed(23 downto 0) := (others => '0');
    signal pitch_measurement : signed(23 downto 0) := (others => '0');
    signal yaw_measurement   : signed(23 downto 0) := (others => '0');

    signal throttle_us : integer range 1000 to 2000 := 1500;

    signal motor_1 : integer range 1000 to 2000;
    signal motor_2 : integer range 1000 to 2000;
    signal motor_3 : integer range 1000 to 2000;
    signal motor_4 : integer range 1000 to 2000;

    signal output_valid : std_logic;

    constant CLK_PERIOD : time := 20 ns;

begin

    clk <= not clk after CLK_PERIOD / 2;


    ------------------------------------------------------------
    -- DUT
    ------------------------------------------------------------

    DUT : entity work.pid_motor_control
        port map (
            clk => clk,
            reset => reset,
            data_valid => data_valid,

            roll_setpoint => roll_setpoint,
            pitch_setpoint => pitch_setpoint,
            yaw_setpoint => yaw_setpoint,

            roll_measurement => roll_measurement,
            pitch_measurement => pitch_measurement,
            yaw_measurement => yaw_measurement,

            throttle_us => throttle_us,

            motor_1 => motor_1,
            motor_2 => motor_2,
            motor_3 => motor_3,
            motor_4 => motor_4,

            output_valid => output_valid
        );


    ------------------------------------------------------------
    -- TEST PROCESS
    ------------------------------------------------------------

    process
    begin

        --------------------------------------------------------
        -- TEST 1: ZERO ERROR
        --------------------------------------------------------

        reset <= '1';
        data_valid <= '0';

        wait for 100 ns;

        reset <= '0';

        roll_setpoint  <= to_signed(0, 24);
        pitch_setpoint <= to_signed(0, 24);
        yaw_setpoint   <= to_signed(0, 24);

        roll_measurement  <= to_signed(0, 24);
        pitch_measurement <= to_signed(0, 24);
        yaw_measurement   <= to_signed(0, 24);

        throttle_us <= 1500;

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 1: Zero error" severity note;

        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1500
            report "ERROR: TEST 1 M1 failed."
            severity error;

        assert motor_2 = 1500
            report "ERROR: TEST 1 M2 failed."
            severity error;

        assert motor_3 = 1500
            report "ERROR: TEST 1 M3 failed."
            severity error;

        assert motor_4 = 1500
            report "ERROR: TEST 1 M4 failed."
            severity error;


        --------------------------------------------------------
        -- TEST 2: ROLL
        --------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        roll_setpoint  <= to_signed(10 * 256, 24);
        pitch_setpoint <= to_signed(0, 24);
        yaw_setpoint   <= to_signed(0, 24);

        roll_measurement  <= to_signed(0, 24);
        pitch_measurement <= to_signed(0, 24);
        yaw_measurement   <= to_signed(0, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 2: Roll PID" severity note;

        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1512
            report "ERROR: TEST 2 M1 failed."
            severity error;

        assert motor_2 = 1488
            report "ERROR: TEST 2 M2 failed."
            severity error;

        assert motor_3 = 1488
            report "ERROR: TEST 2 M3 failed."
            severity error;

        assert motor_4 = 1512
            report "ERROR: TEST 2 M4 failed."
            severity error;


        --------------------------------------------------------
        -- TEST 3: PITCH
        --------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        roll_setpoint  <= to_signed(0, 24);
        pitch_setpoint <= to_signed(10 * 256, 24);
        yaw_setpoint   <= to_signed(0, 24);

        roll_measurement  <= to_signed(0, 24);
        pitch_measurement <= to_signed(0, 24);
        yaw_measurement   <= to_signed(0, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 3: Pitch PID" severity note;

        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1512
            report "ERROR: TEST 3 M1 failed."
            severity error;

        assert motor_2 = 1512
            report "ERROR: TEST 3 M2 failed."
            severity error;

        assert motor_3 = 1488
            report "ERROR: TEST 3 M3 failed."
            severity error;

        assert motor_4 = 1488
            report "ERROR: TEST 3 M4 failed."
            severity error;


        --------------------------------------------------------
        -- TEST 4: YAW
        --------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        roll_setpoint  <= to_signed(0, 24);
        pitch_setpoint <= to_signed(0, 24);
        yaw_setpoint   <= to_signed(10 * 256, 24);

        roll_measurement  <= to_signed(0, 24);
        pitch_measurement <= to_signed(0, 24);
        yaw_measurement   <= to_signed(0, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 4: Yaw PID" severity note;

        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1488
            report "ERROR: TEST 4 M1 failed."
            severity error;

        assert motor_2 = 1512
            report "ERROR: TEST 4 M2 failed."
            severity error;

        assert motor_3 = 1488
            report "ERROR: TEST 4 M3 failed."
            severity error;

        assert motor_4 = 1512
            report "ERROR: TEST 4 M4 failed."
            severity error;


        --------------------------------------------------------
        -- TEST 5: ALL THREE PID CONTROLLERS
        --------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        roll_setpoint  <= to_signed(10 * 256, 24);
        pitch_setpoint <= to_signed(10 * 256, 24);
        yaw_setpoint   <= to_signed(10 * 256, 24);

        roll_measurement  <= to_signed(0, 24);
        pitch_measurement <= to_signed(0, 24);
        yaw_measurement   <= to_signed(0, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 5: All three PID controllers"
            severity note;

        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1512
            report "ERROR: TEST 5 M1 failed."
            severity error;

        assert motor_2 = 1512
            report "ERROR: TEST 5 M2 failed."
            severity error;

        assert motor_3 = 1464
            report "ERROR: TEST 5 M3 failed."
            severity error;

        assert motor_4 = 1512
            report "ERROR: TEST 5 M4 failed."
            severity error;


        --------------------------------------------------------
        -- FINAL RESULT
        --------------------------------------------------------

        report "SUCCESS: PID to Motor Mixer integration passed."
            severity note;

        wait;

    end process;

end architecture sim;
