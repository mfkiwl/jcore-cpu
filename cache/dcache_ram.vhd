library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cache_pack.all;
use work.memory_pack.all;

entity dcache_ram is port (
   clk125 : in  std_logic;
   clk200 : in  std_logic;
   rst : in  std_logic;
   ra  : in  dcache_ram_i_t;
   ry  : out dcache_ram_o_t);
end dcache_ram;

architecture beh of dcache_ram is

signal tag_we0 : std_logic_vector( 1 downto 0);
signal tag_dr0 : std_logic_vector(15 downto 0);
signal tag_dw0 : std_logic_vector(15 downto 0);
signal tag_dr1 : std_logic_vector(15 downto 0);

begin

   tag0 : ram_1rw
    generic map (
     SUBWORD_WIDTH => 8,
     SUBWORD_NUM => 2,
     ADDR_WIDTH => 8)
    port map(
     rst => rst,
     clk => clk125,
     en  => ra.ten0,
     wr  => ra.twr0,
     we  => tag_we0,
     a   => ra.ta0,
     dw  => tag_dw0,                           -- 16 b => 1 b & 15 b
     dr  => tag_dr0,
     margin => "00" );

   tag1 : ram_1rw
    generic map (
     SUBWORD_WIDTH => 8,
     SUBWORD_NUM => 2,
     ADDR_WIDTH => 8)
    port map(
     rst => rst,
     clk => clk125,
     en  => ra.ten0,
     wr  => ra.twr0,
     we  => tag_we0,
     a   => ra.ta1,
     dw  => tag_dw0,                           -- 16 b => 1 b & 15 b
     dr  => tag_dr1,
     margin => "00" );

   tag_we0 <= ra.twr0 & ra.twr0;
   tag_dw0 <= '0'     & ra.tag0;
   ry.tag0 <= tag_dr0(14 downto 0);            -- 15 b => 16 b ( 15 b range)
   ry.tag1 <= tag_dr1(14 downto 0);            -- 15 b => 16 b ( 15 b range)

   ram : for i in 0 to 1 generate
     ram_s : ram_2rw
     generic map (
     SUBWORD_WIDTH => 8,
     SUBWORD_NUM => 2,
     ADDR_WIDTH => 11)
     port map(
     rst0 => rst, clk0 => clk125,
     en0  => ra.en0,
     wr0  => ra.wr0,
     we0  => ra.we0( 2 * i +  1 downto  2 * i),
     a0   => ra.a0,
     dw0  => ra.d0 (16 * i + 15 downto 16 * i),
     dr0  => ry.d0 (16 * i + 15 downto 16 * i),
     rst1 => rst, clk1 => clk200,
     en1  => ra.en1,
     wr1  => ra.wr1,
     we1  => ra.we1( 2 * i +  1 downto  2 * i),
     a1   => ra.a1,
     dw1  => ra.d1 (16 * i + 15 downto 16 * i),
     dr1  => open,
     margin0 => '0',
     margin1 => '0' );
   end generate;

end beh;
