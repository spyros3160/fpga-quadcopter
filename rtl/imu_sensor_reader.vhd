library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity imu_sensor_reader is

    port (
        clk : in std_logic;

        -- Start reading accelerometer and gyroscope
        start : in std_logic;

        -- Accelerometer X
        accel_x : out signed(15 downto 0);

        -- Accelerometer Y
        accel_y : out signed(15 downto 0);

        -- Accelerometer Z
        accel_z : out signed(15 downto 0);

        -- Gyroscope X
        gyro_x : out signed(15 downto 0);

        -- Gyroscope Y
        gyro_y : out signed(15 downto 0);

        -- Gyroscope Z
        gyro_z : out signed(15 downto 0);

        -- Indicates that new data is available
        data_valid : out std_logic;

        -- SPI interface
        sclk : out std_logic;
        mosi : out std_logic;
        miso : in std_logic;
        cs   : out std_logic
    );

end entity imu_sensor_reader;


architecture rtl of imu_sensor_reader is


    ----------------------------------------------------------------
    -- IMU controller signals
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
    -- Accelerometer X
    ----------------------------------------------------------------

    signal accel_x_high : std_logic_vector(7 downto 0)
        := (others => '0');

    signal accel_x_low : std_logic_vector(7 downto 0)
        := (others => '0');


    ----------------------------------------------------------------
    -- Accelerometer Y
    ----------------------------------------------------------------

    signal accel_y_high : std_logic_vector(7 downto 0)
        := (others => '0');

    signal accel_y_low : std_logic_vector(7 downto 0)
        := (others => '0');


    ----------------------------------------------------------------
    -- Accelerometer Z
    ----------------------------------------------------------------

    signal accel_z_high : std_logic_vector(7 downto 0)
        := (others => '0');

    signal accel_z_low : std_logic_vector(7 downto 0)
        := (others => '0');


    ----------------------------------------------------------------
    -- Gyroscope X
    ----------------------------------------------------------------

    signal gyro_x_high : std_logic_vector(7 downto 0)
        := (others => '0');

    signal gyro_x_low : std_logic_vector(7 downto 0)
        := (others => '0');


    ----------------------------------------------------------------
    -- Gyroscope Y
    ----------------------------------------------------------------

    signal gyro_y_high : std_logic_vector(7 downto 0)
        := (others => '0');

    signal gyro_y_low : std_logic_vector(7 downto 0)
        := (others => '0');


    ----------------------------------------------------------------
    -- Gyroscope Z
    ----------------------------------------------------------------

    signal gyro_z_high : std_logic_vector(7 downto 0)
        := (others => '0');

    signal gyro_z_low : std_logic_vector(7 downto 0)
        := (others => '0');


    ----------------------------------------------------------------
    -- State machine
    ----------------------------------------------------------------

    type state_type is (

        IDLE,

        READ_X_HIGH,
        WAIT_X_HIGH,

        READ_X_LOW,
        WAIT_X_LOW,

        READ_Y_HIGH,
        WAIT_Y_HIGH,

        READ_Y_LOW,
        WAIT_Y_LOW,

        READ_Z_HIGH,
        WAIT_Z_HIGH,

        READ_Z_LOW,
        WAIT_Z_LOW,

        READ_GYRO_X_HIGH,
        WAIT_GYRO_X_HIGH,

        READ_GYRO_X_LOW,
        WAIT_GYRO_X_LOW,

        READ_GYRO_Y_HIGH,
        WAIT_GYRO_Y_HIGH,

        READ_GYRO_Y_LOW,
        WAIT_GYRO_Y_LOW,

        READ_GYRO_Z_HIGH,
        WAIT_GYRO_Z_HIGH,

        READ_GYRO_Z_LOW,
        WAIT_GYRO_Z_LOW,

        COMPLETE,
        OUTPUT

    );

    signal state : state_type := IDLE;


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

            done              => controller_done,

            sclk             => sclk,

            mosi             => mosi,

            miso             => miso,

            cs               => cs

        );


    ----------------------------------------------------------------
    -- Sensor reader state machine
    ----------------------------------------------------------------

    process(clk)

    begin

        if rising_edge(clk) then

            --------------------------------------------------------
            -- Default values
            --------------------------------------------------------

            controller_start <= '0';

            data_valid <= '0';


            case state is


                ----------------------------------------------------
                -- IDLE
                ----------------------------------------------------

                when IDLE =>

                    if start = '1' then

                        state <= READ_X_HIGH;

                    end if;


                ----------------------------------------------------
                -- ACCELEROMETER X HIGH
                -- Register 0x1F
                ----------------------------------------------------

                when READ_X_HIGH =>

                    register_address <= x"1F";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_X_HIGH;


                when WAIT_X_HIGH =>

                    if controller_done = '1' then

                        accel_x_high <= register_data;

                        state <= READ_X_LOW;

                    end if;


                ----------------------------------------------------
                -- ACCELEROMETER X LOW
                -- Register 0x20
                ----------------------------------------------------

                when READ_X_LOW =>

                    register_address <= x"20";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_X_LOW;


                when WAIT_X_LOW =>

                    if controller_done = '1' then

                        accel_x_low <= register_data;

                        state <= READ_Y_HIGH;

                    end if;


                ----------------------------------------------------
                -- ACCELEROMETER Y HIGH
                -- Register 0x21
                ----------------------------------------------------

                when READ_Y_HIGH =>

                    register_address <= x"21";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_Y_HIGH;


                when WAIT_Y_HIGH =>

                    if controller_done = '1' then

                        accel_y_high <= register_data;

                        state <= READ_Y_LOW;

                    end if;


                ----------------------------------------------------
                -- ACCELEROMETER Y LOW
                -- Register 0x22
                ----------------------------------------------------

                when READ_Y_LOW =>

                    register_address <= x"22";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_Y_LOW;


                when WAIT_Y_LOW =>

                    if controller_done = '1' then

                        accel_y_low <= register_data;

                        state <= READ_Z_HIGH;

                    end if;


                ----------------------------------------------------
                -- ACCELEROMETER Z HIGH
                -- Register 0x23
                ----------------------------------------------------

                when READ_Z_HIGH =>

                    register_address <= x"23";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_Z_HIGH;


                when WAIT_Z_HIGH =>

                    if controller_done = '1' then

                        accel_z_high <= register_data;

                        state <= READ_Z_LOW;

                    end if;


                ----------------------------------------------------
                -- ACCELEROMETER Z LOW
                -- Register 0x24
                ----------------------------------------------------

                when READ_Z_LOW =>

                    register_address <= x"24";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_Z_LOW;


                when WAIT_Z_LOW =>

                    if controller_done = '1' then

                        accel_z_low <= register_data;

                        state <= READ_GYRO_X_HIGH;

                    end if;


                ----------------------------------------------------
                -- GYROSCOPE X HIGH
                -- Register 0x25
                ----------------------------------------------------

                when READ_GYRO_X_HIGH =>

                    register_address <= x"25";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_GYRO_X_HIGH;


                when WAIT_GYRO_X_HIGH =>

                    if controller_done = '1' then

                        gyro_x_high <= register_data;

                        state <= READ_GYRO_X_LOW;

                    end if;


                ----------------------------------------------------
                -- GYROSCOPE X LOW
                -- Register 0x26
                ----------------------------------------------------

                when READ_GYRO_X_LOW =>

                    register_address <= x"26";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_GYRO_X_LOW;


                when WAIT_GYRO_X_LOW =>

                    if controller_done = '1' then

                        gyro_x_low <= register_data;

                        state <= READ_GYRO_Y_HIGH;

                    end if;


                ----------------------------------------------------
                -- GYROSCOPE Y HIGH
                -- Register 0x27
                ----------------------------------------------------

                when READ_GYRO_Y_HIGH =>

                    register_address <= x"27";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_GYRO_Y_HIGH;


                when WAIT_GYRO_Y_HIGH =>

                    if controller_done = '1' then

                        gyro_y_high <= register_data;

                        state <= READ_GYRO_Y_LOW;

                    end if;


                ----------------------------------------------------
                -- GYROSCOPE Y LOW
                -- Register 0x28
                ----------------------------------------------------

                when READ_GYRO_Y_LOW =>

                    register_address <= x"28";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_GYRO_Y_LOW;


                when WAIT_GYRO_Y_LOW =>

                    if controller_done = '1' then

                        gyro_y_low <= register_data;

                        state <= READ_GYRO_Z_HIGH;

                    end if;


                ----------------------------------------------------
                -- GYROSCOPE Z HIGH
                -- Register 0x29
                ----------------------------------------------------

                when READ_GYRO_Z_HIGH =>

                    register_address <= x"29";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_GYRO_Z_HIGH;


                when WAIT_GYRO_Z_HIGH =>

                    if controller_done = '1' then

                        gyro_z_high <= register_data;

                        state <= READ_GYRO_Z_LOW;

                    end if;


                ----------------------------------------------------
                -- GYROSCOPE Z LOW
                -- Register 0x2A
                ----------------------------------------------------

                when READ_GYRO_Z_LOW =>

                    register_address <= x"2A";
                    write_enable <= '0';
                    write_data <= x"00";

                    controller_start <= '1';

                    state <= WAIT_GYRO_Z_LOW;


                when WAIT_GYRO_Z_LOW =>

                    if controller_done = '1' then

                        gyro_z_low <= register_data;

                        state <= COMPLETE;

                    end if;


                ----------------------------------------------------
                -- COMPLETE
                --
                -- The final gyro Z byte has now been captured.
                --
                -- We deliberately do NOT assert data_valid here.
                -- The next state presents the complete data set.
                ----------------------------------------------------

                when COMPLETE =>

                    state <= OUTPUT;


                ----------------------------------------------------
                -- OUTPUT
                --
                -- All six sensor values are now complete.
                --
                -- data_valid is asserted for exactly one clock.
                ----------------------------------------------------

                when OUTPUT =>

                    accel_x <= signed(
                        accel_x_high & accel_x_low
                    );

                    accel_y <= signed(
                        accel_y_high & accel_y_low
                    );

                    accel_z <= signed(
                        accel_z_high & accel_z_low
                    );

                    gyro_x <= signed(
                        gyro_x_high & gyro_x_low
                    );

                    gyro_y <= signed(
                        gyro_y_high & gyro_y_low
                    );

                    gyro_z <= signed(
                        gyro_z_high & gyro_z_low
                    );

                    data_valid <= '1';

                    state <= IDLE;


            end case;

        end if;

    end process;

end architecture rtl;
