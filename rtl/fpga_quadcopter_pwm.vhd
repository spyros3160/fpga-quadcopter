library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity fpga_quadcopter_pwm is

    port (
        clk : in std_logic;

        pwm_out_1 : out std_logic;
        pwm_out_2 : out std_logic;
        pwm_out_3 : out std_logic;
        pwm_out_4 : out std_logic
    );

end entity fpga_quadcopter_pwm;

architecture structural of fpga_quadcopter_pwm is

    component pwm

        generic (
            CLK_FREQ_HZ   : integer := 50000000;
            PWM_PERIOD_US : integer := 20000
        );

        port (
            clk         : in std_logic;
            pulse_width : in integer range 1000 to 2000;
            pwm_out     : out std_logic
        );

    end component;

begin

       PWM_1 : pwm
        generic map (
            CLK_FREQ_HZ   => 50000000,
            PWM_PERIOD_US => 20000
        )
        port map (
            clk         => clk,
            pulse_width => 1000,
            pwm_out     => pwm_out_1
        );


    PWM_2 : pwm
        generic map (
            CLK_FREQ_HZ   => 50000000,
            PWM_PERIOD_US => 20000
        )
        port map (
            clk         => clk,
            pulse_width => 1250,
            pwm_out     => pwm_out_2
        );


    PWM_3 : pwm
        generic map (
            CLK_FREQ_HZ   => 50000000,
            PWM_PERIOD_US => 20000
        )
        port map (
            clk         => clk,
            pulse_width => 1500,
            pwm_out     => pwm_out_3
        );


    PWM_4 : pwm
        generic map (
            CLK_FREQ_HZ   => 50000000,
            PWM_PERIOD_US => 20000
        )
        port map (
            clk         => clk,
            pulse_width => 1750,
            pwm_out     => pwm_out_4
        );
		  
end architecture structural;