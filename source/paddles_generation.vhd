library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity paddles_generation is
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
end paddles_generation;

architecture rtl of paddles_generation is
    component paddle 
        port (
            clk_14  : in std_logic;
            hsync_n : in std_logic;
            v256_n  : in std_logic;
            count   : out std_logic_vector(3 downto 0);
            vpad_n  : out std_logic
        );
    end component paddle;

    signal hsync_n, v256_n, vpad1_n, vpad2_n, attract_n, g3c, h3a_q_n : std_logic;

begin

    attract_n <= not(attract);
    v256_n    <= not(vid_sync.vertical.c256);
    hsync_n   <= not(vid_sync.hsync);

    --Paddles generation

    PADDLE1 : paddle 
        port map (
            clk_14  => vid_sync.clk_14, 
            hsync_n => hsync_n,
            v256_n  => v256_n,
            count   => paddle1_count,
            vpad_n  => vpad1_n
        );

    PADDLE2 : paddle 
        port map (
            clk_14  => vid_sync.clk_14, 
            hsync_n => hsync_n,
            v256_n  => v256_n,
            count   => paddle2_count,
            vpad_n  => vpad2_n
        );

    H3A_FFD : sn7474
        Port map(
            clr_n   => '1',
            pr_n    => attract_n, 
            clk     => vid_sync.horizontal.c4,
            d       => vid_sync.horizontal.c128,
            q       => open,
            q_n     => h3a_q_n
        );

    g3c <= vid_sync.horizontal.c128 nand h3a_q_n;
    
    pad1 <= not((    vid_sync.horizontal.c256  or vpad1_n) or g3c);
    pad2 <= not((not(vid_sync.horizontal.c256) or vpad2_n) or g3c);

end architecture;