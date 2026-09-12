# RTL Neural Network Accelerator

A parameterized neural network inference accelerator designed and implemented from scratch using **Verilog HDL**, with a strong focus on RTL architecture, fixed-point arithmetic, memory organization, parallel computation, and hardware-oriented neural network execution.

This project explores how a software-defined neural network can be mapped into a structured digital hardware architecture suitable for FPGA implementation.

---

## Project Overview

The objective of this project is to design the core hardware architecture required to perform neural network inference directly in RTL.

Instead of executing the neural network through software, the computational operations are mapped into dedicated hardware blocks including:

* Input RAM
* Weight ROM
* Bias ROM
* Multiply-Accumulate datapaths
* Parallel Neuron Processing
* ReLU Activation
* Fixed-Point Requantization
* Multi-Layer Data Streaming
* Control and Sequencing Logic

The architecture is parameterized to support different input widths, layer sizes, and numbers of neurons.

---

# Architecture

The accelerator is organized around a sequential multi-layer neural network architecture.

```text
                         Input Data
                             |
                             v
                      +-------------+
                      |   Input RAM |
                      +-------------+
                             |
                             v
                 +------------------------+
                 | Parallel Neuron Array  |
                 |                        |
                 |    X × W + Bias        |
                 +-----------+------------+
                             |
                             v
                      +-------------+
                      |    ReLU     |
                      +-------------+
                             |
                             v
                     +---------------+
                     | Requantization|
                     | Shift + Satur.|
                     +-------+-------+
                             |
                             v
                      +-------------+
                      | Layer Output|
                      +------+------+
                             |
                             v
                       Next Layer
                             |
                             v
                            ...
                             |
                             v
                       Final Output
```

## Architecture Diagram

The complete RTL architecture is shown below.

<p align="center">
  <img width="1536" height="1024" alt="Architecture" src="https://github.com/user-attachments/assets/e81d85db-d979-4477-9519-51a6eec42e95" />
</p>

---

# Neural Network Structure

The current implementation contains multiple fully connected layers.

Example configuration:

```text
Input Layer
    |
    v
Layer 0
8 Inputs  -> 10 Neurons
    |
    v
Layer 1
10 Inputs -> 5 Neurons
    |
    v
Layer 2
5 Inputs  -> 3 Neurons
    |
    v
Output Layer
3 Inputs  -> 1 Neuron
```

The number of neurons and input dimensions are controlled through Verilog parameters.

Example:

```verilog
parameter WIDTH = 8;
parameter DEPTH = 8;
parameter No_Neuron_0 = 10;
parameter No_Neuron_1 = 5;
parameter No_Neuron_2 = 3;
parameter No_Neuron_3 = 1;
```

This allows the same RTL architecture to be reused for different neural-network configurations.

---

# Main Hardware Blocks

## 1. X_RAM

`X_RAM` stores the input vector of each neural-network layer.

Its main responsibilities include:

* Receiving input data.
* Storing values according to the provided RAM address.
* Reading the stored input vector sequentially.
* Generating the corresponding weight address.
* Generating the control signal required to start neural computation.

Main signals include:

```text
IN
IN_Valid
RAM_ADDR
X
X_Valid
W_Addr
```

The block provides the input data stream required by the neuron processing elements.

---

## 2. W_ROM

`W_ROM` stores the neural-network weights.

Each neuron accesses the appropriate weight corresponding to the current input element.

The basic computational relationship is:

```text
Input X
   |
   v
X × W
   |
   v
Accumulator
```

The weight memory is enabled during the neural computation phase.

---

## 3. Bias ROM

The project includes two bias-memory implementations.

### B_ROM

`B_ROM` provides the biases for all neurons simultaneously as a packed vector.

```text
B[0]  -> Neuron 0
B[1]  -> Neuron 1
B[2]  -> Neuron 2
...
B[N]  -> Neuron N
```

### Bias_Rom

