import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def routing_smoke(dut):
    cocotb.start_soon(Clock(dut.clk,10,unit='ns').start())
    dut.in_valid.value=0; dut.out_ready.value=0x1f; dut.rst_n.value=1
    await Timer(1,unit='ns'); dut.rst_n.value=0; await Timer(20,unit='ns'); dut.rst_n.value=1
    for dest in range(5):
        packet=(dest<<29)|(0x100+dest)
        dut.in_data.value=packet; dut.in_valid.value=1
        while (int(dut.in_ready.value)&1)==0: await RisingEdge(dut.clk)
        await RisingEdge(dut.clk); dut.in_valid.value=0
        for _ in range(4):
            await RisingEdge(dut.clk)
            if (int(dut.out_valid.value)>>dest)&1:
                assert ((int(dut.out_data.value)>>(dest*32))&0xffffffff)==packet
                break
        else: raise AssertionError(f'packet did not reach output {dest}')
