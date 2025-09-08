import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def test_project(dut):
    """Vending Machine FSM Test"""
    dut._log.info("Start Vending Machine FSM Test")

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Case 1: 1 + 1 -> product
    dut._log.info("Apply 1 rupee coin")
    dut.ui_in.value = 1
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)

    dut._log.info("Apply another 1 rupee coin -> expect product")
    dut.ui_in.value = 1
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)   # FSM updates
    await RisingEdge(dut.clk)   # <-- extra cycle to catch pulse
    assert dut.uo_out.value & 0b1, "Product should be dispensed after 1+1 rupees"

    # Case 2: 2 -> product
    dut._log.info("Apply 2 rupee coin -> expect product")
    dut.ui_in.value = 2
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)   # <-- extra cycle to catch pulse
    assert dut.uo_out.value & 0b1, "Product should be dispensed after 1 x 2 rupee"

    # Case 3: 2 + 2 -> product + change
    dut._log.info("Apply 2 rupee coin followed by another 2 rupee coin -> expect product + change")
    dut.ui_in.value = 2
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)

    dut.ui_in.value = 2
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)   # FSM processes second coin
    await RisingEdge(dut.clk)   # <-- extra cycle to catch pulse

    assert dut.uo_out.value & 0b1, "Product should be dispensed after 2+2 rupees"
    assert dut.uo_out.value & 0b10, "Change should be returned after 2+2 rupees"
