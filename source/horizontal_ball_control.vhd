library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity horizontal_ball_control is
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
end horizontal_ball_control;

architecture rtl of horizontal_ball_control is
    
    function comb_logic(h256_n          : in std_logic;
                        vreset          : in std_logic;
                        counter_reset   : in std_logic;
                        count_slv       : in std_logic_vector(3 downto 0)) return std_logic_vector is
        variable G1D, H1D, H1B, H1C, G1C : std_logic;
        begin
            G1D := count_slv(2) or count_slv(3);
            H1D := (count_slv(2) nand count_slv(3)) nand G1D; --counter_reset nand G1D;
            H1B := G1D nand vreset;
            H1C := H1D nand vreset;
            G1C := not(h256_n or vreset);

            return G1C & H1C & H1B;
    end function;
    
    constant horizontal_ball_count : integer := 376;
    signal counter : integer range 0 to 15;
    signal comb_logic_out : std_logic_vector(2 downto 0);
    signal clk,  count_rst, move, H2A_q, H2B_q : std_logic;
    signal H3B_q, H3B_q_n, C1D : std_logic :='0';
    signal Aa, Bb, h256_n, vreset, clr_n, attract_n : std_logic;
    signal hblanking_n, hvid_n_temp, hvid_n_d, hvid_n_d2 : std_logic;

begin

    h256_n <= not(vid_sync.horizontal.c256);
    vreset <= vid_sync.vertical.reset;
    attract_n <= not(attract);
    clr_n <= attract_n nand serve;
    clk <= hit_sound nand count_rst;
    hblanking_n <= not(vid_sync.horizontal.blank);

    COUNTER_PROC : process(clk, rst_speed)
        begin
            if rst_speed = '1' then
                counter <= 0;
                count_rst <= '1';
            elsif falling_edge(clk) then
                if counter < 12 then
                    counter <= counter + 1;
                    count_rst <= '1';
                end if;
            end if;
        end process;

    debug <= std_logic_vector(to_unsigned(counter,4));
    comb_logic_out <= comb_logic(h256_n, vreset, count_rst, std_logic_vector(to_unsigned(counter, 4)));

    H2B_JK_ff : sn74107a 
        port map(
            clk    => comb_logic_out(2),
            clr_n  => comb_logic_out(1),
            j      => '1',
            k      => move,
            q      => H2B_q,
            q_n    => open
        );

    H2A_JK_ff : sn74107a 
        port map(
            clk    => comb_logic_out(2),
            clr_n  => comb_logic_out(0),
            j      => H2B_q,
            k      => '0',
            q      => H2A_q,
            q_n    => open
        );

    move <= H2B_q nand H2A_q; 


    C1D <= sc and attract;

    H3B_D_FF:  sn7474
        Port map(
            clr_n   => hit1_n,
            pr_n    => hit2_n,
            clk     => C1D,
            d       => H3B_q_n,
            q       => H3B_q,
            q_n     => H3B_q_n
        );

    left <= H3B_q;  --left
    right  <= H3B_q_n; -- right
    Aa <= (move nand H3B_q) nand (move nand H3B_q_n);
    Bb <= move nand H3B_q_n;


    HOR_BALL_COUNTER : ball_position_counter 
        generic map(
            trigger_value => horizontal_ball_count,  -- value at which hvid_n goes low
            reset_value   => horizontal_ball_count   -- value at which the counter reloads the load_value
        )
        port map(
            clk           => vid_sync.clk_7,
            clr_n         => clr_n,
            enable        => hblanking_n,
            load_value    => "00000000000000" & Bb & Aa,

            trigger_n     => hvid_n_temp
        );


    -- when the ball is moving fast hvid never enter hblank, this delays hvid two clocks to detect it
    HVID_DELAY_PROC : process(vid_sync.clk_7)
        begin
            if rising_edge(vid_sync.clk_7) then
                hvid_n_d <= hvid_n_temp;
                hvid_n_d2 <= hvid_n_d; 
            end if;
        end process;  
        
    hvid_n <= hvid_n_temp and hvid_n_d and hvid_n_d2;

end architecture;