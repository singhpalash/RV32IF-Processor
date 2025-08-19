# RV32IF Processor
Design and implementation of RV32IF Processor
 ## INTRODUCTION
This project presents the design and implementation of an RV32IF pipelined processor based on the RISC-V architecture. It includes full support for RV32I (integer instructions) and is being extended to support RV32F (floating-point instructions).

The processor is implemented entirely in Verilog, structured in a modular and synthesizable fashion. The design emphasizes clarity, reusability, and scalability, making it suitable for academic purposes and FPGA deployment.

## Key Features
 ### 1) 5-stage pipeline architecture: 

  - Instruction Fetch (IF)

  - Instruction Decode (ID)

  - Execute (EX)

  - Memory Access (MEM)

  - Write Back (WB)

 ### 2) RV32I instruction support:

  - Arithmetic and logic instructions

  - Load/store operations

  - Branches, jumps, and immediate variants

  - Basic RV32F support (in progress):

  - All instructions of base class supported except byte level load,store and system calls

 ### 3) Pipelined floating-point ALU for Add/Sub, Multiply, Div/Sqrt in floating point

  - Each operation (FADD.S, FSUB.S, FMUL.S, FDIV.S, FSQRT.S,FLW.S,FSW.S) is implemented in separate pipelined units to allow parallelism and reduce execution latency.

  - FP ALUs are designed to support multi-cycle operations using stage-wise handshaking, ensuring proper sequencing and pipeline flushing when needed.

 ### 4) Separate register files for integer and floating-point units
 
  - The processor uses dedicated register files for x0–x31 (integer) and f0–f31 (floating-point) as per RISC-V conventions, allowing parallel access without contention.

  - Each register file is dual-port, enabling simultaneous read/write operations essential for pipelined execution.

 ### 5) Integration of F-Class

 -  Design includes the design of seperate pipeline for f-class once the fact that it is floating point operation has been known using opcode in ID Stage of i class.

 - The neccesary details like opcode,function 7 fields are sent to f-class pipeline where we have seperate register bank for floating point numbers.

### 6) Inorder F-class

  - The current design has inorder f class with future work looking to incorporate out-of-order f class to reduce latency.

  - This inorder f-class pipeline is well balanced as each arithmetic instruction takes exactly 5 cycles

  - Also the floating point alu in itself is pipelined.

 ### 6) Hazard handling:

  - Basic data forwarding and hazard detection implemented for RV32I

  - Floating-point dependency hazard is handled using stall and then forwarding 

 ### 7) Memory modules:

  - Instruction and data memory implemented in Verilog

 ### 8) FPGA-ready:

  - Synthesizable design, compatible with FPGA platforms like ZedBoard, Spartan-3, or Virtex-7


## Usage Note

- The floating point instruction flw.s stalls the i-class pipeline as soon as it reaches ex stage of floating point pipeline so that overwriting by i-class sw could be avoided 

## Tools & Technologies

- Language: Verilog HDL

- Simulation: Vivado Simulator

- Synthesis: Xilinx Vivado

- Target FPGAs: ZedBoard, Spartan-3, Virtex-7
