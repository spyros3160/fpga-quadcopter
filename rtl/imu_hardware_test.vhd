library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity imu_hardware_test is

    port (
        clk : in std_logic;

        led : out std_logic;

        sclk : out std_logic;
        mosi : out std_logic;
        miso : in std_logic;
        cs   : out std_logic
    );

end entity imu_hardware_test;


architecture rtl of imu_hardware_test is

    signal init_start : std_logic := '0';

    signal initialization_done : std_logic;

    signal imu_ok : std_logic;

    signal start_counter : integer range 0 to 99999999 := 0;


begin


    ----------------------------------------------------------------
    -- IMU initialization controller
    ----------------------------------------------------------------

    IMU_INIT : entity work.imu_init

        port map (

            clk                 => clk,

            start               => init_start,

            initialization_done => initialization_done,

            imu_ok              => imu_ok,

            sclk                => sclk,

            mosi                => mosi,

            miso                => miso,

            cs                  => cs

        );


    ----------------------------------------------------------------
    -- Generate a periodic initialization start pulse
    --
    -- 50 MHz clock
    -- 100,000,000 cycles = 2 seconds
    ----------------------------------------------------------------

    process(clk)

    begin

        if rising_edge(clk) then

            init_start <= '0';

            if start_counter = 99999999 then

                init_start <= '1';

                start_counter <= 0;

            else

                start_counter <= start_counter + 1;

            end if;

        end if;

    end process;


    ----------------------------------------------------------------
    -- Hardware indication
    --
    -- LED is ON when WHO_AM_I verification succeeds.
    ----------------------------------------------------------------

    led <= imu_ok;


end architecture imu_hardware_test;
