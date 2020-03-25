# Cortexm0_bridge
System-on-Chip design for Cortex M0

The main task was to replace a SPARC Leon3 processor with ARM’s Cortex M0 while still using an existing SoC infrastructure. As the two processors use different type of interface (Leon3 uses AHB interface and Cortex M0 uses AHB lite), a bridge must be designed to “translate” the given instructions of Cortex M0 to the AMBA bus. In this project, ModelSim and Xilinx ISE are used for design and simulation.
