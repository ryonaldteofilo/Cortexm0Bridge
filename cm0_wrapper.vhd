---------------------------------------------
        -- cm0_wrapper --
---------------------------------------------

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

entity cm0_wrapper is
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    cm0_led : out std_logic
  );
end cm0_wrapper;

architecture cm0wrapper of cm0_wrapper is
  signal HADDR : std_logic_vector(31 downto 0);
  signal HSIZE : std_logic_vector(2 downto 0);
  signal HTRANS : std_logic_vector(1 downto 0);
  signal HWDATA : std_logic_vector(31 downto 0);
  signal HWRITE : std_logic;
  signal HRDATA : std_logic_vector(31 downto 0);
  signal HREADY : std_logic;
  signal LEDLIT : std_logic;


-- Declaring Components of cm0_wrapper --

component CORTEXM0DS is
  port(
    HCLK : in std_logic;
    HRESETn : in std_logic;
    HADDR : out std_logic_vector(31 downto 0);
    HSIZE : out std_logic_vector(2 downto 0);
    HTRANS : out std_logic_vector(1 downto 0);
    HWDATA : out std_logic_vector(31 downto 0);
    HWRITE : out std_logic;
    HRDATA : in std_logic_vector(31 downto 0);
    HREADY : in std_logic;
    HRESP: in std_logic;
    NMI : in std_logic;
    IRQ : in std_logic_vector(15 downto 0);
    RXEV : in std_logic
  );
end component;

component AHB_bridge is
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    HADDR : in std_logic_vector(31 downto 0);
    HSIZE : in std_logic_vector(2 downto 0);
    HTRANS : in std_logic_vector(1 downto 0);
    HWDATA : in std_logic_vector(31 downto 0);
    HWRITE : in std_logic;
    HRDATA : out std_logic_vector(31 downto 0);
    HREADY : out std_logic;
    ahbmo : out ahb_mst_out_type;
    ahbmi : in ahb_mst_in_type
  );
end component;

begin

-- cm0_led blinking as it detects F0F0F0F0 in HRDATA --
ledblink: process (HRDATA, LEDLIT, clkm)
begin
    if falling_edge(clkm) then
      if HRDATA = "11110000111100001111000011110000" then
        LEDLIT <= '1';
      else
        LEDLIT <= '0';
      end if;
  end if;
end process;
cm0_led <= LEDLIT;


-- PORT MAPPING for CORTEX M0 --
-- any unused input in the CORTEX M0 ports are connected to '0' to prevent errors --
cortexm0: CORTEXM0DS 
  port map(
    HCLK => clkm,
    HRESETn => rstn,
    HADDR => HADDR,
    HSIZE => HSIZE,
    HTRANS => HTRANS,
    HWDATA => HWDATA,
    HWRITE => HWRITE,
    HRDATA => HRDATA,
    HREADY => HREADY,
    HRESP => '0',
    NMI => '0',
    IRQ => (others=>'0'),
    RXEV => '0'
  );

-- PORT MAPPING for AHB BRIDGE --
ahbbridge: AHB_bridge
  port map(
      clkm => clkm,
      rstn => rstn,
      HADDR => HADDR,
      HSIZE => HSIZE,
      HTRANS => HTRANS,
      HWDATA => HWDATA,
      HWRITE => HWRITE,
      HRDATA => HRDATA,
      HREADY => HREADY,
      ahbmo => ahbmo,
      ahbmi => ahbmi
  );

end cm0wrapper;
