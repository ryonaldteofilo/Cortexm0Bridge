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
      dmao : in ahb_dma_out_type
  );
end state_machine;

architecture statemachine of state_machine is
type state_type is (IDLE, PREFETCH, FETCH);
signal curstate, nextstate: state_type;

begin

dmai.address <= HADDR;
dmai.size <= HSIZE;
dmai.wdata <= HWDATA;
dmai.write <= HWRITE;
dmai.irq <= '0';
dmai.busy <= '0';
dmai.burst <= '0';

process(clkm, rstn)
  begin
    if rstn = '0' then
      curstate <= IDLE;
    elsif rising_edge(clkm) then
      curstate <= nextstate;
    end if;
end process;

-- State Machine for AHB Bridge --
process(curstate, HTRANS, dmao.ready)
  begin
        case curstate is
          when IDLE =>
            HREADY <= '1';  
            dmai.start <= '0';
                  if HTRANS = "10" then            -- HREADY is set to '1' to indicate that the AHB-lite bus is ready to accept an address phase --      
                      nextstate <= PREFETCH;       -- When HTRANS is set to '10', it means that Cortex M0 is ready to do data transfer --
                  else                             -- Thus when HTRANS is '10', nextstate will be PREFETCH --      
                      nextstate <= IDLE;
                  end if;

          when PREFETCH =>                          -- Went with Moore machine to avoid timing issues --
            HREADY <= '1';                          -- dmai.start is set to '1' in this state rather than in the previous state --
            dmai.start <= '1';                      -- dmai.start set to HIGH to signal the start of data transfer phase --
            nextstate <= FETCH;
                
          when FETCH =>                             -- HREADY is set to '0' to indicate that the bus is busy and not ready for another address phase --
            HREADY <= '0';                          -- dmao.ready is used to notify the state machine that data transfer is completed -- 
            dmai.start <= '0';                      -- Once dmao.ready is 1, it means that data transfer has been done --
                  if dmao.ready = '1' then          -- The nextstate goes back to IDLE to prepare for the next address phase and data transfer phase --
                      nextstate <= IDLE;
                  else
                      nextstate <= FETCH;
                  end if;
        end case;
end process;

end statemachine;
