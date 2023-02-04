library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity score_display is
    port (
        vid_sync    : in video_sync_type;
        srst        : in std_logic;
        missed      : in std_logic;
        left        : in std_logic;
        right       : in std_logic;
        score       : out std_logic;
        stopg1_n    : out std_logic;
        stopg2_n    : out std_logic
    );
end score_display;

architecture rtl of score_display is
    component bcd_counter is
        port (
            clk_n   : in std_logic;
            rst     : in std_logic;
            stopg_n : out std_logic;
            dig0    : out std_logic_vector(3 downto 0);
            dig1    : out std_logic_vector(3 downto 0)
        );
    end component;

    signal e5c, d2b, e5b, e2a, d4a, d5c, c4c, d5a, d4c, d4b, d5b : std_logic :='0';
    signal h4, h8, h16, h32, h64, h128, h256 : std_logic :='0';
    signal v4, v8, v16, v32, v64, v128 : std_logic :='0';
    signal seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g : std_logic := '0';
    signal e3a, e3b, e2c, e3c, d2c, c5_en : std_logic :='0';

    signal seven_segments : std_logic_vector(6 downto 0) := "0000000";  --output of BDC to  7 segments
    signal score_bcd : std_logic_vector(3 downto 0) := "0001";  -- output for mux
    signal score1_10, score2_10, score1, score2 : std_logic_vector(3 downto 0);  -- tracks the score digits
    signal mux_ab : std_logic_vector(1 downto 0) := "00";
    signal F5A, F5B: std_logic :='0';

begin

    F5A <= not(missed or right);
    F5B <= not(missed or left);

    
    SCORE1_COUNT: bcd_counter
    port map(
        clk_n   => F5B,
        rst => srst,
        stopg_n => stopg1_n,
        dig0    => score1,
        dig1    => score1_10
    );
    
    SCORE2_COUNT: bcd_counter
    port map(
        clk_n   => F5A,
        rst => srst,
        stopg_n => stopg2_n,
        dig0    => score2,
        dig1    => score2_10
    );


    --Multiplexer for score digits
    mux_ab <= h64 & h32;
    score_bcd <= score1_10  when mux_ab = "00" else
                 score1     when mux_ab = "01" else
                 score2_10  when mux_ab = "10" else
                 score2     when mux_ab = "11";


    -- BDC to 7 seg
    seven_segments <= "0000000" when c5_en = '0' else
                      "0111111" when c5_en = '1' and score_bcd ="0000" else
                      "0000110" when c5_en = '1' and score_bcd ="0001" else
                      "1011011" when c5_en = '1' and score_bcd ="0010" else
                      "1001111" when c5_en = '1' and score_bcd ="0011" else
                      "1100110" when c5_en = '1' and score_bcd ="0100" else
                      "1101101" when c5_en = '1' and score_bcd ="0101" else
                      "1111100" when c5_en = '1' and score_bcd ="0110" else
                      "0000111" when c5_en = '1' and score_bcd ="0111" else
                      "1111111" when c5_en = '1' and score_bcd ="1000" else
                      "1100111" when c5_en = '1' and score_bcd ="1001" else
                      "1011000" when c5_en = '1' and score_bcd ="1010" else
                      "1001100" when c5_en = '1' and score_bcd ="1011" else
                      "1100010" when c5_en = '1' and score_bcd ="1100" else
                      "1101001" when c5_en = '1' and score_bcd ="1101" else
                      "1111000" when c5_en = '1' and score_bcd ="1110" else
                      "0000000" when c5_en = '1' and score_bcd ="1111";
    seg_a <= seven_segments(0);
    seg_b <= seven_segments(1);
    seg_c <= seven_segments(2);
    seg_d <= seven_segments(3);
    seg_e <= seven_segments(4);
    seg_f <= seven_segments(5);
    seg_g <= seven_segments(6);


    -- mapping needed for the display score
    v4  <= vid_sync.vertical.count(2);
    v8  <= vid_sync.vertical.count(3);
    v16 <= vid_sync.vertical.count(4);
    v32 <= vid_sync.vertical.count(5);
    v64 <= vid_sync.vertical.count(6);
    v128 <= vid_sync.vertical.count(7);

    h4  <= vid_sync.horizontal.count(2);
    h8  <= vid_sync.horizontal.count(3);
    h16 <= vid_sync.horizontal.count(4);
    h32 <= vid_sync.horizontal.count(5);
    h64 <= vid_sync.horizontal.count(6);
    h128 <= vid_sync.horizontal.count(7);
    h256 <= vid_sync.horizontal.count(8);

    --Comb Logic to generate the score video
    e5c <= not(not(h16) or h4 or h8);
    d2b <= not(not(h4 and h8) or not(h16));
    e5b <= not(v8 or v4 or not(h16));
    e2a <= not(v4 and v8 and h16);

    d4a <= not(not(v16) and     seg_f   and e5c);
    d5c <= not(seg_e    and     v16     and e5c);
    c4c <= not(d2b      and not(v16)    and seg_b);
    d5a <= not(d2b      and     seg_c   and v16);
    d4c <= not(seg_a    and not(v16)    and e5b);
    d4b <= not(seg_g    and not(e2a)    and not(v16));
    d5b <= not(not(e2a) and     v16     and seg_d);
    
    score <= not(d4a and 
                 d5c and 
                 c4c and 
                 d5a and 
                 d4c and 
                 d4b and 
                 d5b); 



    -- sync with video sync
    e3a <= not(h128);
    e3b <= not(h256 or h64 or e3a);
    e2c <= not(e3a and h64 and h256);
    e3c <= not(e2c);
    d2c <= not(e3b or e3c);
    c5_en <= not(not(v32) or v64 or v128 or d2c);

                 
end architecture;