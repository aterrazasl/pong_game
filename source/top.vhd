library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pong_pkg.all;

entity top is
    port (
        i_clock     : in  std_logic;   -- 125Mhz input clock from L16
        VGAports    : out Zybo_VGA_output_ports;
        btn         : in std_logic_vector(3 downto 0);
        led         : out std_logic_vector(3 downto 0)
    );
end top;

architecture Behavioral of top is

    signal clock_32  : std_logic;
    signal clock_14 : std_logic;
    signal video_out, video_net, score : std_logic;
    signal vid_sync : video_sync_type;
    signal stopg1_n, stopg2_n : std_logic;
    signal red, blue : std_logic_vector(5 downto 0);
    signal serve, attract, pad1, pad2 : std_logic := '0';
    signal paddle1_count, paddle2_count : std_logic_vector(3 downto 0);
    signal rst_speed, sc, hit1_n, hit2_n : std_logic;
    signal hit,vvid, vvid_n, hvid_n : std_logic;
    signal miss,  miss_n, missed, stop_g : std_logic;
    signal srst : std_logic;
    signal vert_pos_counter : std_logic_vector(15 downto 0);
    signal top_bot_hit_sound, hit_sound_en, hit_sound, score_sound, sound : std_logic;
    signal left, right : std_logic;
    signal led_tmp: std_logic_vector(3 downto 0);
begin

    vvid_n <= not(vvid);
    miss <= not(miss_n);
    miss_n <= vid_sync.horizontal.blank nand not(hvid_n);
    missed   <= (not(attract)) nand (not(miss_n));    
    
    -- Clock generation 14.318Mhz for pong game--
    -- 32Mhz for scandoubler --
    CLOCK_32MHZ :  clk_wiz_0
        port map (
            clk_out1 => clock_14,
            clk_out2 => clock_32,
            clk_in1  => i_clock
        );

    PONG_VIDEO_SYNC : video_sync
        port map(
        clk_in      => clock_14,
        vid_sync    => vid_sync
    );

    NET_GEN : net_generation
        port map(
            vid_sync    => vid_sync,
            video_net   => video_net
        );

   -- Score display
    SCORE_DSP : score_display
        port map(
            vid_sync => vid_sync,
            srst     => srst,
            score    => score,
            left     => left,
            right    => right,
            missed   => missed,
            stopg1_n => stopg1_n,
            stopg2_n => stopg2_n
        );    
        

    PADDLES_GEN : paddles_generation
        port map(
            vid_sync        => vid_sync,
            attract         => attract,
            control1        => 0, -- replace with data from controller
            control2        => 0,
            paddle1_count   => paddle1_count,
            paddle2_count   => paddle2_count,
            pad1            => pad1,
            pad2            => pad2
        );
        

    HOR_BALL_CNTRL : horizontal_ball_control 
        port map(
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
            debug       => led
        ); 

    VER_BALL_CNTRL : vertical_ball_control 
        port map (
            vid_sync    => vid_sync,
            hit         => hit,
            attract     => attract,
            vvid        => vvid,
            paddle1_count  => paddle1_count,
            paddle2_count  => paddle2_count,
            vert_pos_counter => vert_pos_counter,
            ball_cntrl => led_tmp
        );

        -- led <= hit & led_tmp(2 downto 0);
        -- led <= led_tmp; -- debugging vertical speed
        -- led <= left & right & hit & missed;

    GAME_CONTROL_MOD: game_control 
        port map(
            clk_14    => vid_sync.clk_14,
            stopg1_n  => stopg1_n,
            stopg2_n  => stopg2_n,
            coin      => btn(0),
            hvid_n    => hvid_n,
            vvid_n    => vvid_n,
            pad1      => pad1,
            pad2      => pad2,
            miss_n    => miss_n,
            rst_speed  => rst_speed,
            stop_g    => stop_g,
            serve     => serve,
            hit       => hit,
            attract  => attract,
            srst     => srst,
            hit1_n   => hit1_n,
            hit2_n   => hit2_n,
            run_in   => btn(1),
            net_in   => video_net
        );      


    SOUND_CNTRL: sound_control 
        port map(
            vid_sync            => vid_sync, 
            vert_pos_counter    => vert_pos_counter, 
            vvid                => vvid, 
            serve               => serve, 
            hit                 => hit, 
            miss                => miss, 
            attract             => attract, 
            top_bot_hit_sound   => top_bot_hit_sound, 
            hit_sound_en        => hit_sound_en, 
            hit_sound           => hit_sound, 
            score_sound         => score_sound, 
            sc                  => sc, 
            sound               => sound 
        );

    -- sum of video   
    video_out <=  not(hvid_n or vvid_n) or score or video_net or pad1 or pad2 ;
    
    VGAports.red    <= video_out & video_out & video_out & video_out & video_out;
    VGAports.green  <= video_out & video_out & video_out & video_out & video_out & video_out;
    VGAports.blue   <= video_out & video_out & video_out & video_out & video_out;
    VGAports.h_sync <= not(vid_sync.hsync);
    VGAports.v_sync <= not(vid_sync.vsync);
    


        --     -- Scandoubler generates signals for VGA --
        -- Scandoubler_mod : scandoubler
        --     port map (
        --         clk_sys     => clock_32,
        --         hs_in       => vid_sync.hsync,
        --         vs_in       => vid_sync.vsync,
        --         r_in        => video_out & video_out & video_out & video_out & video_out & video_out,
        --         g_in        => video_out & video_out & video_out & video_out & video_out & video_out,
        --         b_in        => video_out & video_out & video_out & video_out & video_out & video_out,
        --         hs_out      => VGAports.h_sync,
        --         vs_out      => VGAports.v_sync,
        --         r_out       => red,
        --         g_out       => VGAports.green,
        --         b_out       => blue
        --     );

        -- VGAports.red        <= red (4 downto 0);
        -- VGAports.blue       <= blue(4 downto 0);
    
end Behavioral;
