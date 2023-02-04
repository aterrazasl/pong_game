library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity paddle is
    port (
        clk_14  : in std_logic;
        hsync_n : in std_logic;
        v256_n  : in std_logic;
        count   : out std_logic_vector(3 downto 0);
        vpad_n  : out std_logic
    );
end paddle;

architecture rtl of paddle is

    signal clk : std_logic := '1';
    signal counter : integer range 0 to 16 := 0;
    signal counter_rst : std_logic := '1';
    signal rst : std_logic := '0';

    signal counter2 : integer range 0 to 350000 := 0;
    signal v256_n_d : std_logic;

begin

    clk <= hsync_n nand counter_rst;
    vpad_n <= not(rst) nand counter_rst;

    count <= std_logic_vector(to_unsigned(counter,4));


    PADDLE_COUNTER_PROC : process(clk,rst)
    begin
        if rst = '1' then
            counter <= 0;
            counter_rst <= '1';
        elsif falling_edge(clk) then
            if counter < 15 then
                counter_rst <= '1';
                counter <= counter + 1;
            else
                counter <= 0;
                counter_rst <= '0';
            end if;
        end if;
    end process;


    LM555_COUNTER_PRO : LM555_monostable
        generic map(
            trigger_value => 126596    -- aprox 8.884 mS
        )
        port map (
            clk      => clk_14,
            trig     => v256_n,
            mono_out => rst,
            control  => 0
        );

end architecture;