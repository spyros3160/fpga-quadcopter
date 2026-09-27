library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity imu_controller_tb is
end entity imu_controller_tb;


architecture sim of imu_controller_tb is

    ----------------------------------------------------------------
    -- FPGA clock
    ----------------------------------------------------------------

    signal clk : std_logic := '0';


    ----------------------------------------------------------------
    -- IMU Controller interface
    ----------------------------------------------------------------

    signal start : std_logic := '0';

    signal write_enable : std_logic := '0';

    signal write_data : std_logic_vector(7 downto 0)
        := (others => '0');

    signal register_address : std_logic_vector(7 downto 0)
        := (others => '0');

    signal register_data : std_logic_vector(7 downto 0);

    signal done : std_logic;


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

    constant WHO_AM_I_DATA : std_logic_vector(7 downto 0)
        := x"47";

    constant IMU_RESPONSE : std_logic_vector(15 downto 0)
        := x"0047";

    signal imu_bit : integer range 0 to 15 := 0;

    signal address_received : std_logic_vector(7 downto 0)
        := (others => '0');

    signal tx_received : std_logic_vector(15 downto 0)
        := (others => '0');


begin

    ----------------------------------------------------------------
    -- 50 MHz FPGA clock
    ----------------------------------------------------------------

    clk <= not clk after 10 ns;


    ----------------------------------------------------------------
    -- Device Under Test
    ----------------------------------------------------------------

    DUT : entity work.imu_controller

        port map (
            clk              => clk,

            start            => start,

            write_enable     => write_enable,

            register_address => register_address,

            write_data       => write_data,

            register_data    => register_data,

            done             => done,

            sclk             => sclk,

            mosi             => mosi,

            miso             => miso,

            cs               => cs
        );


    ----------------------------------------------------------------
    -- Test sequence
    ----------------------------------------------------------------

    process
    begin

        ------------------------------------------------------------
        -- TEST 1
        -- READ WHO_AM_I
        ------------------------------------------------------------

        register_address <= x"75";

        write_enable <= '0';

        write_data <= x"00";

        wait for 100 ns;


        ------------------------------------------------------------
        -- Start READ transaction
        ------------------------------------------------------------

        start <= '1';

        wait for 20 ns;

        start <= '0';


        ------------------------------------------------------------
        -- Wait for transaction to complete
        ------------------------------------------------------------

        wait until done = '1';


        ------------------------------------------------------------
        -- Check WHO_AM_I
        ------------------------------------------------------------

        assert register_data = WHO_AM_I_DATA

            report "ERROR: WHO_AM_I value is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- Check READ address
        ------------------------------------------------------------

        assert address_received = x"F5"

            report "ERROR: SPI read address is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- READ successful
        ------------------------------------------------------------

        report "SUCCESS: WHO_AM_I READ completed correctly."

            severity note;


        ------------------------------------------------------------
        -- Wait before WRITE test
        ------------------------------------------------------------

        wait for 100 ns;


        ------------------------------------------------------------
        -- TEST 2
        -- WRITE PWR_MGMT0
        ------------------------------------------------------------

        register_address <= x"4E";

        write_enable <= '1';

        write_data <= x"0F";


        ------------------------------------------------------------
        -- Start WRITE transaction
        ------------------------------------------------------------

        start <= '1';

        wait for 20 ns;

        start <= '0';


        ------------------------------------------------------------
        -- Wait for transaction to complete
        ------------------------------------------------------------

        wait until done = '1';


        ------------------------------------------------------------
        -- Check WRITE transaction
        ------------------------------------------------------------

        assert tx_received = x"4E0F"

            report "ERROR: SPI write transaction is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- WRITE successful
        ------------------------------------------------------------

        report "SUCCESS: PWR_MGMT0 WRITE completed correctly."

            severity note;


        ------------------------------------------------------------
        -- All tests completed
        ------------------------------------------------------------

        report "SUCCESS: All IMU controller tests completed."

            severity note;


        wait for 100 ns;

        wait;

    end process;


    ----------------------------------------------------------------
    -- Virtual ICM-42688-P
    --
    -- SPI Mode 0
    ----------------------------------------------------------------

    process(cs, sclk)
    begin

        ------------------------------------------------------------
        -- Start of SPI transaction
        ------------------------------------------------------------

        if falling_edge(cs) then

            imu_bit <= 0;

            miso <= IMU_RESPONSE(15);


        ------------------------------------------------------------
        -- Rising edge of SCLK
        ------------------------------------------------------------

        elsif rising_edge(sclk) then

            if cs = '0' then

                tx_received <=
                    tx_received(14 downto 0) & mosi;

            end if;


        ------------------------------------------------------------
        -- Falling edge of SCLK
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
    -- Extract first transmitted byte
    ----------------------------------------------------------------

    address_received <= tx_received(15 downto 8);


end architecture sim;
