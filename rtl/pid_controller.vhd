library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pid_controller is
    generic (
        KP : integer := 256;
        KI : integer := 10;
        KD : integer := 50
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_valid : in std_logic;

        setpoint : in signed(23 downto 0);
        measurement : in signed(23 downto 0);

        control_output : out signed(23 downto 0);
        output_valid : out std_logic
    );
end entity pid_controller;

architecture rtl of pid_controller is

    signal previous_error : integer := 0;
    signal integral : integer := 0;

    signal output_reg : signed(23 downto 0) := (others => '0');

begin

    process(clk)
        variable error_value : integer;
        variable derivative_value : integer;
        variable proportional_value : integer;
        variable integral_value : integer;
        variable output_value : integer;
    begin

        if rising_edge(clk) then

            output_valid <= '0';

            if reset = '1' then

                previous_error <= 0;
                integral <= 0;
                output_reg <= (others => '0');

            elsif data_valid = '1' then

                -- Error = desired - measured
                error_value :=
                    to_integer(setpoint) -
                    to_integer(measurement);

                -- Proportional term
                proportional_value :=
                    (KP * error_value) / 256;

                -- Integral term
                integral_value :=
                    integral + ((KI * error_value) / 256);

                -- Derivative term
                derivative_value :=
                    (KD * (error_value - previous_error)) / 256;

                -- PID output
                output_value :=
                    proportional_value +
                    integral_value +
                    derivative_value;

                -- Save state
                integral <= integral_value;
                previous_error <= error_value;

                -- Limit output to signed 24-bit range
                if output_value > 8388607 then
                    output_value := 8388607;
                elsif output_value < -8388608 then
                    output_value := -8388608;
                end if;

                output_reg <= to_signed(output_value, 24);

                output_valid <= '1';

            end if;

        end if;

    end process;

    control_output <= output_reg;

end architecture rtl;