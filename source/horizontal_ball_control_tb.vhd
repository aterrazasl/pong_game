library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

use work.pong_pkg.all;

entity horizontal_ball_control_tb is
end horizontal_ball_control_tb;

architecture sim of horizontal_ball_control_tb is

    constant clk_hz : integer := 7e6;
    constant clk_period : time := 1 sec / clk_hz;
    --constant vreset_period : time := 1 sec / ((clk_period / 2) * 256);

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal vid_sync : video_sync_type;
    signal hit_sound, sc, attract, serve, hit1_n, hit2_n, hvid_n, left, right : std_logic := '0';
    signal rst_speed : std_logic := '1';
    signal debug : std_logic_vector(3 downto 0) := "0000";
    signal h256_n, vreset : std_logic := '0';
begin

    clk    <= not clk after clk_period / 2;
    h256_n <= not h256_n after (clk_period / 2) * 256;

    vid_sync.horizontal.c256 <= h256_n;
    vid_sync.vertical.reset <= vreset;

    HIT_SOUND_PROC : process
    begin
        hit_sound <= '1';
        wait for clk_period *256;
        hit_sound <= '0';
        wait for clk_period * 256*50;
    end process;

    VRESET_PROC : process
    begin
        vreset <= '1';-- after (clk_period);
        wait for clk_period *256;
        vreset <= '0';
        wait for clk_period * 256*10;
    end process;


    DUT : entity work.horizontal_ball_control(rtl)
    port map (
        vid_sync    => vid_sync,
        rst_speed   => rst_speed,
        hit_sound   => hit_sound,
        sc          => sc,
        attract     => attract,
        serve       => serve,
        hit1_n      => hit1_n,
        hit2_n      => hit2_n,
        hvid_n      => hvid_n,
        left        => left,
        right       => right,
        debug       => debug
    );

    SEQUENCER_PROC : process
    begin

        wait for clk_period * 10;
        rst_speed <= '0';
        rst <= '0';

        wait for clk_period * 10;
        wait for 40 mS; --clk_period * 2048;
        assert false
            report "Replace this with your test cases"
            severity failure;

        finish;
    end process;

end architecture;