library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sr_ff is
    port (
        clk : in std_logic;
        s_n : in std_logic;
        r_n : in std_logic;
        q   : out std_logic;
        q_n : out std_logic
    );
end sr_ff;

architecture rtl of sr_ff is
    signal q_temp : std_logic:= '0';
begin

    SR_FF : process(clk)
        begin
            if rising_edge (clk) then
                if    (s_n = '0') nor (r_n = '0') then
                    q_temp <=q_temp; ------------------ not valid
                elsif (s_n = '0') nor (r_n = '1') then               
                    q_temp <='0';
                elsif (s_n = '1') nor (r_n = '0') then               
                    q_temp <='1';
                elsif (s_n = '1') nor (r_n = '1') then               
                    q_temp <= q_temp;  
                end if;
            end if;
    end process;
    
    q   <=     q_temp;
    q_n <= not(q_temp);

end architecture;