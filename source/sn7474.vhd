library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sn7474 is
    Port (
        clr_n   : in std_logic;
        pr_n    : in std_logic;
        clk     : in std_logic;
        d       : in std_logic;
        q       : out std_logic;
        q_n     : out std_logic
    );
end sn7474;

architecture Behavioral of sn7474 is
    signal q_temp : std_logic := '0';
begin

    q <= q_temp;
    q_n <= not(q_temp);

    process (clk, pr_n, clr_n )
    begin
        if (pr_n = '0' and clr_n ='1') then
            q_temp  <= '1';
        elsif (pr_n = '1' and clr_n ='0') then
            q_temp  <= '0';
        elsif (rising_edge (clk) ) then
            q_temp  <= d;
        end if;

    end process;
end Behavioral;