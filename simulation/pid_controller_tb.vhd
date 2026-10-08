library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pid_controller_tb is
end entity pid_controller_tb;

architecture sim of pid_controller_tb is

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal data_valid : std_logic := '0';

    signal setpoint : signed(23 downto 0) := (others => '0');
    signal measurement : signed(23 downto 0) := (others => '0');

    signal control_output : signed(23 downto 0);
    signal output_valid : std_logic;

    constant CLK_PERIOD : time := 20 ns;

begin

    ----------------------------------------------------------------
    -- 50 MHz clock
    ----------------------------------------------------------------

    clk <= not clk after CLK_PERIOD / 2;


    ----------------------------------------------------------------
    -- Device Under Test
    ----------------------------------------------------------------

    DUT : entity work.pid_controller
        generic map (
            KP => 256,
            KI => 10,
            KD => 50
        )
        port map (
            clk => clk,
            reset => reset,
            data_valid => data_valid,

            setpoint => setpoint,
            measurement => measurement,

            control_output => control_output,
            output_valid => output_valid
        );


    ----------------------------------------------------------------
    -- Test process
    ----------------------------------------------------------------

    process
        variable output_value : integer;
    begin

        ------------------------------------------------------------
        -- TEST 1
        -- Zero error
        ------------------------------------------------------------

        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        setpoint <= to_signed(0, 24);
        measurement <= to_signed(0, 24);

        data_valid <= '1';

        wait until rising_edge(clk);

        data_valid <= '0';

        wait until output_valid = '1';

        -- Allow output register to update
        wait for 1 ns;

        output_value := to_integer(control_output);

        report "TEST 1: Error = 0 degrees, output = "
            & integer'image(output_value)
            severity note;

        assert output_value = 0
            report "ERROR: TEST 1 failed. Expected output = 0."
            severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- TEST 2
        -- +10 degree error
        ------------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        setpoint <= to_signed(10 * 256, 24);
        measurement <= to_signed(0, 24);

        data_valid <= '1';

        wait until rising_edge(clk);

        data_valid <= '0';

        wait until output_valid = '1';

        -- Allow output register to update
        wait for 1 ns;

        output_value := to_integer(control_output);

        report "TEST 2: Error = +10 degrees, output = "
            & integer'image(output_value)
            severity note;

        assert output_value = 3160
            report "ERROR: TEST 2 failed. Expected output = 3160."
            severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- TEST 3
        -- -10 degree error
        ------------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        setpoint <= to_signed(0, 24);
        measurement <= to_signed(10 * 256, 24);

        data_valid <= '1';

        wait until rising_edge(clk);

        data_valid <= '0';

        wait until output_valid = '1';

        -- Allow output register to update
        wait for 1 ns;

        output_value := to_integer(control_output);

        report "TEST 3: Error = -10 degrees, output = "
            & integer'image(output_value)
            severity note;

        assert output_value = -3160
            report "ERROR: TEST 3 failed. Expected output = -3160."
            severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- TEST 4
        -- +2 degree error
        ------------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        setpoint <= to_signed(10 * 256, 24);
        measurement <= to_signed(8 * 256, 24);

        data_valid <= '1';

        wait until rising_edge(clk);

        data_valid <= '0';

        wait until output_valid = '1';

        -- Allow output register to update
        wait for 1 ns;

        output_value := to_integer(control_output);

        report "TEST 4: Error = +2 degrees, output = "
            & integer'image(output_value)
            severity note;

        assert output_value = 632
            report "ERROR: TEST 4 failed. Expected output = 632."
            severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- TEST 5
        -- Zero error after reset
        ------------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        setpoint <= to_signed(10 * 256, 24);
        measurement <= to_signed(10 * 256, 24);

        data_valid <= '1';

        wait until rising_edge(clk);

        data_valid <= '0';

        wait until output_valid = '1';

        -- Allow output register to update
        wait for 1 ns;

        output_value := to_integer(control_output);

        report "TEST 5: Error = 0 degrees at +10 degrees, output = "
            & integer'image(output_value)
            severity note;

        assert output_value = 0
            report "ERROR: TEST 5 failed. Expected output = 0."
            severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- FINAL RESULT
        ------------------------------------------------------------

        report "SUCCESS: All PID controller tests passed."
            severity note;

        wait;

    end process;

end architecture sim;