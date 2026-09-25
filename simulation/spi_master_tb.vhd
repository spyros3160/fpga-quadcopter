library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_master_tb is
end entity spi_master_tb;


architecture sim of spi_master_tb is

    -- FPGA clock
    signal clk : std_logic := '0';

    -- SPI Master internal interface
    signal start   : std_logic := '0';
    signal tx_data : std_logic_vector(7 downto 0) := (others => '0');

    signal rx_data : std_logic_vector(7 downto 0);
    signal done    : std_logic;

    -- SPI physical signals
    signal sclk : std_logic;
    signal mosi : std_logic;
    signal miso : std_logic := '0';
    signal cs   : std_logic;

    -- Virtual IMU data
    signal imu_data : std_logic_vector(7 downto 0) := "00110101";
    signal imu_bit  : integer range 0 to 7 := 0;

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

        -- Data that FPGA will transmit
        tx_data <= "11001010";

        -- Wait before starting
        wait for 100 ns;

        -- Start SPI transfer
        start <= '1';

        wait for 20 ns;

        start <= '0';

        -- Wait until SPI transfer is completed
        wait until done = '1';

        -- Give ModelSim some time to display final signals
        wait for 100 ns;

        wait;

    end process;


    ----------------------------------------------------------------
    -- Virtual IMU
    -- SPI Mode 0
    ----------------------------------------------------------------

    process(cs, sclk)
    begin

        -- CS goes LOW:
        -- Start of SPI transaction
        if falling_edge(cs) then

            imu_bit <= 0;

            -- First bit (MSB)
            miso <= imu_data(7);


        -- SCLK falling edge:
        -- Prepare next MISO bit
        elsif falling_edge(sclk) then

            if cs = '0' then

                if imu_bit < 7 then

                    imu_bit <= imu_bit + 1;

                    miso <= imu_data(6 - imu_bit);

                end if;

            end if;

        end if;

    end process;


end architecture sim;