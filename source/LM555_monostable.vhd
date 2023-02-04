library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LM555_monostable is
    generic (
        trigger_value : in integer
    );
    port (
        clk      : in std_logic;
        trig     : in std_logic;
        mono_out : out std_logic;
        control  : in integer
    );
end LM555_monostable;

architecture rtl of LM555_monostable is
signal trig_d, out_signal : std_logic;
signal counter : integer;
begin
    mono_out <= out_signal;

    LM555_COUNTER_PROC : process(clk)
    begin
        if falling_edge(clk) then
            trig_d <= trig;
            if trig = '0' and trig_d = '1' and out_signal = '0' then
                counter <= 0;
                out_signal <= '1';
            end if;
            if out_signal ='1' then
                if counter < (trigger_value + control)then 
                    counter <= counter + 1;
                    out_signal <= '1';                
                else
                    counter <= 0;
                    out_signal <= '0';
                end if;
            end if;
        end if;
    end process;


end architecture;