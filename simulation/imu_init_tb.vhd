library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity imu_init_tb is
end entity imu_init_tb;


architecture sim of imu_init_tb is


    ----------------------------------------------------------------
    -- FPGA clock
    ----------------------------------------------------------------

    signal clk : std_logic := '0';


    ----------------------------------------------------------------
    -- IMU initialization interface
    ----------------------------------------------------------------

    signal start : std_logic := '0';

    signal initialization_done : std_logic;

    signal imu_ok : std_logic;


    ----------------------------------------------------------------
    -- SPI signals
    ----------------------------------------------------------------

    signal sclk : std_logic;

    signal mosi : std_logic;

    signal miso : std_logic := '0';

    signal cs : std_logic;


    ----------------------------------------------------------------
    -- Virtual ICM-42688-P
    ----------------------------------------------------------------

    constant IMU_RESPONSE : std_logic_vector(15 downto 0)
        := x"0047";


    ----------------------------------------------------------------
    -- SPI data transmitted by FPGA
    ----------------------------------------------------------------

    signal tx_received : std_logic_vector(15 downto 0)
        := (others => '0');


    ----------------------------------------------------------------
    -- SPI bit counter
    ----------------------------------------------------------------

    signal imu_bit : integer range 0 to 15 := 0;


    ----------------------------------------------------------------
    -- SPI transaction counter
    --
    -- 0 = WHO_AM_I
    -- 1 = PWR_MGMT0
    -- 2 = ACCEL_CONFIG0
    -- 3 = GYRO_CONFIG0
    ----------------------------------------------------------------

    signal transaction_count : integer range 0 to 4 := 0;


begin


    ----------------------------------------------------------------
    -- 50 MHz FPGA clock
    --
    -- Period = 20 ns
    ----------------------------------------------------------------

    clk <= not clk after 10 ns;


    ----------------------------------------------------------------
    -- Device Under Test
    ----------------------------------------------------------------

    DUT : entity work.imu_init

        port map (

            clk => clk,

            start => start,

            initialization_done => initialization_done,

            imu_ok => imu_ok,

            sclk => sclk,

            mosi => mosi,

            miso => miso,

            cs => cs

        );


    ----------------------------------------------------------------
    -- Test sequence
    ----------------------------------------------------------------

    process
    begin

        ------------------------------------------------------------
        -- Wait for simulation to stabilize
        ------------------------------------------------------------

        wait for 100 ns;


        ------------------------------------------------------------
        -- Start IMU initialization
        ------------------------------------------------------------

        report "Starting IMU initialization..."
            severity note;

        start <= '1';

        wait for 20 ns;

        start <= '0';


        ------------------------------------------------------------
        -- Wait until initialization is completed
        ------------------------------------------------------------

        wait until initialization_done = '1';


        ------------------------------------------------------------
        -- Check WHO_AM_I verification
        ------------------------------------------------------------

        assert imu_ok = '1'

            report "ERROR: WHO_AM_I verification failed!"

            severity error;


        ------------------------------------------------------------
        -- Initialization successful
        ------------------------------------------------------------

        report "SUCCESS: IMU initialization completed."

            severity note;


        ------------------------------------------------------------
        -- End simulation
        ------------------------------------------------------------

        wait for 100 ns;


        report "SUCCESS: All IMU initialization tests completed."

            severity note;


        wait;

    end process;


    ----------------------------------------------------------------
    -- Virtual ICM-42688-P SPI slave
    --
    -- SPI Mode 0
    --
    -- WHO_AM_I response:
    --
    -- 0x47
    ----------------------------------------------------------------

    process(cs, sclk)
    begin

        ------------------------------------------------------------
        -- Start of SPI transaction
        ------------------------------------------------------------

        if falling_edge(cs) then

            imu_bit <= 0;

            tx_received <= (others => '0');

            miso <= IMU_RESPONSE(15);


        ------------------------------------------------------------
        -- Rising edge of SCLK
        --
        -- FPGA transmits MOSI data here.
        ------------------------------------------------------------

        elsif rising_edge(sclk) then

            if cs = '0' then

                tx_received <=
                    tx_received(14 downto 0) & mosi;

            end if;


        ------------------------------------------------------------
        -- Falling edge of SCLK
        --
        -- SPI Mode 0:
        -- Slave changes MISO on falling edge.
        ------------------------------------------------------------

        elsif falling_edge(sclk) then

            if cs = '0' then

                if imu_bit < 15 then

                    imu_bit <= imu_bit + 1;

                    miso <=
                        IMU_RESPONSE(14 - imu_bit);

                end if;

            end if;

        end if;

    end process;


    ----------------------------------------------------------------
    -- SPI transaction verification
    --
    -- Separate process for rising edge of CS.
    ----------------------------------------------------------------

    process(cs)
    begin

        if rising_edge(cs) then

            case transaction_count is

                ----------------------------------------------------
                -- Transaction 1
                -- READ WHO_AM_I
                -- Expected: F5 00
                ----------------------------------------------------

                when 0 =>

                    assert tx_received = x"F500"

                        report
                        "ERROR: WHO_AM_I SPI transaction incorrect!"

                        severity error;


                    report
                    "SUCCESS: WHO_AM_I transaction = 0xF500"

                        severity note;


                ----------------------------------------------------
                -- Transaction 2
                -- WRITE PWR_MGMT0
                -- Expected: 4E 0F
                ----------------------------------------------------

                when 1 =>

                    assert tx_received = x"4E0F"

                        report
                        "ERROR: PWR_MGMT0 SPI transaction incorrect!"

                        severity error;


                    report
                    "SUCCESS: PWR_MGMT0 transaction = 0x4E0F"

                        severity note;


                ----------------------------------------------------
                -- Transaction 3
                -- WRITE ACCEL_CONFIG0
                -- Expected: 50 26
                ----------------------------------------------------

                when 2 =>

                    assert tx_received = x"5026"

                        report
                        "ERROR: ACCEL_CONFIG0 SPI transaction incorrect!"

                        severity error;


                    report
                    "SUCCESS: ACCEL_CONFIG0 transaction = 0x5026"

                        severity note;


                ----------------------------------------------------
                -- Transaction 4
                -- WRITE GYRO_CONFIG0
                -- Expected: 4F 06
                ----------------------------------------------------

                when 3 =>

                    assert tx_received = x"4F06"

                        report
                        "ERROR: GYRO_CONFIG0 SPI transaction incorrect!"

                        severity error;


                    report
                    "SUCCESS: GYRO_CONFIG0 transaction = 0x4F06"

                        severity note;


                ----------------------------------------------------
                -- Any additional transaction
                ----------------------------------------------------

                when others =>

                    null;

            end case;


            --------------------------------------------------------
            -- Move to next transaction
            --------------------------------------------------------

            if transaction_count < 4 then

                transaction_count <=
                    transaction_count + 1;

            end if;

        end if;

    end process;


end architecture sim;
