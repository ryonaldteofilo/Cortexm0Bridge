------------------------------------
      -- data_swapper --
------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;

entity data_swapper is
  port(
    clkm : in std_logic;
    HRDATA : out std_logic_vector (31 downto 0);
    dmao : in ahb_dma_out_type
  );
end data_swapper;


-- Inverting the endianness of the data byte by byte, the upper 32 bits are ignored --
architecture dataswap of data_swapper is  
begin

  HRDATA(7 downto 0) <= dmao.rdata(31 downto 24);
  HRDATA(15 downto 8) <= dmao.rdata(23 downto 16);
  HRDATA(23 downto 16) <= dmao.rdata(15 downto 8);
  HRDATA(31 downto 24) <= dmao.rdata(7 downto 0);

end dataswap;
