library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity accel_tilt_estimator is
    port (
        clk : in std_logic;
        data_valid : in std_logic;
        accel_x_g : in signed(23 downto 0);
        accel_y_g : in signed(23 downto 0);
        accel_z_g : in signed(23 downto 0);
        accel_roll_deg : out signed(23 downto 0);
        accel_pitch_deg : out signed(23 downto 0);
        angle_valid : out std_logic
    );
end entity accel_tilt_estimator;

architecture rtl of accel_tilt_estimator is
    function abs_int(value : integer) return integer is
    begin
        if value < 0 then return -value; else return value; end if;
    end function;

    function atan2_approx(y : integer; x : integer) return integer is
        variable ay : integer;
        variable ax : integer;
        variable ratio : integer;
        variable angle : integer;
        variable base_angle : integer;
    begin
        ay := abs_int(y);
        ax := abs_int(x);
        if ax = 0 then
            if y > 0 then return 23040;
            elsif y < 0 then return -23040;
            else return 0;
            end if;
        end if;

        if ay <= ax then
            ratio := (ay * 100) / ax;
        else
            ratio := (ax * 100) / ay;
        end if;

        angle :=
            (11520 * ratio) / 100 +
            (4004 * ratio * (100 - ratio)) / 10000;

        if ay > ax then
            angle := 23040 - angle;
        end if;

        if x < 0 then
            if y >= 0 then
                base_angle := 46080 - angle;
            else
                base_angle := -46080 + angle;
            end if;
        else
            if y < 0 then
                base_angle := -angle;
            else
                base_angle := angle;
            end if;
        end if;

        return base_angle;
    end function;

    function magnitude_approx(x : integer; y : integer) return integer is
        variable ax : integer;
        variable ay : integer;
        variable maximum : integer;
        variable minimum : integer;
    begin
        ax := abs_int(x);
        ay := abs_int(y);
        if ax >= ay then
            maximum := ax;
            minimum := ay;
        else
            maximum := ay;
            minimum := ax;
        end if;
        return maximum + (414 * minimum) / 1000;
    end function;
begin
    process(clk)
        variable x_value : integer;
        variable y_value : integer;
        variable z_value : integer;
        variable yz_magnitude : integer;
        variable roll_value : integer;
        variable pitch_value : integer;
    begin
        if rising_edge(clk) then
            angle_valid <= '0';
            if data_valid = '1' then
                x_value := to_integer(accel_x_g);
                y_value := to_integer(accel_y_g);
                z_value := to_integer(accel_z_g);

                roll_value := atan2_approx(y_value, z_value);

                yz_magnitude := magnitude_approx(y_value, z_value);

                pitch_value := atan2_approx(-x_value, yz_magnitude);

                accel_roll_deg <= to_signed(roll_value, 24);
                accel_pitch_deg <= to_signed(pitch_value, 24);
                angle_valid <= '1';
            end if;
        end if;
    end process;
end architecture rtl;
