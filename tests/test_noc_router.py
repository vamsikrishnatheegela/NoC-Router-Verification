import os, random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

N = 5

def set_arr(handle, vals):
    for i,v in enumerate(vals): handle[i].value = v

@cocotb.test()
async def reset_and_route(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_n.value = 0
    set_arr(dut.in_valid, [0]*N); set_arr(dut.out_ready, [1]*N)
    await Timer(30, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    for dest in range(N):
        packet = (dest << 29) | (0x1234 + dest)
        dut.in_data[0].value = packet; dut.in_valid[0].value = 1
        while not int(dut.in_ready[0].value): await RisingEdge(dut.clk)
        await RisingEdge(dut.clk); dut.in_valid[0].value = 0
        for _ in range(5):
            await RisingEdge(dut.clk)
            if int(dut.out_valid[dest].value):
                assert int(dut.out_data[dest].value) == packet
                break
        else: assert False, f"packet did not reach output {dest}"

@cocotb.test()
async def randomized_packets(dut):
    random.seed(7)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_n.value = 0; set_arr(dut.in_valid,[0]*N); set_arr(dut.out_ready,[1]*N)
    await Timer(20, units="ns"); dut.rst_n.value = 1
    expected = {i:[] for i in range(N)}
    for n in range(40):
        src, dest = random.randrange(N), random.randrange(N)
        packet = (dest << 29) | n
        dut.in_data[src].value = packet; dut.in_valid[src].value = 1
        await RisingEdge(dut.clk)
        if int(dut.in_ready[src].value): expected[dest].append(packet)
        dut.in_valid[src].value = 0
        for d in range(N):
            if int(dut.out_valid[d].value):
                got=int(dut.out_data[d].value); assert expected[d] and got==expected[d].pop(0)
    for _ in range(20):
        await RisingEdge(dut.clk)
        for d in range(N):
            if int(dut.out_valid[d].value): assert int(dut.out_data[d].value)==expected[d].pop(0)
    assert not any(expected[d] for d in expected), f"undelivered packets: {expected}"
