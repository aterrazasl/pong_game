library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_counter is
    port (
        clk_n   : in std_logic;
        rst     : in std_logic;
        stopg_n : out std_logic;
        dig0    : out std_logic_vector(3 downto 0);
        dig1    : out std_logic_vector(3 downto 0)
    );
end bcd_counter;

architecture rtl of bcd_counter is
    signal counter0, counter1 : integer range 0 to 10 := 0;
begin

    COUNT_PROC : process(clk_n, rst)
    begin
        dig0 <= std_logic_vector(to_unsigned(counter0,4));
        dig1 <= std_logic_vector(to_unsigned(counter1,4));
        if rst = '1' then
            counter0<= 0;
            counter1 <= 0;
            stopg_n <= '1';
        elsif rising_edge (clk_n) then
            if counter0 = 1 and counter1 =1 then
                counter0 <= 0;
                counter1 <= 0;
                stopg_n <= '0';
            else
                stopg_n <= '1';
                if counter0 < 9 then
                    counter0 <= counter0 + 1;
                else
                    counter0 <= 0;
                    counter1 <= counter1 + 1;
                end if; 
            end if;
        end if;
    end process;
end architecture;