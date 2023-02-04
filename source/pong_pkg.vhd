library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Package Declaration Section
package pong_pkg is

    constant ClockPeriod_3M  : TIME := 333 ns;
    constant ClockPeriod_6M  : TIME := 166.66666666 ns; --333 ns;
    constant ClockPeriod_32M : TIME := 31.25 ns;

    type VGA_output_ports is record
        h_sync			: std_logic;
        v_sync			: std_logic;
        red             : std_logic_vector (5 downto 0);
        green           : std_logic_vector (5 downto 0);
        blue            : std_logic_vector (5 downto 0);
    end record;

    -- Type used in the top VHDL from Zybo board, difference is that blue and red uses 5 bits insted of 6 like in green -- 
    type Zybo_VGA_output_ports is record
        h_sync			: std_logic;
        v_sync			: std_logic;
        red             : std_logic_vector (4 downto 0);
        green           : std_logic_vector (5 downto 0);
        blue            : std_logic_vector (4 downto 0);
    end record;

    type Zybo_DIP_SWITCH is record
        num_tanks   	: std_logic;
        bonus			: std_logic_vector (1 downto 0);
        game_fee        : std_logic_vector (1 downto 0);
    end record;

    type Zybo_CONTROLS is record
        up   	        : std_logic;
        left	        : std_logic;
        down            : std_logic;
        right           : std_logic;
        shoot           : std_logic;
        player1_start   : std_logic;
        coin_switch     : std_logic;
        test_switch     : std_logic;
    end record;

    type vh_sync_type is record
        count           : std_logic_vector(8 downto 0);
        c1              : std_logic;
        c2              : std_logic;
        c4              : std_logic;
        c8              : std_logic;
        c16             : std_logic;
        c32             : std_logic;
        c64             : std_logic;
        c128            : std_logic;
        c256            : std_logic;
        blank           : std_logic;
        reset           : std_logic;
    end record;

    type video_sync_type is record
        clk_14	        : std_logic;
        clk_7           : std_logic;
        vertical        : vh_sync_type;
        horizontal      : vh_sync_type;
        vsync           : std_logic;
        hsync           : std_logic;
    end record;


    component scandoubler
        port (
            clk_sys   : in std_logic ;
            hs_in     : in std_logic ;
            vs_in     : in std_logic ;
            r_in      : in std_logic_vector (5 downto 0);
            g_in      : in std_logic_vector (5 downto 0);
            b_in      : in std_logic_vector (5 downto 0);
            hs_out    : out std_logic ;
            vs_out    : out std_logic ;
            r_out     : out std_logic_vector (5 downto 0);
            g_out     : out std_logic_vector (5 downto 0);
            b_out     : out std_logic_vector (5 downto 0)
        );
    end component scandoubler;

    component video_sync is
        port (
            clk_in      : in std_logic;         -- clock input 14.318Mhz
            vid_sync    : out video_sync_type
        );
    end component video_sync;

    component sr_ff is
        port (
            clk : in std_logic;
            s_n : in std_logic;
            r_n : in std_logic;
            q   : out std_logic;
            q_n : out std_logic
        );
    end component sr_ff;

    component rs_ff is
        port (
            clk : in std_logic;
            r   : in std_logic;
            s   : in std_logic;
            q   : out std_logic;
            q_n : out std_logic
        );
    end component rs_ff;


    component net_generation is
        port (
            vid_sync    : in video_sync_type;
            video_net   : out std_logic
        );
    end component net_generation;

    component clk_wiz_0
        port (
            clk_out1 : out std_logic;
            clk_out2 : out std_logic;
            clk_in1  : in  std_logic
        );
    end component clk_wiz_0;

    component paddles_generation is
        port (
            vid_sync    : in video_sync_type;
            attract     : in std_logic;
            control1    : in integer;
            control2    : in integer;
            paddle1_count : out std_logic_vector(3 downto 0);
            paddle2_count : out std_logic_vector(3 downto 0);
            pad1        : out std_logic;
            pad2        : out std_logic
        );
    end component paddles_generation;
    
    component score_display is
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
    end component;

    component sn74107a is
        port (
            clk : in std_logic;
            clr_n : in std_logic;
            j   : in std_logic;
            k   : in std_logic;
            q   : out std_logic;
            q_n : out std_logic
        );
    end component;

    component sn7474
        Port (
            clr_n   : in std_logic;
            pr_n    : in std_logic;
            clk     : in std_logic;
            d       : in std_logic;
            q       : out std_logic;
            q_n     : out std_logic
        );
    end component sn7474;

    component video_sync_counter is
        generic (
            trigger_value : in integer range 0 to 511
        );    
        port (
            clk       : in std_logic;
            reset_out : out std_logic;
            count   : out std_logic_vector (8 downto 0)
        );
    end component video_sync_counter;    

    component ball_position_counter is
        generic (
            trigger_value : in integer range 0 to 65535; -- value at which hvid_n goes low
            reset_value   : in integer range 0 to 65535 -- value at which the counter reloads the load_value
        );
        port (
            clk           : in std_logic;
            clr_n         : in std_logic;
            enable        : in std_logic;
            load_value    : in std_logic_vector(15 downto 0); -- value at which the count starts at
            pos_counter   : out std_logic_vector(15 downto 0);
            trigger_n     : out std_logic
        );
    end component ball_position_counter;

    component vertical_ball_control is
        port (
            vid_sync            : in video_sync_type;
            hit                 : in std_logic;
            attract             : in std_logic;
            paddle1_count       : in std_logic_vector(3 downto 0);
            paddle2_count       : in std_logic_vector(3 downto 0);
            vvid                : out std_logic;
            vert_pos_counter    : out std_logic_vector(15 downto 0);
            ball_cntrl          : out std_logic_vector(3 downto 0)
        );
    end component vertical_ball_control; 
    
    component horizontal_ball_control is
        port (
            vid_sync    : in video_sync_type;
            rst_speed   : in std_logic;
            hit_sound   : in std_logic;
            sc          : in std_logic;
            attract     : in std_logic;
            serve       : in std_logic;
            hit1_n      : in std_logic;
            hit2_n      : in std_logic;
            hvid_n      : out std_logic;
            left        : out std_logic;
            right       : out std_logic;
            debug       : out std_logic_vector(3 downto 0)
        );
    end component horizontal_ball_control; 

    component LM555_monostable is
        generic (
            trigger_value : in integer 
        );
        port (
            clk      : in std_logic;
            trig     : in std_logic;
            mono_out : out std_logic;
            control  : in integer
        );
    end component LM555_monostable;

    component game_control is
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
    end component game_control;


    component sound_control is
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
    end component sound_control;

end package pong_pkg;

