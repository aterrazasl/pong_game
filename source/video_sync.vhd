library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity video_sync is
    port (
        clk_in      : in std_logic;         -- clock input 14.318Mhz
        vid_sync    : out video_sync_type
    );
end video_sync;

architecture rtl of video_sync is

    signal clk : std_logic;
    constant h_px : integer := 454;
    constant v_px : integer := 261;
    signal hreset,vreset : std_logic := '1';
    signal hblanking, h16, h64, hsync_n, h32 : std_logic;
    signal vblank, v256, v16, v8, vsync_n, v4 : std_logic;
    signal h_count, v_count : std_logic_vector (8 downto 0) := "000000000";
    signal s1_n, s2_n, r1_n, r2_n : std_logic;

begin

    CLK_DIV : sn74107a
        port map  (
            clk   => clk_in,
            clr_n => '1',
            j     => '1',
            k     => '1',
            q     => clk,
            q_n   => open
        );

    HORIZONTAL_COUNT_PROC : video_sync_counter 
        generic map(
            trigger_value => h_px
        )
        port map(
            clk       => clk, 
            reset_out => hreset,
            count     => h_count
        );

    h16  <= h_count(4);
    h32  <= h_count(5);
    h64  <= h_count(6);

    VERTICAL_COUNT_PROC : video_sync_counter 
        generic map(
            trigger_value => v_px
        )
        port map(
            clk       => hreset, 
            reset_out => vreset,
            count     => v_count
        );

    v4       <= v_count(2);
    v8       <= v_count(3);
    v16      <= v_count(4);
    v256     <= v_count(8);


    ---------------- Generation of blanking and sync ----------
    s1_n <= h16 nand h64;
    r1_n <= not(hreset);

    HBLANK_PROC  : sr_ff
        port map(
            clk => clk_in,
            s_n => s1_n,
            r_n => r1_n,
            q   => open,
            q_n => hblanking
        );

    
    s2_n <= v16;
    r2_n <= vreset;

    VBLANK_PROC : rs_ff
        port map(
            clk => clk_in,
            r   => r2_n,
            s   => s2_n,
            q   => open,
            q_n => vblank
        );
    
    hsync_n  <= not(hblanking and h32);
    vsync_n  <= not(vblank    and v4 and not(v8));


    ----------------------- map vid_sync----------------
    vid_sync.clk_14             <= clk_in;
    vid_sync.clk_7              <= clk;
    vid_sync.vsync              <= not(vsync_n);
    vid_sync.hsync              <= not(hsync_n);
    vid_sync.vertical.count     <= v_count;
    vid_sync.vertical.c1        <= v_count(0);
    vid_sync.vertical.c2        <= v_count(1);
    vid_sync.vertical.c4        <= v_count(2);
    vid_sync.vertical.c8        <= v_count(3);
    vid_sync.vertical.c16       <= v_count(4);
    vid_sync.vertical.c32       <= v_count(5);
    vid_sync.vertical.c64       <= v_count(6);
    vid_sync.vertical.c128      <= v_count(7);
    vid_sync.vertical.c256      <= v_count(8);
    vid_sync.vertical.reset     <= vreset;
    vid_sync.vertical.blank     <= vblank;
    vid_sync.horizontal.count   <= h_count;
    vid_sync.horizontal.c1      <= h_count(0);
    vid_sync.horizontal.c2      <= h_count(1);
    vid_sync.horizontal.c4      <= h_count(2);
    vid_sync.horizontal.c8      <= h_count(3);
    vid_sync.horizontal.c16     <= h_count(4);
    vid_sync.horizontal.c32     <= h_count(5);
    vid_sync.horizontal.c64     <= h_count(6);
    vid_sync.horizontal.c128    <= h_count(7);
    vid_sync.horizontal.c256    <= h_count(8);
    vid_sync.horizontal.reset   <= hreset;
    vid_sync.horizontal.blank   <= hblanking;    

end architecture;