library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity motor_mixer_tb is
end entity motor_mixer_tb;

architecture sim of motor_mixer_tb is

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal data_valid : std_logic := '0';

    signal throttle_us : integer range 1000 to 2000 := 1500;

    signal roll_correction  : signed(23 downto 0) := (others => '0');
    signal pitch_correction : signed(23 downto 0) := (others => '0');
    signal yaw_correction   : signed(23 downto 0) := (others => '0');

    signal motor_1 : integer range 1000 to 2000;
    signal motor_2 : integer range 1000 to 2000;
    signal motor_3 : integer range 1000 to 2000;
    signal motor_4 : integer range 1000 to 2000;

    signal output_valid : std_logic;

    constant CLK_PERIOD : time := 20 ns;

begin

    clk <= not clk after CLK_PERIOD / 2;

    DUT : entity work.motor_mixer
        port map (
            clk => clk,
            reset => reset,
            data_valid => data_valid,
            throttle_us => throttle_us,
            roll_correction => roll_correction,
            pitch_correction => pitch_correction,
            yaw_correction => yaw_correction,
            motor_1 => motor_1,
            motor_2 => motor_2,
            motor_3 => motor_3,
            motor_4 => motor_4,
            output_valid => output_valid
        );

    process
    begin

        ------------------------------------------------------------
        -- TEST 1: Throttle only
        ------------------------------------------------------------

        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        throttle_us <= 1500;
        roll_correction  <= to_signed(0, 24);
        pitch_correction <= to_signed(0, 24);
        yaw_correction   <= to_signed(0, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 1: Throttle only" severity note;
        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1500 report "ERROR: TEST 1 M1 failed." severity error;
        assert motor_2 = 1500 report "ERROR: TEST 1 M2 failed." severity error;
        assert motor_3 = 1500 report "ERROR: TEST 1 M3 failed." severity error;
        assert motor_4 = 1500 report "ERROR: TEST 1 M4 failed." severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- TEST 2: Positive Roll correction
        ------------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        throttle_us <= 1500;
        roll_correction  <= to_signed(256, 24);
        pitch_correction <= to_signed(0, 24);
        yaw_correction   <= to_signed(0, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 2: Positive Roll correction" severity note;
        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1501 report "ERROR: TEST 2 M1 failed." severity error;
        assert motor_2 = 1499 report "ERROR: TEST 2 M2 failed." severity error;
        assert motor_3 = 1499 report "ERROR: TEST 2 M3 failed." severity error;
        assert motor_4 = 1501 report "ERROR: TEST 2 M4 failed." severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- TEST 3: Positive Pitch correction
        ------------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        throttle_us <= 1500;
        roll_correction  <= to_signed(0, 24);
        pitch_correction <= to_signed(256, 24);
        yaw_correction   <= to_signed(0, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 3: Positive Pitch correction" severity note;
        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1501 report "ERROR: TEST 3 M1 failed." severity error;
        assert motor_2 = 1501 report "ERROR: TEST 3 M2 failed." severity error;
        assert motor_3 = 1499 report "ERROR: TEST 3 M3 failed." severity error;
        assert motor_4 = 1499 report "ERROR: TEST 3 M4 failed." severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- TEST 4: Positive Yaw correction
        ------------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        throttle_us <= 1500;
        roll_correction  <= to_signed(0, 24);
        pitch_correction <= to_signed(0, 24);
        yaw_correction   <= to_signed(256, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 4: Positive Yaw correction" severity note;
        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 1499 report "ERROR: TEST 4 M1 failed." severity error;
        assert motor_2 = 1501 report "ERROR: TEST 4 M2 failed." severity error;
        assert motor_3 = 1499 report "ERROR: TEST 4 M3 failed." severity error;
        assert motor_4 = 1501 report "ERROR: TEST 4 M4 failed." severity error;

        wait until output_valid = '0';


        ------------------------------------------------------------
        -- TEST 5: Saturation
        ------------------------------------------------------------

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        throttle_us <= 1500;
        roll_correction  <= to_signed(128000, 24);
        pitch_correction <= to_signed(0, 24);
        yaw_correction   <= to_signed(0, 24);

        data_valid <= '1';
        wait until rising_edge(clk);
        data_valid <= '0';

        wait until output_valid = '1';
        wait for 1 ns;

        report "TEST 5: Saturation" severity note;
        report "M1 = " & integer'image(motor_1)
            & " M2 = " & integer'image(motor_2)
            & " M3 = " & integer'image(motor_3)
            & " M4 = " & integer'image(motor_4)
            severity note;

        assert motor_1 = 2000 report "ERROR: TEST 5 M1 saturation failed." severity error;
        assert motor_2 = 1000 report "ERROR: TEST 5 M2 saturation failed." severity error;
        assert motor_3 = 1000 report "ERROR: TEST 5 M3 saturation failed." severity error;
        assert motor_4 = 2000 report "ERROR: TEST 5 M4 saturation failed." severity error;

        wait until output_valid = '0';

        report "SUCCESS: All Motor Mixer tests passed." severity note;

        wait;

    end process;

end architecture sim;