library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity game_control is
    port (
        clk_14   : in std_logic;
        stopg1_n : in std_logic;
        stopg2_n : in std_logic;
        coin     : in std_logic;
        hvid_n   : in std_logic;
        vvid_n   : in std_logic;
        pad1     : in std_logic;
        pad2     : in std_logic;
        miss_n : in std_logic;
        rst_speed : out std_logic;
        stop_g   : out std_logic;
        serve    : out std_logic;
        hit      : out std_logic;
        attract : out std_logic;
        srst    : out std_logic;
        hit1_n  : out std_logic;
        hit2_n  : out std_logic;
        run_in  : in std_logic;
        net_in  : in std_logic
    );
end game_control;

architecture rtl of game_control is
signal run_n, srst_n, speed_rst, E6A, F4_LM555, E5A : std_logic := '0';
signal G1B, stopg, hit1_n_d, hit2_n_d: std_logic;

begin

    run_n <= run_in;
    stopg <= stopg1_n nand stopg2_n;
    stop_g <= stopg;
    attract <= (stopg or run_n);
    srst_n <= not(coin);
    srst <= not(srst_n);

    -- combinatorial logic for Hit
    G1B <= not(hvid_n or vvid_n);
    hit1_n_d <= (G1B nand pad1);
    hit2_n_d <= (G1B nand pad2);
    hit <= hit1_n_d nand hit2_n_d;
    hit1_n <= hit1_n_d;
    hit2_n <= hit2_n_d;

    -- start of serve generation
    speed_rst <= srst_n nand  miss_n;
    rst_speed <= speed_rst;
    E6A <= not speed_rst;

    LM55_COMP : LM555_monostable
        generic map(
            trigger_value => 24340600 -- equivalent to 1.7sec with 14.318Mhz clock
        )
        port map(
            clk      => clk_14, 
            trig     => E6A,
            mono_out => F4_LM555, 
            control  => 0 
        );


    E5A <= not(run_n or stopg or F4_LM555);

    B5B_DFF : sn7474
        Port map (
            clr_n   => E5A,
            pr_n    => '1',
            clk     => net_in, --pad1,
            d       => E5A,
            q       => open,
            q_n     => serve
        );

end architecture;