library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpga_quadcopter is
    port (
        clk : in  std_logic;   -- 50 MHz system clock
        led : out std_logic    -- Status LED
    );
end entity fpga_quadcopter;

architecture rtl of fpga_quadcopter is

-- Counter used to generate a visible LED blinking frequency
signal counter : integer range 0 to 24999999 := 0;

-- Current state of the LED
signal led_state : std_logic := '0';

begin

process(clk)
begin
    if rising_edge(clk) then

        -- Toggle LED every 25,000,000 clock cycles
        if counter = 24999999 then
            counter <= 0;
            led_state <= not led_state;
        else
            counter <= counter + 1;
        end if;

    end if;
end process;

led <= led_state;

end architecture rtl;
