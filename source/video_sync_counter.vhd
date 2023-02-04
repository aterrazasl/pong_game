library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity video_sync_counter is
    generic (
        trigger_value : in integer range 0 to 511 -- value at which hvid_n goes low
    );    
    port (
        clk       : in std_logic;
        reset_out : out std_logic;
        count   : out std_logic_vector (8 downto 0)
    );
end video_sync_counter;

architecture rtl of video_sync_counter is
    signal reset, F7_out : std_logic := '0';
    signal counter : integer range 0 to 511 := 0;

begin

    COUNT_PROC : process(clk, reset)
        begin
            if (reset = '1') then
                counter <= 0;
            elsif falling_edge(clk) then
                counter <= counter + 1;
            end if;
    end process;

    count <= std_logic_vector(to_unsigned(counter,9));

    F7_out <= '0' when counter = trigger_value else '1';                

    E7B_DFF : sn7474
        Port map(
            clr_n   => '1',
            pr_n    => '1',
            clk     => clk,
            d       => F7_out,
            q       => open,
            q_n     => reset
        );
    
    reset_out  <= reset;

end architecture;