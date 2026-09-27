library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity imu_controller is
    port (
        clk : in std_logic;

        -- Start a register transaction
        start : in std_logic;

        -- '0' = read
        -- '1' = write
        write_enable : in std_logic;

        -- Register address
        register_address : in std_logic_vector(7 downto 0);

        -- Data to write to the register
        write_data : in std_logic_vector(7 downto 0);

        -- Data read from the register
        register_data : out std_logic_vector(7 downto 0);

        -- Transaction completed
        done : out std_logic;

        -- SPI interface
        sclk : out std_logic;
        mosi : out std_logic;
        miso : in std_logic;
        cs   : out std_logic
    );
end entity imu_controller;


architecture rtl of imu_controller is

    signal spi_start   : std_logic := '0';
    signal spi_tx_data : std_logic_vector(15 downto 0)
        := (others => '0');

    signal spi_rx_data : std_logic_vector(15 downto 0);

    signal spi_done : std_logic;

    type state_type is (
        IDLE,
        START_SPI,
        WAIT_SPI
    );

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
                -- Wait for a new transaction
                ----------------------------------------------------

                when IDLE =>

                    if start = '1' then

                        if write_enable = '0' then

                            ------------------------------------------------
                            -- READ
                            --
                            -- Bit 7 = 1
                            -- Bits 6..0 = register address
                            -- Second byte = dummy byte
                            ------------------------------------------------

                            spi_tx_data <=
                                ('1' & register_address(6 downto 0))
                                & x"00";

                        else

                            ------------------------------------------------
                            -- WRITE
                            --
                            -- Bit 7 = 0
                            -- Bits 6..0 = register address
                            -- Second byte = data
                            ------------------------------------------------

                            spi_tx_data <=
                                ('0' & register_address(6 downto 0))
                                & write_data;

                        end if;

                        state <= START_SPI;

                    end if;


                ----------------------------------------------------
                -- Start SPI transaction
                ----------------------------------------------------

                when START_SPI =>

                    spi_start <= '1';

                    state <= WAIT_SPI;


                ----------------------------------------------------
                -- Wait for SPI transaction to finish
                ----------------------------------------------------

                when WAIT_SPI =>

                    if spi_done = '1' then

                        -- For READ transactions,
                        -- the received register value is
                        -- in the last 8 bits.

                        if write_enable = '0' then
                            register_data <= spi_rx_data(7 downto 0);
                        end if;

                        done <= '1';

                        state <= IDLE;

                    end if;

            end case;

        end if;

    end process;

end architecture rtl;
