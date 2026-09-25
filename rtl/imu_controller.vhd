library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity imu_controller is

    port (
        clk : in std_logic;

        -- Controller interface
        start    : in  std_logic;
        tx_data  : in  std_logic_vector(7 downto 0);
        rx_data  : out std_logic_vector(7 downto 0);
        done     : out std_logic;

        -- SPI interface
        sclk : out std_logic;
        mosi : out std_logic;
        miso : in  std_logic;
        cs   : out std_logic
    );

end entity imu_controller;


architecture rtl of imu_controller is

    -- SPI Master interface
    signal spi_start   : std_logic := '0';
    signal spi_tx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal spi_rx_data : std_logic_vector(7 downto 0);
    signal spi_done    : std_logic;

    -- Controller state
    type state_type is (IDLE, START_SPI, WAIT_SPI);

    signal state : state_type := IDLE;

begin

    ----------------------------------------------------------------
    -- SPI Master
    ----------------------------------------------------------------

    SPI : entity work.spi_master

        generic map (
            CLK_FREQ_HZ => 50000000,
            SPI_FREQ_HZ => 1000000
        )

        port map (
            clk      => clk,

            start    => spi_start,
            tx_data  => spi_tx_data,

            rx_data  => spi_rx_data,
            done     => spi_done,

            sclk     => sclk,
            mosi     => mosi,
            miso     => miso,
            cs       => cs
        );


    ----------------------------------------------------------------
    -- IMU Controller
    ----------------------------------------------------------------

    process(clk)
    begin

        if rising_edge(clk) then

            -- Default values
            spi_start <= '0';
            done      <= '0';

            case state is

                ----------------------------------------------------
                -- Waiting for a new transaction
                ----------------------------------------------------

                when IDLE =>

                    if start = '1' then

                        spi_tx_data <= tx_data;

                        state <= START_SPI;

                    end if;


                ----------------------------------------------------
                -- Start SPI transfer
                ----------------------------------------------------

                when START_SPI =>

                    spi_start <= '1';

                    state <= WAIT_SPI;


                ----------------------------------------------------
                -- Wait for SPI transfer to finish
                ----------------------------------------------------

                when WAIT_SPI =>

                    if spi_done = '1' then

                        rx_data <= spi_rx_data;

                        done <= '1';

                        state <= IDLE;

                    end if;


            end case;

        end if;

    end process;

end architecture rtl;