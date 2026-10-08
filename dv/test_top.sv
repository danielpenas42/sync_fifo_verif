import fifo_pkg::*;

interface fifo_if (input logic clk);

        logic  rst;

        data_t w_data;
        logic  w_val;
        logic  w_rdy;
        
        data_t r_data;
        logic  r_val;
        logic  r_rdy;

        clocking cb @(posedge clk);
            inout w_data;
            inout w_val;
            inout r_rdy;
            input w_rdy;
            input r_val;
            input r_data;
        endclocking


endinterface

module tb_top;

    logic clk;
    initial clk = 0; 
    always #5 clk = ~clk; 

    fifo_if fifo (clk);

    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(fifo.rst),
        
        .w_data(fifo.w_data),
        .w_val(fifo.w_val),
        .w_rdy(fifo.w_rdy),

        .r_data(fifo.r_data),
        .r_val(fifo.r_val),
        .r_rdy(fifo.r_rdy)
    );

    initial begin
        Driver drv;
        Monitor mon;
        Scoreboard scb;
        RandomTest test;

        // build and connect them
        scb = new();
        drv = new(fifo);
        mon = new(fifo, scb.mbx_r, scb.mbx_w);
        test = new(drv);

        // reset
        drv.reset();

        fork
            drv.run();
            mon.run();
            scb.run();
        join_none

        test.run();
        repeat(5) @(fifo.cb);
        scb.report();
        $finish;
    end



endmodule