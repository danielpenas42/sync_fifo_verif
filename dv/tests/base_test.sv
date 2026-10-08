
virtual class BaseTest;
    Driver dr;

    function new(Driver dr);
        this.dr = dr;
    endfunction

    task run_traffic(input int n, input int wr_pct, input int rd_pct);
        
        for (int i = 0; i < n; i++) begin
            Packet p;
            p = new();
            p.write_pct = wr_pct;
            p.read_pct = rd_pct;

            if (!p.randomize()) $fatal(1, "randomize failed");
            dr.mbx.put(p);
        end
    endtask

    pure virtual task run();
endclass