`Bias_Rom` provides a single bias value according to a read address.

This implementation is used by the final single-neuron layer.

---

# 4. Neuron Processing Element

The `Neuron` module represents the core computational unit.

The neuron performs a multiply-accumulate operation across the complete input vector and then adds the corresponding bias.

Mathematically:

```text
Result = Σ(Xi × Wi) + Bias
```

Conceptually:

```text
X0 × W0
    |
    v
  MAC
    |
X1 × W1
    |
    v
  MAC
    |
   ...
    |
Xn × Wn
    |
    v
Accumulator
    |
    v
 + Bias
    |
    v
Neuron Result
```

The neuron generates a `Done` signal when the complete accumulation operation has finished.

---

# 5. Parallel Neuron Architecture

The `Multi_Neuron` module instantiates multiple neuron processing elements in parallel.

For a layer containing multiple neurons:

```text
                         Input X
                            |
          +-----------------+-----------------+
          |                 |                 |
          v                 v                 v
      Neuron 0          Neuron 1          Neuron 2
          |                 |                 |
          v                 v                 v
        ReLU              ReLU              ReLU
          |                 |                 |
          v                 v                 v
    Requantize        Requantize        Requantize
          |                 |                 |
          +-----------------+-----------------+
                            |
                            v
                       Layer Output
```

All neurons process the same input stream while using their own stored weights and biases.

The number of neurons is parameterized using:

```verilog
parameter No_Neuron
```

This allows the processing array to scale according to the required neural-network layer.

---

# 6. ReLU Activation

The `RELU` module implements the Rectified Linear Unit activation function directly in RTL.

The mathematical definition is:

```text
ReLU(x) = max(0, x)
```

Equivalent representation:

```text
        x,  x > 0
f(x) =
        0,  x <= 0
```

The activation function is therefore executed directly by hardware without requiring software intervention.

---

# 7. Requantization

The multiplication and accumulation operations increase the required bit width of the intermediate results.

For example:

```text
8-bit Input
     ×
8-bit Weight
     |
     v
16-bit Product
     |
     v
Accumulator
     |
     v
Higher-Width Result
```

The `Requantize` module converts the wider result back to the required output width.

The current implementation uses:

```text
Arithmetic Right Shift
        +
Saturation
        +
Width Reduction
```

Conceptually:

```text
Wide Accumulator
       |
       v
Arithmetic Shift
       |
       v
Saturation
       |
       v
Output Width
```

Saturation prevents overflow from wrapping around and generating an incorrect numerical result.

The shift amount is configurable through:

```verilog
parameter SHIFT = 4;
```

---

# 8. Multi-Layer Architecture

The `Leyars` module connects the neural-network layers together.

The output of one layer becomes the input of the following layer.

```text
              +----------------+
Input ------->|    Layer 0     |
              |   10 Neurons   |
              +-------+--------+
                      |
                      v
              +----------------+
              |    Layer 1     |
              |    5 Neurons   |
              +-------+--------+
                      |
                      v
              +----------------+
              |    Layer 2     |
              |    3 Neurons   |
              +-------+--------+
                      |
                      v
              +----------------+
              |  Output Layer  |
              |    1 Neuron    |
              +-------+--------+
                      |
                      v
                 Final Output
```

The layers communicate using control and address signals including:

```text
IN_Valid
wr_en
RAM_ADDR
Address
```

This allows each layer to write its generated outputs into the input memory of the following layer.

---

# Dataflow

The complete inference dataflow is:

```text
Input Vector
     |
     v
Input RAM
     |
     v
Read X
     |
     +---------------> Weight ROM
     |
     v
Parallel MAC
     |
     v
Add Bias
     |
     v
ReLU
     |
     v
Requantization
     |
     v
Layer Output
     |
     v
Next Layer RAM
     |
     v
Repeat
     |
     v
Final Output
```

---

# Fixed-Point Arithmetic

