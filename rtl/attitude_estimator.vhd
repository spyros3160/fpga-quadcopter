library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity attitude_estimator is
    port (
        clk : in std_logic;
        data_valid : in std_logic;
        accel_roll_deg  : in signed(23 downto 0);
        accel_pitch_deg : in signed(23 downto 0);
        gyro_x_dps : in signed(23 downto 0);
        gyro_y_dps : in signed(23 downto 0);
        roll_deg  : out signed(23 downto 0);
        pitch_deg : out signed(23 downto 0);
        attitude_valid : out std_logic
    );
end entity attitude_estimator;

architecture rtl of attitude_estimator is
    constant ALPHA : integer := 251;
    constant BETA  : integer := 5;
    signal roll_estimate  : integer := 0;
    signal pitch_estimate : integer := 0;
begin
    process(clk)
        variable gyro_roll_delta  : integer;
        variable gyro_pitch_delta : integer;
        variable roll_gyro  : integer;
        variable pitch_gyro : integer;
        variable accel_roll_q16  : integer;
        variable accel_pitch_q16 : integer;
        variable new_roll  : integer;
        variable new_pitch : integer;
        variable output_roll  : integer;
        variable output_pitch : integer;
    begin
        if rising_edge(clk) then
            attitude_valid <= '0';
            if data_valid = '1' then
                gyro_roll_delta :=
                    (to_integer(gyro_x_dps) * 256) / 1000;
                gyro_pitch_delta :=
                    (to_integer(gyro_y_dps) * 256) / 1000;
                roll_gyro := roll_estimate + gyro_roll_delta;
                pitch_gyro := pitch_estimate + gyro_pitch_delta;
                accel_roll_q16 :=
                    to_integer(accel_roll_deg) * 256;
                accel_pitch_q16 :=
                    to_integer(accel_pitch_deg) * 256;
                new_roll :=
                    (ALPHA * roll_gyro +
                     BETA * accel_roll_q16) / 256;
                new_pitch :=
                    (ALPHA * pitch_gyro +
                     BETA * accel_pitch_q16) / 256;
                roll_estimate <= new_roll;
                pitch_estimate <= new_pitch;
                output_roll := new_roll / 256;
                output_pitch := new_pitch / 256;
                roll_deg <= to_signed(output_roll, 24);
                pitch_deg <= to_signed(output_pitch, 24);
                attitude_valid <= '1';
            end if;
        end if;
    end process;
end architecture rtl;
