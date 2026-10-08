library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity motor_mixer is
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_valid : in std_logic;

        -- Base throttle in microseconds
        throttle_us : in integer range 1000 to 2000;

        -- Corrections in Q16.8
        -- 1.0 = 256
        roll_correction  : in signed(23 downto 0);
        pitch_correction : in signed(23 downto 0);
        yaw_correction   : in signed(23 downto 0);

        -- Motor outputs in microseconds
        motor_1 : out integer range 1000 to 2000;
        motor_2 : out integer range 1000 to 2000;
        motor_3 : out integer range 1000 to 2000;
        motor_4 : out integer range 1000 to 2000;

        output_valid : out std_logic
    );
end entity motor_mixer;


architecture rtl of motor_mixer is

    signal motor_1_reg : integer range 1000 to 2000 := 1000;
    signal motor_2_reg : integer range 1000 to 2000 := 1000;
    signal motor_3_reg : integer range 1000 to 2000 := 1000;
    signal motor_4_reg : integer range 1000 to 2000 := 1000;

begin

    process(clk)

        variable roll_us  : integer;
        variable pitch_us : integer;
        variable yaw_us   : integer;

        variable motor_1_value : integer;
        variable motor_2_value : integer;
        variable motor_3_value : integer;
        variable motor_4_value : integer;

    begin

        if rising_edge(clk) then

            output_valid <= '0';

            if reset = '1' then

                motor_1_reg <= 1000;
                motor_2_reg <= 1000;
                motor_3_reg <= 1000;
                motor_4_reg <= 1000;

            elsif data_valid = '1' then

                ----------------------------------------------------
                -- Convert Q16.8 corrections to microseconds
                --
                -- 256 Q16.8 units = 1 us correction
                ----------------------------------------------------

                roll_us :=
                    to_integer(roll_correction) / 256;

                pitch_us :=
                    to_integer(pitch_correction) / 256;

                yaw_us :=
                    to_integer(yaw_correction) / 256;


                ----------------------------------------------------
                -- X-configuration motor mixing
                ----------------------------------------------------

                motor_1_value :=
                    throttle_us
                    + pitch_us
                    + roll_us
                    - yaw_us;

                motor_2_value :=
                    throttle_us
                    + pitch_us
                    - roll_us
                    + yaw_us;

                motor_3_value :=
                    throttle_us
                    - pitch_us
                    - roll_us
                    - yaw_us;

                motor_4_value :=
                    throttle_us
                    - pitch_us
                    + roll_us
                    + yaw_us;


                ----------------------------------------------------
                -- Saturation
                ----------------------------------------------------

                if motor_1_value > 2000 then
                    motor_1_value := 2000;
                elsif motor_1_value < 1000 then
                    motor_1_value := 1000;
                end if;


                if motor_2_value > 2000 then
                    motor_2_value := 2000;
                elsif motor_2_value < 1000 then
                    motor_2_value := 1000;
                end if;


                if motor_3_value > 2000 then
                    motor_3_value := 2000;
                elsif motor_3_value < 1000 then
                    motor_3_value := 1000;
                end if;


                if motor_4_value > 2000 then
                    motor_4_value := 2000;
                elsif motor_4_value < 1000 then
                    motor_4_value := 1000;
                end if;


                ----------------------------------------------------
                -- Register outputs
                ----------------------------------------------------

                motor_1_reg <= motor_1_value;
                motor_2_reg <= motor_2_value;
                motor_3_reg <= motor_3_value;
                motor_4_reg <= motor_4_value;

                output_valid <= '1';

            end if;

        end if;

    end process;


    motor_1 <= motor_1_reg;
    motor_2 <= motor_2_reg;
    motor_3 <= motor_3_reg;
    motor_4 <= motor_4_reg;

end architecture rtl;