The accelerator uses fixed-width integer arithmetic rather than floating-point computation.

The current default configuration uses:

```text
Input Width  = 8 bits
Weight Width = 8 bits
Bias Width   = 8 bits
Output Width = 8 bits
```

Intermediate signals use wider data paths to accommodate multiplication and accumulation.

After activation, the result is requantized back to the required output width.

This hardware-oriented approach reduces the complexity of the datapath compared with floating-point implementations and provides explicit control over numerical precision.

---

# Parameterization

The architecture is designed to be configurable through Verilog parameters.

Important parameters include:

| Parameter   | Description                                |
| ----------- | ------------------------------------------ |
| `WIDTH`     | Input, weight, bias, and output data width |
| `DEPTH`     | Number of inputs to a layer                |
| `No_Neuron` | Number of neurons in a layer               |
| `SHIFT`     | Requantization arithmetic shift amount     |

Example:

```verilog
Multi_Neuron #(
    .WIDTH(8),
    .DEPTH(8),
    .No_Neuron(10)
)
layer_0 (
    .clk(clk),
    .rst(rst),
    ...
);
```

This makes the architecture reusable for different fully connected neural-network configurations.

---

# RTL Design Philosophy

The project focuses on understanding how neural-network algorithms can be translated into real digital hardware.

The main design considerations are:

* Parameterized RTL
* Modular architecture
* Parallel processing
* Memory organization
* Signed arithmetic
* Bit-width management
* Fixed-point computation
* Saturation
* Data movement
* Layer-to-layer streaming
* Explicit control signals
* Reusable processing elements

The objective is to develop the architecture from a hardware perspective rather than simply translating software code into Verilog.

---

# Module Hierarchy

The main RTL hierarchy is:

```text
Leyars
 |
 +-- Multi_Neuron
 |    |
 |    +-- X_RAM
 |    |
 |    +-- B_ROM
 |    |
 |    +-- W_ROM
 |    |
 |    +-- Neuron
 |    |
 |    +-- RELU
 |    |
 |    +-- Requantize
 |
 +-- Multi_Neuron
 |    |
 |    +-- X_RAM
 |    +-- B_ROM
 |    +-- W_ROM
 |    +-- Neuron
 |    +-- RELU
 |    +-- Requantize
 |
 +-- Multi_Neuron
 |
 +-- Single_Neuron
      |
      +-- X_RAM
      +-- W_ROM
      +-- Bias_Rom
      +-- Neuron
      +-- RELU
      +-- Requantize
```

---

# Simulation Results

The following waveforms demonstrate the RTL simulation and the output generation of the different neural-network layers.

## Layer 0 — Waveform

The waveform below shows the input loading, neural computation, control signals, and output generation of the first layer.

<p align="center">
  <img width="1890" height="954" alt="Leyar_0" src="https://github.com/user-attachments/assets/d57d876e-1316-43cf-bd95-2c5322918aed" />
</p>

---

## Layer 1 — Waveform

The waveform below shows the output generation of the second neural-network layer.

<p align="center">
  <img width="1890" height="968" alt="Leyar_1" src="https://github.com/user-attachments/assets/5a373a46-cfbb-473b-b594-7792941fa5d7" />
</p>

---

## Layer 2 — Waveform

The waveform below shows the operation and output generation of the third neural-network layer.

<p align="center">
  <img width="1805" height="966" alt="Leyar_2" src="https://github.com/user-attachments/assets/da75bc02-f8bb-4c3e-9030-ef8390707db7" />
</p>

---

## Output Layer — Waveform

The waveform below shows the final layer and generation of the final neural-network output.

<p align="center">
  <img width="1804" height="915" alt="out_leyar" src="https://github.com/user-attachments/assets/6c577b75-da29-4f3c-8a2d-2821fe0b9bee" />
</p>

---

# FPGA Design Results

## Elaboration

The elaborated RTL design demonstrates the generated hardware hierarchy and instantiated neural-network processing elements.

