import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

@cocotb.test()
async def test_project(dut):
    """Vending Machine FSM Test"""

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    dut._log.info("Start Vending Machine FSM Test")

    # Case 1: 1 + 1 → product
    dut._log.info("Apply 1 rupee coin")
    dut.ui_in.value = 1
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0

    dut._log.info("Apply another 1 rupee coin -> expect product")
    dut.ui_in.value = 1
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    assert dut.uo_out.value & 0b1, "Product should be dispensed after 1+1 rupee"

    # Case 2: 2 → product
    dut._log.info("Apply 2 rupee coin -> expect product")
    dut.ui_in.value = 2
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    assert dut.uo_out.value & 0b1, "Product should be dispensed after 1 x 2 rupee"

    # Case 3: 2 + 2 → product + change
    dut._log.info("Apply 2 rupee coin followed by another 2 rupee coin -> expect product + change")
    dut.ui_in.value = 2
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    dut.ui_in.value = 2
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    assert dut.uo_out.value & 0b1, "Product should be dispensed after 2+2 rupees"
    assert dut.uo_out.value & 0b10, "Change should be returned after 2+2 rupees"
