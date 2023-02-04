library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rs_ff is
    port (
        clk : in std_logic;
        r   : in std_logic;
        s   : in std_logic;
        q   : out std_logic;
        q_n : out std_logic
    );
end rs_ff;

architecture rtl of rs_ff is
signal q_temp : std_logic;
begin

    VBLANK_PROS : process(clk)
        begin
            if rising_edge (clk) then
                if    (s = '0') and (r = '0') then
                    q_temp <=q_temp; ----------------not valid
                elsif (s = '0') and (r = '1') then               
                    q_temp <='0';
                elsif (s = '1') and (r = '0') then               
                    q_temp <='1';
                elsif (s = '1') and (r = '1') then               
                    q_temp <= q_temp;
                end if;
            end if;
    end process;

    q    <=     q_temp;
    q_n  <= not(q_temp);

end architecture;