class RandomTest extends BaseTest;
    
    function new(Driver dr);
        super.new(dr);
    endfunction

    task run();
        run_traffic(100, 50,50);
    endtask
endclass