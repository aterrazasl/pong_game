library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;


entity vertical_ball_control is
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
end vertical_ball_control;

architecture rtl of vertical_ball_control is

    function ls7450(a, b, c, d :std_logic) return std_logic is
    begin
        return not((a and b) or (c and d));
    end function;

    constant vertical_ball_count : integer := 255;
    signal A5B, A5B_d, A5A, A5A_d, B5A, B5A_d, B5A_n, H2A, H2A_n, H2A_n_2 : std_logic := '0';
    signal add_a, add_b : std_logic_vector(3 downto 0);
    signal attract_n , hit_n: std_logic;
    signal vblank_n,hsync_n, vblank,h256, h256_n, vvid_d, vvid_n, vvid_n_temp,vvid_n_temp2 : std_logic;
    signal v_ball_control : std_logic_vector(3 downto 0);
    signal LM55_out, LM55_out_n,LM55trig, H2A_clock : std_logic;
    signal clk, ff_t, ff_clk, ff_clk1, ff_clk2, ff_clk3 : std_logic := '0';
    signal ff_clk_sample : std_logic_vector(15 downto 0);
    signal ff_t_count : integer := 0;
    signal init_ff : std_logic := '0';

begin


    INIT_D_FF: sn7474
    Port map(
        clr_n   => '1',
        pr_n    => '1',
        clk     => vid_sync.vertical.c128,
        d       => '1',
        q       => init_ff,
        q_n     => open
    );


    vblank_n <= not(vid_sync.vertical.blank) and init_ff;
    hsync_n <= not(vid_sync.hsync);
    vblank <= vid_sync.vertical.blank;
    h256 <= vid_sync.horizontal.c256;
    h256_n <= not(h256);
    attract_n <= not( attract); 
    hit_n <= not hit;
    A5B_d <= ls7450(paddle1_count(1), h256_n, paddle2_count(1), h256);
    A5A_d <= ls7450(paddle1_count(2), h256_n, paddle2_count(2), h256);
    B5A_d <= ls7450(paddle1_count(3), h256_n, paddle2_count(3), h256);

    A5B_D_FF: sn7474
    Port map(
        clr_n   => attract_n,
        pr_n    => '1',
        clk     => hit,
        d       => A5B_d,
        q       => A5B,
        q_n     => open
    );

    A5A_D_FF: sn7474
    Port map(
        clr_n   => attract_n,
        pr_n    => '1',
        clk     => hit,
        d       => A5A_d,
        q       => A5A,
        q_n     => open
    );

    B5A_D_FF: sn7474
    Port map(
        clr_n   => attract_n,
        pr_n    => '1',
        clk     => hit,
        d       => B5A_d,
        q       => B5A,
        q_n     => B5A_n
    );

    


    clk <= vid_sync.clk_14;
    H2A   <= '0' when hit_n = '0' else ff_t; -- and not clr_n;
    H2A_n <= '1' when hit_n = '0' else (not ff_t) ; --  or (not clr_n);
    JK_FF_PROC : process(clk)
    begin
        if rising_edge(clk) then
            if ff_t_count < 14318000/2 then
                ff_t_count <= ff_t_count + 1;
                ff_t <= ff_t;
            elsif vvid_d = '1' and vblank = '1' then
                        ff_t_count <= 0;
                        ff_t <= not ff_t;
            end if;
        end if;
    end process;

    add_a(0) <= A5B xor H2A;
    add_a(1) <= A5A xor H2A;
    add_a(2) <= ls7450(H2A, B5A, B5A_n, H2A_n);
    add_a(3) <= '0';

    add_b(0) <= not(add_a(2));
    add_b(1) <= '1';
    add_b(2) <= '1';
    add_b(3) <= '0';


    v_ball_control <= std_logic_vector( unsigned(add_a) + unsigned(add_b) );
    ball_cntrl <= v_ball_control;

    VERTICAL_BALL_COUNTER : ball_position_counter 
    generic map(
        trigger_value => vertical_ball_count, -- value at which hvid_n goes low
        reset_value   => vertical_ball_count  -- value at which the counter reloads the load_value
    )
    port map(
        clk           => hsync_n,
        clr_n         => '1',
        enable        => vblank_n,
        load_value    => "000000000000" & v_ball_control,
        pos_counter   => vert_pos_counter,
        trigger_n     => vvid_n
    );

    -- when the ball is moving fast vvid never enter vblank, this delays vvid two clocks to detect it
    VVID_DELAY_PROC : process(hsync_n)
    begin
        if rising_edge(hsync_n) then
            vvid_n_temp <= vvid_n; 
            vvid_n_temp2 <= vvid_n_temp;
        end if;
    end process;

    vvid_d <= not(vvid_n and vvid_n_temp and vvid_n_temp2);    
    vvid   <= vvid_d;    
end architecture;