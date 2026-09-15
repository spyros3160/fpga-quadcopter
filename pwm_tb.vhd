library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity pwm_tb is
end entity pwm_tb;


architecture sim of pwm_tb is

    -- Testbench clock
    signal clk : std_logic := '0';

    -- PWM pulse width to be tested
    signal pulse_width : integer range 1000 to 2000 := 1500;

    -- PWM output from the DUT
    signal pwm_out : std_logic;


begin

    -- Clock generation: 50 MHz
    clk <= not clk after 10 ns;


    -- Device Under Test (PWM module)
    DUT : entity work.pwm
        generic map (
            CLK_FREQ_HZ   => 50000000,
            PWM_PERIOD_US => 20000
        )
        port map (
            clk         => clk,
            pulse_width => pulse_width,
            pwm_out     => pwm_out
        );


    -- Test sequence
    process
    begin

        -- Test 1: 1500 us pulse
        pulse_width <= 1500;
        wait for 25 ms;


        -- Test 2: 1000 us pulse
        pulse_width <= 1000;
        wait for 25 ms;


        -- Test 3: 2000 us pulse
        pulse_width <= 2000;
        wait for 25 ms;


        -- End simulation
        wait;

    end process;

end architecture sim;