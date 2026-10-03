library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sensor_processor is
    port (
        clk : in std_logic;
        data_valid : in std_logic;

        accel_x_raw : in signed(15 downto 0);
        accel_y_raw : in signed(15 downto 0);
        accel_z_raw : in signed(15 downto 0);

        gyro_x_raw : in signed(15 downto 0);
        gyro_y_raw : in signed(15 downto 0);
        gyro_z_raw : in signed(15 downto 0);

        accel_x_g : out signed(23 downto 0);
        accel_y_g : out signed(23 downto 0);
        accel_z_g : out signed(23 downto 0);

        gyro_x_dps : out signed(23 downto 0);
        gyro_y_dps : out signed(23 downto 0);
        gyro_z_dps : out signed(23 downto 0);

        processed_valid : out std_logic
    );
end entity sensor_processor;

architecture rtl of sensor_processor is

    -- Q16.8 fixed-point format:
    -- 1.0 = 256
    --
    -- Accelerometer:
    -- ±8 g -> 4096 LSB/g
    -- Q16.8 result = raw * 256 / 4096 = raw / 16
    --
    -- Gyroscope:
    -- ±2000 dps -> 16.4 LSB/(dps)
    -- Q16.8 result = raw * 256 / 16.4
    --               = raw * 640 / 41

    function accel_to_q8(value : signed(15 downto 0))
        return signed is
        variable value_int : integer;
        variable result_int : integer;
    begin
        value_int := to_integer(value);
        result_int := value_int / 16;
        return to_signed(result_int, 24);
    end function;

    function gyro_to_q8(value : signed(15 downto 0))
        return signed is
        variable value_int : integer;
        variable result_int : integer;
    begin
        value_int := to_integer(value);
        result_int := (value_int * 640) / 41;
        return to_signed(result_int, 24);
    end function;

begin

    process(clk)
    begin
        if rising_edge(clk) then

            processed_valid <= '0';

            if data_valid = '1' then

                accel_x_g <= accel_to_q8(accel_x_raw);
                accel_y_g <= accel_to_q8(accel_y_raw);
                accel_z_g <= accel_to_q8(accel_z_raw);

                gyro_x_dps <= gyro_to_q8(gyro_x_raw);
                gyro_y_dps <= gyro_to_q8(gyro_y_raw);
                gyro_z_dps <= gyro_to_q8(gyro_z_raw);

                processed_valid <= '1';

            end if;

        end if;
    end process;

end architecture rtl;
