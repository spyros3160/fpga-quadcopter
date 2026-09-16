library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity pwm_4ch_tb is
end entity pwm_4ch_tb;


architecture sim of pwm_4ch_tb is

    -- Testbench clock
    signal clk : std_logic := '0';

    -- Pulse widths for the four PWM channels
    signal pulse_width_1 : integer range 1000 to 2000 := 1000;
    signal pulse_width_2 : integer range 1000 to 2000 := 1250;
    signal pulse_width_3 : integer range 1000 to 2000 := 1500;
    signal pulse_width_4 : integer range 1000 to 2000 := 1750;

    -- PWM outputs
    signal pwm_out_1 : std_logic;
    signal pwm_out_2 : std_logic;
    signal pwm_out_3 : std_logic;
    signal pwm_out_4 : std_logic;

begin


    -- 50 MHz clock
    clk <= not clk after 10 ns;


    -- Device Under Test
    DUT : entity work.pwm_4ch

        generic map (
            CLK_FREQ_HZ   => 50000000,
            PWM_PERIOD_US => 20000
        )

        port map (
            clk          => clk,

            pulse_width_1 => pulse_width_1,
            pulse_width_2 => pulse_width_2,
            pulse_width_3 => pulse_width_3,
            pulse_width_4 => pulse_width_4,

            pwm_out_1 => pwm_out_1,
            pwm_out_2 => pwm_out_2,
            pwm_out_3 => pwm_out_3,
            pwm_out_4 => pwm_out_4
        );


    -- Test sequence
    process
    begin

        -- Initial test values
        pulse_width_1 <= 1000;
        pulse_width_2 <= 1250;
        pulse_width_3 <= 1500;
        pulse_width_4 <= 1750;

        wait for 25 ms;


        -- Second test
        pulse_width_1 <= 1200;
        pulse_width_2 <= 1400;
        pulse_width_3 <= 1600;
        pulse_width_4 <= 1800;

        wait for 25 ms;


        -- Third test
        pulse_width_1 <= 1500;
        pulse_width_2 <= 1500;
        pulse_width_3 <= 1500;
        pulse_width_4 <= 1500;

        wait for 25 ms;


        -- End simulation
        wait;

    end process;

end architecture sim;