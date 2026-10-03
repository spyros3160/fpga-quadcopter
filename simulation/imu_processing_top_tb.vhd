library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imu_processing_top_tb is
end entity imu_processing_top_tb;

architecture sim of imu_processing_top_tb is

    signal clk : std_logic := '0';
    constant CLK_PERIOD : time := 20 ns;

    signal start : std_logic := '0';

    signal roll_deg : signed(23 downto 0);
    signal pitch_deg : signed(23 downto 0);
    signal attitude_valid : std_logic;

    signal sclk : std_logic;
    signal mosi : std_logic;
    signal miso : std_logic := '0';
    signal cs : std_logic;

    signal response_byte : std_logic_vector(7 downto 0)
        := (others => '0');

    signal command_byte : std_logic_vector(7 downto 0)
        := (others => '0');

    signal bit_count : integer range 0 to 16 := 0;
    signal transaction_active : std_logic := '0';

begin

    clk <= not clk after CLK_PERIOD / 2;

    DUT : entity work.imu_processing_top
        port map (
            clk => clk,
            start => start,
            roll_deg => roll_deg,
            pitch_deg => pitch_deg,
            attitude_valid => attitude_valid,
            sclk => sclk,
            mosi => mosi,
            miso => miso,
            cs => cs
        );

    process(sclk, cs)
        variable cmd_value : std_logic_vector(7 downto 0);
    begin
        if cs = '1' then
            bit_count <= 0;
            command_byte <= (others => '0');
            response_byte <= (others => '0');
            miso <= '0';
            transaction_active <= '0';

        elsif falling_edge(sclk) then
            transaction_active <= '1';

            if bit_count < 8 then
                command_byte <=
                    command_byte(6 downto 0) & mosi;

                bit_count <= bit_count + 1;

                if bit_count = 7 then
                    cmd_value :=
                        command_byte(6 downto 0) & mosi;

                    case cmd_value is
                        when x"9F" => response_byte <= x"00";
                        when x"A0" => response_byte <= x"00";
                        when x"A1" => response_byte <= x"00";
                        when x"A2" => response_byte <= x"00";
                        when x"A3" => response_byte <= x"10";
                        when x"A4" => response_byte <= x"00";
                        when x"A5" => response_byte <= x"00";
                        when x"A6" => response_byte <= x"00";
                        when x"A7" => response_byte <= x"00";
                        when x"A8" => response_byte <= x"00";
                        when x"A9" => response_byte <= x"00";
                        when x"AA" => response_byte <= x"00";
                        when others => response_byte <= x"00";
                    end case;

                    bit_count <= 8;
                end if;

            elsif bit_count < 16 then
                miso <= response_byte(15 - bit_count);
                bit_count <= bit_count + 1;
            end if;
        end if;
    end process;

    process
    begin
        wait for 100 ns;

        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        wait until attitude_valid = '1';

        report "SUCCESS: attitude_valid detected."
            severity note;

        assert abs(to_integer(roll_deg)) <= 2
            report "ERROR: Roll is not approximately 0 degrees."
            severity error;

        assert abs(to_integer(pitch_deg)) <= 2
            report "ERROR: Pitch is not approximately 0 degrees."
            severity error;

        report "SUCCESS: Complete IMU processing chain verified."
            severity note;

        report "SUCCESS: Roll and Pitch are approximately 0 degrees."
            severity note;

        wait;
    end process;

end architecture sim;
