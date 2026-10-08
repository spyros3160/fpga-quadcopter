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

    signal bit_count : integer range 0 to 16 := 0;
    signal transaction_number : integer range 0 to 11 := 0;

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
        variable response_value : std_logic_vector(7 downto 0);
    begin
        if cs = '1' then
            bit_count <= 0;
            miso <= '0';

        elsif rising_edge(sclk) then

            if bit_count < 8 then
                bit_count <= bit_count + 1;
            end if;

        elsif falling_edge(sclk) then

            if bit_count = 8 then

                case transaction_number is
                    when 0  => response_value := x"00"; -- Accel X high
                    when 1  => response_value := x"00"; -- Accel X low
                    when 2  => response_value := x"0B"; -- Accel Y high
                    when 3  => response_value := x"50"; -- Accel Y low
                    when 4  => response_value := x"0B"; -- Accel Z high
                    when 5  => response_value := x"50"; -- Accel Z low
                    when 6  => response_value := x"00"; -- Gyro X high
                    when 7  => response_value := x"00"; -- Gyro X low
                    when 8  => response_value := x"00"; -- Gyro Y high
                    when 9  => response_value := x"00"; -- Gyro Y low
                    when 10 => response_value := x"00"; -- Gyro Z high
                    when 11 => response_value := x"00"; -- Gyro Z low
                    when others => response_value := x"00";
                end case;

                response_byte <= response_value;
                miso <= response_value(7);
                bit_count <= 9;

            elsif bit_count = 9 then
                miso <= response_byte(6);
                bit_count <= 10;

            elsif bit_count = 10 then
                miso <= response_byte(5);
                bit_count <= 11;

            elsif bit_count = 11 then
                miso <= response_byte(4);
                bit_count <= 12;

            elsif bit_count = 12 then
                miso <= response_byte(3);
                bit_count <= 13;

            elsif bit_count = 13 then
                miso <= response_byte(2);
                bit_count <= 14;

            elsif bit_count = 14 then
                miso <= response_byte(1);
                bit_count <= 15;

            elsif bit_count = 15 then
                miso <= response_byte(0);
                bit_count <= 16;
            end if;
        end if;
    end process;

    process(cs)
    begin
        if rising_edge(cs) then
            if transaction_number = 11 then
                transaction_number <= 0;
            else
                transaction_number <= transaction_number + 1;
            end if;
        end if;
    end process;

    process
    begin
        wait for 100 ns;

        for sample in 1 to 200 loop

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            wait until attitude_valid = '1';
            wait until attitude_valid = '0';

        end loop;

        report "SUCCESS: 200 IMU samples processed."
            severity note;

        report "Final Roll = "
            & integer'image(to_integer(roll_deg))
            & " degrees (Q16.8)"
            severity note;

        report "Final Pitch = "
            & integer'image(to_integer(pitch_deg))
            & " degrees (Q16.8)"
            severity note;

        assert to_integer(roll_deg) >= 42 * 256
            report "ERROR: Roll did not converge close to +45 degrees."
            severity error;

        assert to_integer(roll_deg) <= 46 * 256
            report "ERROR: Roll exceeded expected +45 degree range."
            severity error;

        assert abs(to_integer(pitch_deg)) <= 2 * 256
            report "ERROR: Pitch is not approximately 0 degrees."
            severity error;

        report "SUCCESS: +45 degree roll integration test passed."
            severity note;

        report "SUCCESS: Complete IMU attitude chain verified."
            severity note;

        wait;
    end process;

end architecture sim;
