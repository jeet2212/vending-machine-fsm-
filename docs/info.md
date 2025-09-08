## How it works

This project implements a simple vending machine using a finite state machine (FSM).  
It accepts two types of coin inputs:

- **ui[0] → coinx (1 rupee)**
- **ui[1] → coiny (2 rupees)**

The FSM tracks the inserted amount and produces outputs when enough value is collected:

- **uo[0] → prod (dispense product pulse)**
- **uo[1] → change (return change pulse)**

### FSM states
- **IDLE** → Waiting for coin input  
- **ONE_RUPEE** → After 1 rupee inserted  
- **TWO_RUPEE** → After 2 rupees inserted  

Transitions:
- 1 + 1 rupee → product dispensed  
- 2 rupees → product dispensed  
- 2 + 2 rupees → product dispensed + change returned  

Both `prod` and `change` signals are 1-cycle pulses on successful transactions.

---

## How to test

1. Reset the design (`rst_n = 0 → 1`).  
2. Insert coins by pulsing inputs:
   - `ui[0] = 1` → 1 rupee coin  
   - `ui[1] = 1` → 2 rupee coin  
3. Observe outputs:
   - `uo[0] = 1` → product dispensed  
   - `uo[1] = 1` → change returned  

### Example sequences
- Insert 1 rupee, then another 1 rupee → product dispensed.  
- Insert a 2 rupee coin → product dispensed.  
- Insert two 2 rupee coins → product dispensed and change returned.  

---

## External hardware

No external hardware required.  
The design can be tested directly with simulation or connected to LEDs on an FPGA/ASIC board:  
- LED on `uo[0]` → lights up when product is dispensed.  
- LED on `uo[1]` → lights up when change is returned.
