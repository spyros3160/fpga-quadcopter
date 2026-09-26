library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_master_tb is
end entity spi_master_tb;


architecture sim of spi_master_tb is

    ----------------------------------------------------------------
    -- FPGA clock
    ----------------------------------------------------------------

    signal clk : std_logic := '0';


    ----------------------------------------------------------------
    -- SPI Master internal interface
    ----------------------------------------------------------------

    signal start : std_logic := '0';

    signal tx_data : std_logic_vector(15 downto 0)
        := (others => '0');

    signal rx_data : std_logic_vector(15 downto 0);

    signal done : std_logic;


    ----------------------------------------------------------------
    -- SPI physical signals
    ----------------------------------------------------------------

    signal sclk : std_logic;

    signal mosi : std_logic;

    signal miso : std_logic := '0';

    signal cs : std_logic;


    ----------------------------------------------------------------
    -- Virtual SPI slave
    ----------------------------------------------------------------

    -- Expected data returned by the virtual IMU
    constant SLAVE_RESPONSE : std_logic_vector(15 downto 0)
        := x"0047";

    -- Store the data transmitted by the FPGA
    signal tx_received : std_logic_vector(15 downto 0)
        := (others => '0');

    -- Bit counter
    signal slave_bit : integer range 0 to 15 := 0;


begin

    ----------------------------------------------------------------
    -- 50 MHz FPGA clock
    ----------------------------------------------------------------

    clk <= not clk after 10 ns;


    ----------------------------------------------------------------
    -- Device Under Test
    ----------------------------------------------------------------

    DUT : entity work.spi_master

        generic map (
            CLK_FREQ_HZ => 50000000,
            SPI_FREQ_HZ => 1000000
        )

        port map (
            clk      => clk,

            start    => start,
            tx_data  => tx_data,

            rx_data  => rx_data,
            done     => done,

            sclk     => sclk,
            mosi     => mosi,
            miso     => miso,
            cs       => cs
        );


    ----------------------------------------------------------------
    -- Test sequence
    ----------------------------------------------------------------

    process
    begin

        ------------------------------------------------------------
        -- Data transmitted by FPGA
        --
        -- F5 = READ + register address 0x75
        -- 00 = dummy byte
        ------------------------------------------------------------

        tx_data <= x"F500";

        wait for 100 ns;


        ------------------------------------------------------------
        -- Start SPI transaction
        ------------------------------------------------------------

        start <= '1';

        wait for 20 ns;

        start <= '0';


        ------------------------------------------------------------
        -- Wait for transaction completion
        ------------------------------------------------------------

        wait until done = '1';


        ------------------------------------------------------------
        -- Check received data
        ------------------------------------------------------------

        assert rx_data = x"0047"

            report "ERROR: Received SPI data is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- Check transmitted data
        ------------------------------------------------------------

        assert tx_received = x"F500"

            report "ERROR: Transmitted SPI data is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- Successful test
        ------------------------------------------------------------

        report "SUCCESS: 16-bit SPI transfer completed correctly."

            severity note;


        wait for 100 ns;

        wait;

    end process;


    ----------------------------------------------------------------
    -- Virtual SPI Slave
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

            slave_bit <= 0;

            -- First bit of response
            miso <= SLAVE_RESPONSE(15);


        ------------------------------------------------------------
        -- Rising edge of SCLK
        --
        -- FPGA samples MISO.
        -- Virtual slave samples MOSI.
        ------------------------------------------------------------

        elsif rising_edge(sclk) then

            if cs = '0' then

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

                if slave_bit < 15 then

                    slave_bit <= slave_bit + 1;

                    miso <=
                        SLAVE_RESPONSE(14 - slave_bit);

                end if;

            end if;

        end if;

    end process;

end architecture sim;
