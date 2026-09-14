library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pwm is
    generic (
        CLK_FREQ_HZ  : integer := 50000000;
        PWM_PERIOD_US : integer := 20000
    );

    Port (
        clk         : in  std_logic;
        pulse_width : in  integer range 1000 to 2000;
        pwm_out     : out std_logic
    );
end entity pwm;


architecture rtl of pwm is

    -- Number of clock cycles in one microsecond
    constant TICKS_PER_US : integer := CLK_FREQ_HZ / 1000000;

    -- Number of clock cycles in one complete PWM period
    constant PERIOD_TICKS : integer := TICKS_PER_US * PWM_PERIOD_US;

    signal counter : integer range 0 to PERIOD_TICKS - 1 := 0;

begin

    process(clk)
    begin
        if rising_edge(clk) then

            -- Restart counter at the end of the PWM period
            if counter = PERIOD_TICKS - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;

        end if;
    end process;


    -- Generate the PWM pulse
    pwm_out <= '1'
               when counter < pulse_width * TICKS_PER_US
               else '0';

end architecture rtl;