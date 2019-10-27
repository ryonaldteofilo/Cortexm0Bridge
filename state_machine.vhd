------------------------------------
      -- state_machine --
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

entity state_machine is
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
end;

architecture statemachine of state_machine is
type state_type is (IDLE, PREFETCH, FETCH);
signal curstate, nextstate: state_type;

begin

dmai.address <= HADDR;
dmai.size <= HSIZE;
dmai.wdata <= HWDATA;
dmai.write <= HWRITE;
dmai.irq <= '0'
dmai.busy <= '0'
dmai.burst <= '0'

process(clkm, rstn)
  begin
    if rstn = '0' then
      curstate <= IDLE
    elsif rising_edge(clkm) then
      curstate <= nextstate
    end if;
end process;

process(curstate, HTRANS, dmao.ready)
  begin
        case curstate is
          when IDLE =>
            HREADY <= '1';
            dmai.start <= '0';
                  if HTRANS = "10" then
                      nextstate <= PREFETCH;
                  else
                      nextstate <= IDLE;
                  end if;

          when PREFETCH =>
            HREADY <= '1';
            dmai.start <= '1';
                  if HTRANS = "10" then
                      nextstate <= PREFETCH;
                  else
                      nextstate <= FETCH;
                  end if;

          when FETCH =>
            HREADY = '0';
            dmai.start <= '0';
                  if dmai.ready = '1' then
                      nextstate <= IDLE;
                  else
                      nextstate <= FETCH;
                  end if;
        end case;
end process;

end statemachine;
