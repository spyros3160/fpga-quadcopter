library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_master is

    generic (
        CLK_FREQ_HZ : integer := 50000000;
        SPI_FREQ_HZ : integer := 1000000
    );

    port (
        clk : in std_logic;

        start   : in  std_logic;
        tx_data : in  std_logic_vector(7 downto 0);

        rx_data : out std_logic_vector(7 downto 0);
        done    : out std_logic;

        sclk : out std_logic;
        mosi : out std_logic;
        miso : in  std_logic;
        cs   : out std_logic
    );

end entity spi_master;

architecture rtl of spi_master is
	
	-- Generate SPI clock
	-- FPGA clock period = 20 ns
	-- SPI clock period = 1000 ns
	-- 25 FPGA clock cycles for each half-period of SPI clock
	constant CLK_DIV : integer := CLK_FREQ_HZ / (2 * SPI_FREQ_HZ);

	 --clock counter from 0 to 24
    signal clk_count : integer range 0 to CLK_DIV - 1 := 0;
	 
	 --counter for internal clock of SPI master 
	 signal sclk_int : std_logic := '0';
	 
	 -- Transmit shift register
    signal tx_shift : std_logic_vector(7 downto 0) := (others => '0');

    -- Receive shift register
    signal rx_shift : std_logic_vector(7 downto 0) := (others => '0');
	 
	 --commmunication SPI->IMU
	 signal busy : std_logic := '0';
	 
	 --BIT counter
	 signal bit_count : integer range 0 to 7 := 0;
	 
	 -- Indicates that the last SPI bit has been received
	 signal last_bit : std_logic := '0';

begin

process(clk)
begin

    if rising_edge(clk) then
		  done <= '0';

        if busy = '0' then
		  
				if start = '1' then
					 busy <= '1';
					 clk_count <= 0;
					 sclk_int <= '0';

					 tx_shift <= tx_data;
					 mosi <= tx_data(7);
					 bit_count <= 0;
				end if;

        else

            if clk_count = CLK_DIV - 1 then

                clk_count <= 0;

                if sclk_int = '0' then

                    -- Rising edge: read MISO
                    rx_shift <= rx_shift(6 downto 0) & miso;

                    if bit_count = 7 then
								-- 8 bits completed
								rx_data <= rx_shift(6 downto 0) & miso;
								last_bit <= '1';
								
                    else
                        bit_count <= bit_count + 1;
								
								
                    end if;
						  
					else

						if last_bit = '1' then

							  -- SPI transfer completed
							  busy <= '0';
							  last_bit <= '0';
							  sclk_int <= '0';
							  mosi <= '0';
							  done <= '1';

						else

							  tx_shift <= tx_shift(6 downto 0) & '0';
							  mosi <= tx_shift(6);
							  sclk_int <= not sclk_int;

						end if;

                end if;

                sclk_int <= not sclk_int;

            else
                clk_count <= clk_count + 1;
					 
            end if;

        end if;

    end if;

end process;


sclk <= sclk_int;
cs <= not busy;


end architecture rtl;
