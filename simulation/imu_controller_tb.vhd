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
    signal register_address : std_logic_vector(7 downto 0) := (others => '0');

    signal register_data    : std_logic_vector(7 downto 0);
    signal done             : std_logic;


    ----------------------------------------------------------------
    -- SPI signals
    ----------------------------------------------------------------

    signal sclk : std_logic;
    signal mosi : std_logic;
    signal miso : std_logic := '0';
    signal cs   : std_logic;


    ----------------------------------------------------------------
    -- Virtual IMU
    ----------------------------------------------------------------

    -- Virtual register data
    constant IMU_REGISTER_DATA : std_logic_vector(7 downto 0)
        := "01000010";   -- 0x42

    -- Address received from FPGA
    signal address_received : std_logic_vector(7 downto 0)
        := (others => '0');

    signal imu_bit : integer range 0 to 7 := 0;


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
        -- Request register 0x75
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
        -- Wait for transaction completion
        ------------------------------------------------------------

        wait until done = '1';


        ------------------------------------------------------------
        -- Check received register data
        ------------------------------------------------------------

        assert register_data = IMU_REGISTER_DATA

            report "ERROR: Register data is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- Check transmitted register address
        ------------------------------------------------------------

        assert address_received = x"75"

            report "ERROR: Register address is incorrect!"

            severity error;


        ------------------------------------------------------------
        -- Successful test
        ------------------------------------------------------------

        report "SUCCESS: IMU Controller register read completed correctly."

            severity note;


        wait for 100 ns;

        wait;

    end process;


    ----------------------------------------------------------------
    -- Virtual IMU
    --
    -- SPI Mode 0
    ----------------------------------------------------------------

    process(cs, sclk)
    begin

        ------------------------------------------------------------
        -- CS LOW
        -- Start of SPI transaction
        ------------------------------------------------------------

        if falling_edge(cs) then

            imu_bit <= 0;

            -- Send MSB of register data
            miso <= IMU_REGISTER_DATA(7);


        ------------------------------------------------------------
        -- Rising edge of SCLK
        -- FPGA samples MISO
        -- Virtual IMU samples MOSI
        ------------------------------------------------------------

        elsif rising_edge(sclk) then

            if cs = '0' then

                address_received <=
                    address_received(6 downto 0) & mosi;

            end if;


        ------------------------------------------------------------
        -- Falling edge of SCLK
        -- Prepare next MISO bit
        ------------------------------------------------------------

        elsif falling_edge(sclk) then

            if cs = '0' then

                if imu_bit < 7 then

                    imu_bit <= imu_bit + 1;

                    miso <= IMU_REGISTER_DATA(6 - imu_bit);

                end if;

            end if;

        end if;

    end process;

end architecture sim;
