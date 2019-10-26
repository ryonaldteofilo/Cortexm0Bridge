------------------------------------
      -- AHB_bridge --
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
entity AHB_bridge is
 port(
 -- Clock and Reset -----------------
 clkm : in std_logic;
 rstn : in std_logic;
 -- AHB Master records --------------
 ahbmi : in ahb_mst_in_type;
 ahbmo : out ahb_mst_out_type;
 -- ARM Cortex-M0 AHB-Lite signals --
 HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
 HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
 HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: nonsequential only
 HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
 HWRITE : in std_logic; -- AHB write control
 HRDATA : out std_logic_vector (31 downto 0); -- AHB read-data
 HREADY : out std_logic -- AHB stall signal
 );
end;

architecture structural of AHB_bridge is

signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;

-- declaring ports for components --

component state_machine
  port(
    HADDR : in std_logic_vector(31 downto 0);
    HSIZE : in std_logic_vector(2 downto 0);
    HTRANS : in std_logic_vector(1 downto 0);
    HWDATA : in std_logic_vector(31 downto 0);
    HWRITE : in std_logic;
    HREADY : out std_logic;
    clkm : in std_logic;
    rstn : in std_logic;
    dmai : out ahb_dma_in_type;
    dmao : in ahb_dma_out_type;
  );
end component;

component ahbmst
  port(
    dmai : in ahb_dma_in_type;
    dmao : out ahb_dma_out_type;
    clk : in std_logic;
    rst : in std_logic;
    ahbo : out ahb_mst_out_type;
    ahbi : in ahb_mst_in_type;
  );
end component;

component data_swapper
  port(
    HRDATA : out std_logic_vector(31 downto 0);
    clkm : in std_logic;
    dmao : in ahb_dma_out_type;
    );
end component;

begin
-- instantiating components a.k.a port mapping --
statemachine: state_machine
  port map(
    clkm => clkm,
    rstn => rstn,
    dmai => dmai,
    dmao => dmao,
    HADDR => HADDR,
    HSIZE => HSIZE,
    HTRANS => HTRANS,
    HWDATA => HWDATA,
    HWRITE => HWRITE,
    HREADY => HREADY,
  );

ahbmaster: ahbmst
  port map(
    clk => clkm,
    rst => rstn,
    dmai => dmai,
    dmao => dmao,
    ahbi => ahbmi,
    ahbo => ahbmo,
  );

dataswapper: data_swapper
  port map(
    clkm => clkm,
    dmao => dmao,
    HRDATA => HRDATA,
    );

end structural;
