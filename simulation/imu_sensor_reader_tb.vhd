library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity imu_sensor_reader_tb is
end entity imu_sensor_reader_tb;


architecture sim of imu_sensor_reader_tb is

    signal clk : std_logic := '0';
    signal start : std_logic := '0';

    signal accel_x : signed(15 downto 0);
    signal accel_y : signed(15 downto 0);
    signal accel_z : signed(15 downto 0);

    signal gyro_x : signed(15 downto 0);
    signal gyro_y : signed(15 downto 0);
    signal gyro_z : signed(15 downto 0);

    signal data_valid : std_logic;

    signal sclk : std_logic;
    signal mosi : std_logic;
    signal miso : std_logic := '0';
    signal cs   : std_logic;


    -- ============================================================
    -- Virtual ICM-42688-P register values
    -- ============================================================

    -- Accelerometer X = 0x1234
    constant ACCEL_X_HIGH : std_logic_vector(7 downto 0)
        := x"12";

    constant ACCEL_X_LOW : std_logic_vector(7 downto 0)
        := x"34";


    -- Accelerometer Y = 0x5678
    constant ACCEL_Y_HIGH : std_logic_vector(7 downto 0)
        := x"56";

    constant ACCEL_Y_LOW : std_logic_vector(7 downto 0)
        := x"78";


    -- Accelerometer Z = 0x1357
    constant ACCEL_Z_HIGH : std_logic_vector(7 downto 0)
        := x"13";

    constant ACCEL_Z_LOW : std_logic_vector(7 downto 0)
        := x"57";


    -- Gyroscope X = 0x2468
    constant GYRO_X_HIGH : std_logic_vector(7 downto 0)
        := x"24";

    constant GYRO_X_LOW : std_logic_vector(7 downto 0)
        := x"68";


    -- Gyroscope Y = 0x369A
    constant GYRO_Y_HIGH : std_logic_vector(7 downto 0)
        := x"36";

    constant GYRO_Y_LOW : std_logic_vector(7 downto 0)
        := x"9A";


    -- Gyroscope Z = 0x48AC
    constant GYRO_Z_HIGH : std_logic_vector(7 downto 0)
        := x"48";

    constant GYRO_Z_LOW : std_logic_vector(7 downto 0)
        := x"AC";


    -- ============================================================
    -- Virtual SPI slave
    -- ============================================================

    signal bit_count : integer range 0 to 16 := 0;

    signal command_byte : std_logic_vector(7 downto 0)
        := (others => '0');

    signal response_byte : std_logic_vector(7 downto 0)
        := (others => '0');


