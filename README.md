# FPGA Password Lock (Nexys A7-100T)

A switch-based password lock written in Verilog for the Digilent **Nexys A7-100T** (Xilinx Artix-7 `xc7a100tcsg324-1`). You enter a 16-bit password on the slide switches, and the board shows the result on the 7-segment display, the RGB LED and the on-board speaker. An admin mode lets you change the user password without re-programming the FPGA.

## Features

- 16-bit password entered on switches `SW[15:0]` and shown live as four hex digits
- Success and failure feedback: green/red RGB LED, plus a 1 kHz (success) or 2 kHz (failure) tone
- Admin mode protected by a separate admin password, used to set a new user password
- Debounced push-button inputs (with 2-stage synchronizers)
- Multiplexed 8-digit 7-segment display that shows messages such as `ENTER`, `PASS`, `FAIL`, `AdPASS`, `SETPASS`, `DENIED`, `SAVED`
- Self-checking-style testbenches for the top level and the password controller

## Controls

| Input | Board control | Function |
|-------|---------------|----------|
| `SW[15:0]` | Slide switches | Password value (4 hex digits) |
| `BTNC` | Centre button | Submit / confirm |
| `BTNU` | Up button | Request admin mode |
| `BTND` | Down button | Reset back to the start state |

## How to use

### Unlock
1. The display shows `ENTER`.
2. Set the switches to the password. The display shows the value in hex.
3. Press **BTNC**.
   - Correct: `PASS`, green LED, high tone.
   - Wrong: `FAIL`, red LED, low tone.
4. Press **BTND** to reset and try again.

### Change the password (admin mode)
1. Press **BTNU**. The display shows `AdPASS`.
2. Set the admin password on the switches and press **BTNC**.
   - Correct: the display shows `SETPASS`.
   - Wrong: `DENIED` with red LED and tone. Press **BTNC** to retry.
3. Press **BTNC** again, set the new password on the switches, then press **BTNC** to save. The display shows `SAVED` with the green LED.
4. Press **BTND** to return to normal mode. The new password is kept until the FPGA is re-programmed or power is lost.

### Default credentials

| Password | Value |
|----------|-------|
| User password | `B5A7` (hex) |
| Admin password | `1234` (hex) |

> **Security note:** the passwords are hard-coded in `password_controller.v` and are for demonstration only. Change them before using this for anything beyond a class or hobby project.

## Architecture

```
                 +------------------+
 BTNC/BTNU/BTND ->| button_debounce  |--pulses--+
                 +------------------+          v
 SW[15:0] ----------------------------> +---------------------+  display_mode  +---------------+--> SEG, AN, DP
                                         | password_controller |--------------->| seven_segment |
                                         |       (FSM)         |                +---------------+
                                         +---------------------+
                                           | led_red/green    | success/failure
                                           v                  v
                                     LED16_R / LED16_G   +------------------+--> AUD_PWM, AUD_SD
                                                         | audio_controller |
                                                         +------------------+
```

### FSM states (`password_controller`)

`IDLE` -> `ADMIN_ENTRY` -> `SET_NOTICE` -> `NEW_ENTRY` -> `SAVED`, with `PASS_STATE`, `FAIL_STATE` and `DENIED` as result states. `BTND` returns to `IDLE` from any state.

## Repository layout

```
.
├── README.md
├── .gitignore
├── abcd 2.xpr                         # Vivado project file
└── abcd 2.srcs/
    ├── sources_1/new/
    │   ├── top_module.v               # Top level
    │   ├── password_controller.v      # FSM: password check, admin mode
    │   ├── seven_segment.v            # 8-digit multiplexed display driver
    │   ├── button_debounce.v          # Synchronizer + debounce -> single pulse
    │   ├── audio_controller.v         # Success/failure tone generator
    │   └── keypad_scanner.v           # Empty placeholder (not used)
    ├── constrs_1/new/constraint.xdc   # Nexys A7 pin constraints
    └── sim_1/new/
        ├── tb_top_module.v            # Top-level testbench
        └── tb_password_controller.v   # FSM testbench
```

## Build and run

**Requirements:** Xilinx Vivado (the project was generated with a 2018.2-era IP cache) and a Nexys A7-100T board.

1. Clone the repository and open `abcd 2.xpr` in Vivado.
2. Run **Synthesis**, **Implementation**, then **Generate Bitstream**.
3. Connect the board over USB, open **Hardware Manager** and program the device.

### Simulation
In Vivado, set `tb_top_module` (or `tb_password_controller`) as the simulation top and run **Run Behavioral Simulation**.

## Resource usage (post-implementation)

| Resource | Used | Available |
|----------|------|-----------|
| Slice LUTs | 111 | 63,400 |
| Slice registers | 180 | 126,800 |

## Known limitations / ideas

- Passwords are hard-coded and the saved password is lost on power-off (no non-volatile storage).
- No lockout after repeated wrong attempts.
- `keypad_scanner.v` is an empty stub, reserved for a possible keypad input.
- The `SAVED` message uses a `U` glyph as an approximation of `V`.


