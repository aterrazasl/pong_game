library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

entity net_generation is
    port (
        vid_sync    : in video_sync_type;
        video_net   : out std_logic
    );
end net_generation;

architecture rtl of net_generation is
    signal JK_FF_n, k : std_logic;
    begin
        k <= not(vid_sync.horizontal.c256);
        JK_FF : sn74107a
            port map(
                clk=> vid_sync.clk_7,
                clr_n=> '1',
                j=> vid_sync.horizontal.c256,
                k => k,
                q=> open,
                q_n => JK_FF_n
            );

        video_net <= not((vid_sync.horizontal.c256 nand JK_FF_n) or 
                        vid_sync.vertical.blank or vid_sync.vertical.c4);

end architecture;