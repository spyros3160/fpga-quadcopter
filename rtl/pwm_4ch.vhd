library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity pwm_4ch is

    generic (
        CLK_FREQ_HZ   : integer := 50000000;
        PWM_PERIOD_US : integer := 20000
    );

    Port (
        clk : in std_logic;

        pulse_width_1 : in integer range 1000 to 2000;
        pulse_width_2 : in integer range 1000 to 2000;
        pulse_width_3 : in integer range 1000 to 2000;
        pulse_width_4 : in integer range 1000 to 2000;

        pwm_out_1 : out std_logic;
        pwm_out_2 : out std_logic;
        pwm_out_3 : out std_logic;
        pwm_out_4 : out std_logic
    );

end entity pwm_4ch;

architecture rtl of pwm_4ch is

    -- Number of clock cycles in one microsecond
    constant TICKS_PER_US : integer := CLK_FREQ_HZ / 1000000;

    -- Number of clock cycles in one complete PWM period
    constant PERIOD_TICKS : integer :=
        TICKS_PER_US * PWM_PERIOD_US;

    -- Common counter for all four PWM channels
    signal counter : integer range 0 to PERIOD_TICKS - 1 := 0;

begin

    -- PWM period counter
    process(clk)
    begin
        if rising_edge(clk) then

            if counter = PERIOD_TICKS - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;

        end if;
    end process;


    -- PWM Channel 1
    pwm_out_1 <= '1'
                 when counter < pulse_width_1 * TICKS_PER_US
                 else '0';


    -- PWM Channel 2
    pwm_out_2 <= '1'
                 when counter < pulse_width_2 * TICKS_PER_US
                 else '0';


    -- PWM Channel 3
    pwm_out_3 <= '1'
                 when counter < pulse_width_3 * TICKS_PER_US
                 else '0';


    -- PWM Channel 4
    pwm_out_4 <= '1'
                 when counter < pulse_width_4 * TICKS_PER_US
                 else '0';

end architecture rtl;