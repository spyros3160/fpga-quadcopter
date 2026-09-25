library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity imu_controller_tb is
end entity imu_controller_tb;


architecture sim of imu_controller_tb is

    -- FPGA clock
    signal clk : std_logic := '0';

    -- Controller interface
    signal start   : std_logic := '0';
    signal tx_data : std_logic_vector(7 downto 0) := (others => '0');

    signal rx_data : std_logic_vector(7 downto 0);
    signal done    : std_logic;

    -- SPI signals
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

    DUT : entity work.imu_controller

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

        -- Data transmitted by FPGA
        tx_data <= "11001010";

        -- Wait before starting
        wait for 100 ns;

        -- Start transaction
        start <= '1';

        wait for 20 ns;

        start <= '0';

        -- Wait until transaction is completed
        wait until done = '1';

        -- Check received data
        assert rx_data = "00110101"
            report "ERROR: Received data is incorrect!"
            severity error;

        report "SUCCESS: IMU Controller received correct data."
            severity note;

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