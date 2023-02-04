library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ball_position_counter is
    generic (
        trigger_value : in integer range 0 to 65535; -- value at which trigger_n goes low
        reset_value   : in integer range 0 to 65535  -- value at which the counter reloads the load_value
    );
    port (
        clk           : in std_logic;
        clr_n         : in std_logic;
        enable        : in std_logic;
        load_value    : in std_logic_vector(15 downto 0); -- value at which the count starts at
        pos_counter   : out std_logic_vector(15 downto 0);
        trigger_n     : out std_logic
    );
end ball_position_counter;

architecture rtl of ball_position_counter is
    signal counter : integer range 0 to 65535;
    signal trigger_output : std_logic :='1';

begin
    trigger_n <= trigger_output;
    
    BALL_COUNTER_PROC : process(clk, clr_n)
        begin
            pos_counter <= std_logic_vector(to_unsigned(counter,16));
            if clr_n = '0' then
                counter <= 0;
                trigger_output <= '1';
            elsif rising_edge(clk) then
                if enable = '1' then
                    trigger_output <= '1';
                    if counter < reset_value then
                        counter <= counter + 1;
                    else
                        counter <= to_integer(unsigned(load_value));
                    end if;

                    if counter = trigger_value then
                        trigger_output <= '0';
                    end if;

                end if;

            end if;
    end process;    

end architecture;