<p align="center">
  <img width="1526" height="502" alt="Elab" src="https://github.com/user-attachments/assets/1c32d47f-69da-4ec8-916f-e9f4222ea208" />
</p>

The elaboration view provides a structural representation of the parameterized RTL architecture before synthesis and implementation.

---

## Implementation

The implementation result shows the mapped FPGA design after synthesis, placement, and routing.

<p align="center">
  <img width="511" height="766" alt="Imple" src="https://github.com/user-attachments/assets/38d4492b-45f5-4f92-8505-aa1e06915a0c" />

</p>

The implementation stage is used to evaluate the physical realization of the accelerator on the target FPGA, including resource utilization and timing characteristics.

---

# Verification

The RTL architecture is verified through simulation before FPGA implementation.

The verification flow focuses on:

```text
Input Loading
     |
     v
Memory Access
     |
     v
MAC Computation
     |
     v
Bias Addition
     |
     v
ReLU Activation
     |
     v
Requantization
     |
     v
Layer Transition
     |
     v
Final Output
```

Simulation can be performed using HDL simulation tools such as **QuestaSim**.

---

# FPGA Implementation Flow

The intended FPGA development flow is:

```text
Verilog RTL
    |
    v
RTL Simulation
    |
    v
Elaboration
    |
    v
Synthesis
    |
    v
Implementation
    |
    v
Timing Analysis
    |
    v
Bitstream Generation
    |
    v
FPGA Hardware
```

The implementation stage can be used to evaluate:

* LUT utilization
* Flip-Flop utilization
* BRAM utilization
* Maximum operating frequency
* Timing
* Latency
* Throughput
* Power estimation

---

# Repository Structure

```text
RTL-Neural-Network-Accelerator/
│
├── RTL/
│   ├── X_RAM.v
│   ├── W_ROM.v
│   ├── B_ROM.v
│   ├── Bias_Rom.v
│   ├── Neuron.v
│   ├── RELU.v
│   ├── Requantize.v
│   ├── Single_Neuron.v
│   ├── Multi_Neuron.v
│   └── Leyars.v
│
├── TB/
│   └── Neural_Network_TB.v
│
├── Documentation/
│   ├── Architecture/
│   │   └── AI_Accelerator_Architecture.png
│   │
│   ├── Waveforms/
│   │   ├── Layer_0_Waveform.png
│   │   ├── Layer_1_Waveform.png
│   │   ├── Layer_2_Waveform.png
│   │   └── Output_Layer_Waveform.png
│   │
│   └── FPGA/
│       ├── Elaboration.png
│       └── Implementation.png
│
├── Constraints/
│   └── constraints.xdc
│
└── README.md
```

---

# Technologies

* Verilog HDL
* RTL Design
* Digital Logic Design
* Fixed-Point Arithmetic
* Neural Network Hardware
* FPGA
* Hardware Acceleration
* QuestaSim
* Xilinx Vivado

---

# Project Goals

The long-term goal of this project is to evolve the current neural-network RTL architecture into a more complete and scalable **AI Hardware Accelerator**.

Future development will focus on:

* Computational efficiency
* Memory bandwidth
* Parallelism
* Hardware utilization
* Pipeline optimization
* Latency reduction
* Throughput improvement
* RTL verification
* FPGA resource optimization
* Scalable hardware architecture

The broader objective is to explore how machine-learning algorithms can be transformed into efficient, reliable, and scalable digital hardware architectures.

---

# Author

**Ziad Mohamed**

Electrical Engineering Student
Digital IC Design | RTL Design | FPGA | AI Hardware

---

# Keywords

`AI Hardware` `AI Accelerator` `RTL Design` `Verilog` `FPGA` `Digital IC Design` `VLSI` `Neural Network` `Hardware Acceleration` `Digital Design` `Fixed Point` `MAC` `ReLU` `ASIC` `Hardware Architecture` `Computer Architecture`
