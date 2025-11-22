# Local Binary Pattern (LBP) — Verilog Implementation

This project implements the **Local Binary Patterns (LBP)** algorithm in hardware using **Verilog**. It processes images through a full pipeline: **RGB → Gray → LBP**.  
LBP is a popular image feature extraction method widely used in face recognition, texture classification, and image analysis.

## Language Composition

- Verilog

---

## Example Pipeline

Below is a demonstration of the image pipeline:

![image](https://github.com/YuminChiang/LBP/blob/main/assets/image.png)

**(Left)** Original RGB image  
**(Center)** Grayscale conversion  
**(Right)** Result of LBP feature extraction

---

## Project Pipeline Overview

The procedure is divided into three major stages:

### 1. **RGB → Grayscale Conversion**

The module reads RGB image data (24 bits: R, G, B are each 8 bits) from memory and converts it to grayscale.  
A common grayscale conversion formula:

```
Gray = (R + G + B) / 3
```

Converted grayscale values are stored in internal memory (`gray_mem`) for later LBP computation.

---

### 2. **Gray → LBP**

LBP works by comparing a central pixel to its 8 neighbors.  
For each neighbor, if the pixel value ≥ center, output 1; otherwise, 0.  
The comparison creates an 8-bit binary LBP feature descriptor.

Diagram:

```
g0 g1 g2
g7 gc g3
g6 g5 g4
```

The comparison results are combined into an 8-bit binary value representing the LBP feature.

---

### 3. **Write to Output Memory (LBP Output)**

After LBP computation, results are output through:

* `lbp_addr`
* `lbp_data`
* `lbp_valid`

The process is complete when `finish = 1`.

---

## State Machine Description

This design uses a finite state machine (FSM) to control the LBP operation, with the following states:

- **IDLE**: Waits for process initiation.
- **REQ**: Requests the next RGB input.
- **GRAY**: Converts RGB to Grayscale and stores in memory.
- **GET_GC**: Prepares and fetches the grayscale center pixel for LBP calculation.
- **LBP**: Computes LBP value from grayscale memory and outputs data.
- **DONE**: Indicates all pixels are processed, operation finished.

---

## Directory Structure

```
src/           # Main LBP algorithm module (Verilog)
tb/            # Testbench (SystemVerilog)
data/          # Example image data golden (RGB/Gray/LBP)
README.md      # Project documentation
```

---

## How to Use

1. Use a Verilog/SystemVerilog simulator (e.g., ModelSim, VCS, Verilator) for simulation.
2. Run the testbench (`tb/testfixture.sv`) in the project folder.
3. Sample data files (RGB, Gray, LBP) are provided in the `data/` directory.
4. If the implementation is correct, you will see a PASS message at the end of simulation; otherwise, error details are printed.

---

## Key Modules & Interface Description

### LBP Processing Module (`src/LBP.v`)

**Inputs:**
- `clk`      : Clock
- `reset`    : Reset
- `RGB_data` : Input RGB24 bits image data
- `RGB_ready`: RGB data ready

**Outputs:**
- `gray_addr`/`gray_data`/`gray_valid`: Grayscale image address/data/valid signal
- `lbp_addr`/`lbp_data`/`lbp_valid`   : LBP address/data/valid signal
- `finish`    : Processing finished flag

### Testbench (`tb/testfixture.sv`)
- Loads image data from the `data/` directory.
- Automatically checks correctness of grayscale and LBP results.

---

## References

- [Wikipedia: Local Binary Pattern](https://en.wikipedia.org/wiki/Local_binary_pattern)
- Ojala, T., Pietikäinen, M., & Harwood, D. (1996). "A comparative study of texture measures with classification based on featured distributions".

---

## License

MIT
