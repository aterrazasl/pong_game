library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity sound_control is
    port (
        vid_sync            : in video_sync_type;
        vert_pos_counter    : in std_logic_vector(15 downto 0);
        vvid                : in std_logic;
        serve               : in std_logic;
        hit                 : in std_logic;
        miss                : in std_logic;
        attract             : in std_logic;
        top_bot_hit_sound   : out std_logic;
        hit_sound_en        : out std_logic;
        hit_sound           : out std_logic;
        score_sound         : out std_logic;
        sc                  : out std_logic;
        sound               : out std_logic
    );
end sound_control;

architecture rtl of sound_control is
    signal hit_n, vvid_n, miss_n, serve_n : std_logic;
    signal vpos256, vpos16, vpos32, vpos255: std_logic;
    signal C2A_q_n : std_logic;
    signal G4_out : std_logic;
begin
    hit_n <= not(hit);
    vvid_n <= not(vvid);
    miss_n <= not(miss);
    serve_n <= not(serve);
    vpos256 <= vert_pos_counter(8);
    vpos32  <= vert_pos_counter(5);
    vpos16  <= vert_pos_counter(4);
    vpos255 <= vert_pos_counter(0) and vert_pos_counter(1) and vert_pos_counter(2) and vert_pos_counter(4) and vert_pos_counter(5) and vert_pos_counter(6) and vert_pos_counter(7);

    C2A_DFF : sn7474
        Port map(
            clr_n   => hit_n,
            pr_n    => '1',
            clk     => vpos255,
            d       => '1',
            q       => open,
            q_n     => C2A_q_n
        );

        hit_sound_en <= C2A_q_n;
        hit_sound    <= C2A_q_n; --vpos16 nand C2A_q_n;




    G4_LM555 : LM555_monostable 
        generic map(
            trigger_value => 3464956 --aprox .242s
        )
        port map(
            clk       => vid_sync.clk_14,
            trig      => miss_n,
            mono_out  => G4_out,
            control   => 0
        );
    sc <= G4_out;
    score_sound <= vid_sync.vertical.c32 nand G4_out;



end architecture;