library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity imu_init is

    port (
        clk : in std_logic;

        -- Start IMU initialization
        start : in std_logic;

        -- Initialization completed successfully
        initialization_done : out std_logic;

        -- WHO_AM_I verification result
        imu_ok : out std_logic;

        -- SPI interface
        sclk : out std_logic;
        mosi : out std_logic;
        miso : in std_logic;
        cs   : out std_logic
    );

end entity imu_init;


architecture rtl of imu_init is


    ----------------------------------------------------------------
    -- IMU Controller interface
    ----------------------------------------------------------------

    signal controller_start : std_logic := '0';

    signal write_enable : std_logic := '0';

    signal register_address : std_logic_vector(7 downto 0)
        := (others => '0');

    signal write_data : std_logic_vector(7 downto 0)
        := (others => '0');

    signal register_data : std_logic_vector(7 downto 0);

    signal controller_done : std_logic;


    ----------------------------------------------------------------
    -- Initialization state machine
    ----------------------------------------------------------------

    type state_type is (
        IDLE,
        READ_WHO_AM_I,
        WAIT_WHO_AM_I,
        WRITE_PWR_MGMT0,
        WAIT_PWR_MGMT0,
        WAIT_200US,
        WRITE_ACCEL_CONFIG,
        WAIT_ACCEL_CONFIG,
        WRITE_GYRO_CONFIG,
        WAIT_GYRO_CONFIG,
        WAIT_GYRO_STARTUP,
        COMPLETE,
        ERROR
    );

    signal state : state_type := IDLE;


    ----------------------------------------------------------------
    -- Delay counter
    --
    -- 50 MHz clock
    -- 1 clock = 20 ns
    --
    -- 200 us = 10,000 clock cycles
    -- 30 ms  = 1,500,000 clock cycles
    ----------------------------------------------------------------

    signal delay_counter : integer range 0 to 1499999 := 0;


begin


    ----------------------------------------------------------------
    -- IMU Controller
    ----------------------------------------------------------------

    IMU_CONTROLLER : entity work.imu_controller

        port map (

            clk              => clk,

            start            => controller_start,

            write_enable     => write_enable,

            register_address => register_address,

            write_data       => write_data,

            register_data    => register_data,

            done             => controller_done,

            sclk             => sclk,

            mosi             => mosi,

            miso             => miso,

            cs               => cs

        );


    ----------------------------------------------------------------
    -- Initialization state machine
    ----------------------------------------------------------------

    process(clk)

    begin

        if rising_edge(clk) then

            --------------------------------------------------------
            -- Default values
            --------------------------------------------------------

            controller_start <= '0';


            case state is

                ----------------------------------------------------
                -- IDLE
                ----------------------------------------------------

                when IDLE =>

                    initialization_done <= '0';
                    imu_ok <= '0';

                    if start = '1' then

                        state <= READ_WHO_AM_I;

                    end if;


                ----------------------------------------------------
                -- READ WHO_AM_I
                ----------------------------------------------------

                when READ_WHO_AM_I =>

                    register_address <= x"75";

                    write_enable <= '0';

                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_WHO_AM_I;


                ----------------------------------------------------
                -- WAIT FOR WHO_AM_I READ
                ----------------------------------------------------

                when WAIT_WHO_AM_I =>

                    if controller_done = '1' then

                        if register_data = x"47" then

                            imu_ok <= '1';

                            state <= WRITE_PWR_MGMT0;

                        else

                            imu_ok <= '0';

                            state <= ERROR;

                        end if;

                    end if;


                ----------------------------------------------------
                -- WRITE PWR_MGMT0
                ----------------------------------------------------

                when WRITE_PWR_MGMT0 =>

                    register_address <= x"4E";

                    write_enable <= '1';

                    write_data <= x"0F";

                    controller_start <= '1';

                    state <= WAIT_PWR_MGMT0;


                ----------------------------------------------------
                -- WAIT FOR WRITE TO COMPLETE
                ----------------------------------------------------

                when WAIT_PWR_MGMT0 =>

                    if controller_done = '1' then

                        delay_counter <= 0;

                        state <= WAIT_200US;

                    end if;


                ----------------------------------------------------
                -- WAIT 200 us
                ----------------------------------------------------

                when WAIT_200US =>

                    if delay_counter = 9999 then

                        state <= WRITE_ACCEL_CONFIG;

                    else

                        delay_counter <= delay_counter + 1;

                    end if;


                ----------------------------------------------------
                -- WRITE ACCEL_CONFIG0
                --
                -- 0x50 = ACCEL_CONFIG0
                -- 0x26 = ±8 g, 1 kHz
                ----------------------------------------------------

                when WRITE_ACCEL_CONFIG =>

                    register_address <= x"50";

                    write_enable <= '1';

                    write_data <= x"26";

                    controller_start <= '1';

                    state <= WAIT_ACCEL_CONFIG;


                ----------------------------------------------------
                -- WAIT FOR ACCEL_CONFIG0 WRITE
                ----------------------------------------------------

                when WAIT_ACCEL_CONFIG =>

                    if controller_done = '1' then

                        state <= WRITE_GYRO_CONFIG;

                    end if;


                ----------------------------------------------------
                -- WRITE GYRO_CONFIG0
                --
                -- 0x4F = GYRO_CONFIG0
                -- 0x06 = ±2000 dps, 1 kHz
                ----------------------------------------------------

                when WRITE_GYRO_CONFIG =>

                    register_address <= x"4F";

                    write_enable <= '1';

                    write_data <= x"06";

                    controller_start <= '1';

                    state <= WAIT_GYRO_CONFIG;


                ----------------------------------------------------
                -- WAIT FOR GYRO_CONFIG0 WRITE
                ----------------------------------------------------

                when WAIT_GYRO_CONFIG =>

                    if controller_done = '1' then

                        delay_counter <= 0;

                        state <= WAIT_GYRO_STARTUP;

                    end if;


                ----------------------------------------------------
                -- WAIT FOR GYROSCOPE STARTUP
                --
                -- 30 ms at 50 MHz
                -- = 1,500,000 clock cycles
                ----------------------------------------------------

                when WAIT_GYRO_STARTUP =>

                    if delay_counter = 1499999 then

                        state <= COMPLETE;

                    else

                        delay_counter <= delay_counter + 1;

                    end if;


                ----------------------------------------------------
                -- INITIALIZATION COMPLETE
                ----------------------------------------------------

                when COMPLETE =>

                    initialization_done <= '1';

                    state <= COMPLETE;


                ----------------------------------------------------
                -- ERROR
                ----------------------------------------------------

                when ERROR =>

                    initialization_done <= '0';

                    state <= ERROR;


            end case;

        end if;

    end process;


end architecture rtl;
