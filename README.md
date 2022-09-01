## Cortexm0Bridge
SoC design for Cortex M0 <br />
<br />
Replace a SPARC Leon3 processor with ARM’s Cortex M0 while still using an existing SoC infrastructure. <br />
<br />
Since the two processors use different type of interface (Leon3 with AHB interface and Cortex M0 with AHB lite), a bridge must be made to “translate” the given instructions of Cortex M0 to the AMBA bus. ModelSim and Xilinx ISE are used for design and simulation.
