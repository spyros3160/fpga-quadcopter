library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pid_motor_control is
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_valid : in std_logic;

        -- Desired attitude (Q16.8)
        roll_setpoint  : in signed(23 downto 0);
        pitch_setpoint : in signed(23 downto 0);
        yaw_setpoint   : in signed(23 downto 0);

        -- Measured attitude (Q16.8)
        roll_measurement  : in signed(23 downto 0);
        pitch_measurement : in signed(23 downto 0);
        yaw_measurement   : in signed(23 downto 0);

        -- Base throttle
        throttle_us : in integer range 1000 to 2000;

        -- Motor outputs
        motor_1 : out integer range 1000 to 2000;
        motor_2 : out integer range 1000 to 2000;
        motor_3 : out integer range 1000 to 2000;
        motor_4 : out integer range 1000 to 2000;

        output_valid : out std_logic
    );
end entity pid_motor_control;


architecture rtl of pid_motor_control is

    -- PID outputs
    signal roll_output  : signed(23 downto 0);
    signal pitch_output : signed(23 downto 0);
    signal yaw_output   : signed(23 downto 0);

    -- PID valid signals
    signal roll_valid  : std_logic;
    signal pitch_valid : std_logic;
    signal yaw_valid   : std_logic;

    -- Combined valid signal
    signal pid_valid : std_logic;

begin

    ------------------------------------------------------------
    -- ROLL PID
    ------------------------------------------------------------

    PID_ROLL : entity work.pid_controller
        port map (
            clk => clk,
            reset => reset,
            data_valid => data_valid,

            setpoint => roll_setpoint,
            measurement => roll_measurement,

            control_output => roll_output,
            output_valid => roll_valid
        );


    ------------------------------------------------------------
    -- PITCH PID
    ------------------------------------------------------------

    PID_PITCH : entity work.pid_controller
        port map (
            clk => clk,
            reset => reset,
            data_valid => data_valid,

            setpoint => pitch_setpoint,
            measurement => pitch_measurement,

            control_output => pitch_output,
            output_valid => pitch_valid
        );


    ------------------------------------------------------------
    -- YAW PID
    ------------------------------------------------------------

    PID_YAW : entity work.pid_controller
        port map (
            clk => clk,
            reset => reset,
            data_valid => data_valid,

            setpoint => yaw_setpoint,
            measurement => yaw_measurement,

            control_output => yaw_output,
            output_valid => yaw_valid
        );


    ------------------------------------------------------------
    -- PID VALID
    ------------------------------------------------------------

    pid_valid <= roll_valid and pitch_valid and yaw_valid;


    ------------------------------------------------------------
    -- MOTOR MIXER
    ------------------------------------------------------------

    MOTOR_MIXER : entity work.motor_mixer
        port map (
            clk => clk,
            reset => reset,
            data_valid => pid_valid,

            throttle_us => throttle_us,

            roll_correction  => roll_output,
            pitch_correction => pitch_output,
            yaw_correction   => yaw_output,

            motor_1 => motor_1,
            motor_2 => motor_2,
            motor_3 => motor_3,
            motor_4 => motor_4,

            output_valid => output_valid
        );

end architecture rtl;
