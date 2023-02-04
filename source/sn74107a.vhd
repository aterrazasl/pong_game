library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sn74107a is
    port (
        clk : in std_logic;
        clr_n : in std_logic;
        j   : in std_logic;
        k   : in std_logic;
        q   : out std_logic;
        q_n : out std_logic
    );
end sn74107a;

architecture rtl of sn74107a is
signal tmp : std_logic := '0';
begin

    
    q   <= '0' when clr_n = '0' else tmp; -- and not clr_n;
    q_n <= '1' when clr_n = '0' else (not tmp) ; --  or (not clr_n);

    JK_FF_PROC : process(clk, clr_n)
    
    begin
        if clr_n = '0' then
            tmp <= '0';
        -- end if;         
        elsif falling_edge(clk) then

            if(j='0' and k='0')then
                tmp <= tmp;
            elsif(j='1' and k='1')then
                tmp <= not tmp;
            elsif(j='0' and k='1')then
                tmp <='0';
            elsif(j='1' and k='0')then
                tmp <='1';
            end if;
        end if;
    end process;

end architecture;