begin


    -- ============================================================
    -- 50 MHz FPGA clock
    -- ============================================================

    clk <= not clk after 10 ns;


    -- ============================================================
    -- Device Under Test
    -- ============================================================

    DUT : entity work.imu_sensor_reader

        port map (
            clk        => clk,
            start      => start,

            accel_x    => accel_x,
            accel_y    => accel_y,
            accel_z    => accel_z,

            gyro_x     => gyro_x,
            gyro_y     => gyro_y,
            gyro_z     => gyro_z,

            data_valid => data_valid,

            sclk       => sclk,
            mosi       => mosi,
            miso       => miso,
            cs         => cs
        );


    -- ============================================================
    -- Test sequence
    -- ============================================================

    process
    begin

        report "Starting 6-axis IMU sensor reader test..."
            severity note;


        -- --------------------------------------------------------
        -- Start reading all sensor data
        -- --------------------------------------------------------

        wait for 100 ns;

        start <= '1';

        wait for 20 ns;

        start <= '0';


        -- --------------------------------------------------------
        -- Wait until all six values are available
        -- --------------------------------------------------------

        wait until data_valid = '1';


        -- ========================================================
        -- Check Accelerometer X
        -- ========================================================

        assert accel_x = to_signed(16#1234#, 16)

            report "ERROR: Accelerometer X value is incorrect!"

            severity error;


        report "SUCCESS: Accelerometer X = 0x1234"
            severity note;


        -- ========================================================
        -- Check Accelerometer Y
        -- ========================================================

        assert accel_y = to_signed(16#5678#, 16)

            report "ERROR: Accelerometer Y value is incorrect!"

            severity error;


        report "SUCCESS: Accelerometer Y = 0x5678"
            severity note;


        -- ========================================================
        -- Check Accelerometer Z
        -- ========================================================

        assert accel_z = to_signed(16#1357#, 16)

            report "ERROR: Accelerometer Z value is incorrect!"

            severity error;


        report "SUCCESS: Accelerometer Z = 0x1357"
            severity note;


        -- ========================================================
        -- Check Gyroscope X
        -- ========================================================

        assert gyro_x = to_signed(16#2468#, 16)

            report "ERROR: Gyroscope X value is incorrect!"

            severity error;


        report "SUCCESS: Gyroscope X = 0x2468"
            severity note;


        -- ========================================================
        -- Check Gyroscope Y
        -- ========================================================

        assert gyro_y = to_signed(16#369A#, 16)

            report "ERROR: Gyroscope Y value is incorrect!"

            severity error;


        report "SUCCESS: Gyroscope Y = 0x369A"
            severity note;


        -- ========================================================
        -- Check Gyroscope Z
        -- ========================================================

        assert gyro_z = to_signed(16#48AC#, 16)

            report "ERROR: Gyroscope Z value is incorrect!"

            severity error;


        report "SUCCESS: Gyroscope Z = 0x48AC"
            severity note;


        -- ========================================================
        -- Final result
        -- ========================================================

        report "SUCCESS: All 6-axis IMU readings completed."
            severity note;


        wait for 100 ns;

        wait;

    end process;


    -- ============================================================
    -- Virtual ICM-42688-P SPI slave
    --
    -- SPI Mode 0:
    --
    -- Rising edge  -> master samples MISO
    -- Falling edge -> slave changes MISO
    --
    -- First 8 bits = register command
    -- Next 8 bits  = register data
    -- ============================================================

    process(cs, sclk)
    begin


        -- ========================================================
        -- Start of SPI transaction
        -- ========================================================

        if falling_edge(cs) then

            bit_count <= 0;

            command_byte <= (others => '0');

            response_byte <= (others => '0');

            miso <= '0';


        -- ========================================================
        -- Rising edge
        --
        -- FPGA samples MISO.
        -- Virtual IMU receives MOSI.
        -- ========================================================

        elsif rising_edge(sclk) then

            if cs = '0' then

                -- ------------------------------------------------
                -- Receive the first 8 bits = command
                -- ------------------------------------------------

                if bit_count < 8 then

                    command_byte <=
                        command_byte(6 downto 0) & mosi;

                end if;

                bit_count <= bit_count + 1;

            end if;


        -- ========================================================
        -- Falling edge
        --
        -- Virtual IMU changes MISO.
        -- ========================================================

        elsif falling_edge(sclk) then

            if cs = '0' then


                -- =================================================
                -- After receiving command byte
                -- select requested register
                -- =================================================

                if bit_count = 8 then

                    case command_byte is


                        -- =========================================
                        -- ACCEL X HIGH
                        -- Register 0x1F
                        -- SPI read command = 0x9F
                        -- =========================================

                        when x"9F" =>

                            response_byte <= ACCEL_X_HIGH;

                            miso <= ACCEL_X_HIGH(7);


                        -- =========================================
                        -- ACCEL X LOW
                        -- Register 0x20
                        -- SPI read command = 0xA0
                        -- =========================================

                        when x"A0" =>

                            response_byte <= ACCEL_X_LOW;

                            miso <= ACCEL_X_LOW(7);


                        -- =========================================
                        -- ACCEL Y HIGH
                        -- Register 0x21
                        -- SPI read command = 0xA1
                        -- =========================================

                        when x"A1" =>

                            response_byte <= ACCEL_Y_HIGH;

                            miso <= ACCEL_Y_HIGH(7);


                        -- =========================================
                        -- ACCEL Y LOW
                        -- Register 0x22
                        -- SPI read command = 0xA2
                        -- =========================================

                        when x"A2" =>

                            response_byte <= ACCEL_Y_LOW;

                            miso <= ACCEL_Y_LOW(7);


                        -- =========================================
                        -- ACCEL Z HIGH
                        -- Register 0x23
                        -- SPI read command = 0xA3
                        -- =========================================

                        when x"A3" =>

                            response_byte <= ACCEL_Z_HIGH;

                            miso <= ACCEL_Z_HIGH(7);


                        -- =========================================
                        -- ACCEL Z LOW
                        -- Register 0x24
                        -- SPI read command = 0xA4
                        -- =========================================

                        when x"A4" =>

                            response_byte <= ACCEL_Z_LOW;

                            miso <= ACCEL_Z_LOW(7);


                        -- =========================================
                        -- GYRO X HIGH
                        -- Register 0x25
                        -- SPI read command = 0xA5
                        -- =========================================

                        when x"A5" =>

                            response_byte <= GYRO_X_HIGH;

                            miso <= GYRO_X_HIGH(7);


                        -- =========================================
                        -- GYRO X LOW
                        -- Register 0x26
                        -- SPI read command = 0xA6
                        -- =========================================

                        when x"A6" =>

                            response_byte <= GYRO_X_LOW;

                            miso <= GYRO_X_LOW(7);


                        -- =========================================
                        -- GYRO Y HIGH
                        -- Register 0x27
                        -- SPI read command = 0xA7
                        -- =========================================

                        when x"A7" =>

                            response_byte <= GYRO_Y_HIGH;

                            miso <= GYRO_Y_HIGH(7);


                        -- =========================================
                        -- GYRO Y LOW
                        -- Register 0x28
                        -- SPI read command = 0xA8
                        -- =========================================

                        when x"A8" =>

                            response_byte <= GYRO_Y_LOW;

                            miso <= GYRO_Y_LOW(7);


                        -- =========================================
                        -- GYRO Z HIGH
                        -- Register 0x29
                        -- SPI read command = 0xA9
                        -- =========================================

                        when x"A9" =>

                            response_byte <= GYRO_Z_HIGH;

                            miso <= GYRO_Z_HIGH(7);


                        -- =========================================
                        -- GYRO Z LOW
                        -- Register 0x2A
                        -- SPI read command = 0xAA
                        -- =========================================

                        when x"AA" =>

                            response_byte <= GYRO_Z_LOW;

                            miso <= GYRO_Z_LOW(7);


                        -- =========================================
                        -- Unknown register
                        -- =========================================

                        when others =>

                            response_byte <= x"00";

                            miso <= '0';

                    end case;


                -- =================================================
                -- Send remaining response bits
                -- =================================================

                elsif bit_count = 9 then

                    miso <= response_byte(6);


                elsif bit_count = 10 then

                    miso <= response_byte(5);


                elsif bit_count = 11 then

                    miso <= response_byte(4);


                elsif bit_count = 12 then

                    miso <= response_byte(3);


                elsif bit_count = 13 then

                    miso <= response_byte(2);


                elsif bit_count = 14 then

                    miso <= response_byte(1);


                elsif bit_count = 15 then

                    miso <= response_byte(0);

                end if;

            end if;

        end if;

    end process;


end architecture sim;