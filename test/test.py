# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start Vending Machine FSM Test")

    # Clock 10us period (100kHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    dut._log.info("Apply 1 rupee coin")
    dut.ui_in.value = 0b00000001  # coinx = 1
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)

    dut._log.info("Apply another 1 rupee coin -> expect product")
    dut.ui_in.value = 0b00000001
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value & 0b1, "Product should be dispensed after 2 x 1 rupee"

    dut._log.info("Apply 2 rupee coin -> expect product")
    dut.ui_in.value = 0b00000010  # coiny = 1
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)

    await RisingEdge(dut.clk)  # wait one cycle
    assert dut.uo_out.value & 0b1, "Product should be dispensed after 1 x 2 rupee"

    dut._log.info("Apply 2 rupee coin followed by another 2 rupee coin -> expect product + change")
    dut.ui_in.value = 0b00000010
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)

    dut.ui_in.value = 0b00000010
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)

    assert dut.uo_out.value & 0b1, "Product should be dispensed after 2+2 rupees"
    assert (dut.uo_out.value >> 1) & 0b1, "Change should be returned after 2+2 rupees"
