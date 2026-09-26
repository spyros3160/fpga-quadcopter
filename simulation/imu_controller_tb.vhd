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

    signal start            : std_logic := '0';

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

    -- WHO_AM_I register value
    constant WHO_AM_I_DATA : std_logic_vector(7 downto 0)
        := x"47";

    -- The complete 16-bit response from the IMU
    --
    -- First byte  = dummy
    -- Second byte = WHO_AM_I = 0x47
    constant IMU_RESPONSE : std_logic_vector(15 downto 0)
        := x"0047";

    -- Bit counter for the virtual IMU
    signal imu_bit : integer range 0 to 15 := 0;

    -- Address received from FPGA
    signal address_received : std_logic_vector(7 downto 0)
        := (others => '0');

    -- Stores the 16 bits transmitted by the FPGA
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

            register_address => register_address,

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
        -- Request WHO_AM_I register
        ------------------------------------------------------------

        register_address <= x"75";

        wait for 100 ns;


        ------------------------------------------------------------
        -- Start register read
        ------------------------------------------------------------

        start <= '1';

        wait for 20 ns;

        start <= '0';


        ------------------------------------------------------------
        -- Wait for SPI transaction to complete
        ------------------------------------------------------------

        wait until done = '1';


        ------------------------------------------------------------
        -- Check received WHO_AM_I value
        ------------------------------------------------------------

        assert register_data = WHO_AM_I_DATA

            report "ERROR: WHO_AM_I value is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- Check transmitted SPI address byte
        ------------------------------------------------------------

        assert address_received = x"F5"

            report "ERROR: SPI read address is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- Successful test
        ------------------------------------------------------------

        report "SUCCESS: ICM-42688-P WHO_AM_I read completed correctly."

            severity note;


        wait for 100 ns;

        wait;

    end process;


    ----------------------------------------------------------------
    -- Virtual ICM-42688-P
    --
    -- SPI Mode 0
    --
    -- Data changes on falling edge.
    -- FPGA samples data on rising edge.
    ----------------------------------------------------------------

    process(cs, sclk)
    begin

        ------------------------------------------------------------
        -- CS goes LOW
        -- Start of SPI transaction
        ------------------------------------------------------------

        if falling_edge(cs) then

            imu_bit <= 0;

            -- Send first bit of the 16-bit response
            miso <= IMU_RESPONSE(15);


        ------------------------------------------------------------
        -- Rising edge of SCLK
        --
        -- FPGA samples MISO.
        -- Virtual IMU samples MOSI.
        ------------------------------------------------------------

        elsif rising_edge(sclk) then

            if cs = '0' then

                -- Store transmitted MOSI bit
                tx_received <=
                    tx_received(14 downto 0) & mosi;

            end if;


        ------------------------------------------------------------
        -- Falling edge of SCLK
        --
        -- Prepare next MISO bit.
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
    -- Extract the first transmitted byte
    --
    -- After the complete 16-bit transfer:
    --
    -- tx_received = F5 00
    --
    -- The first byte is the SPI read address.
    ----------------------------------------------------------------

    address_received <= tx_received(15 downto 8);


end architecture sim;
