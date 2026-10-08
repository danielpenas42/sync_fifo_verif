package fifo_pkg;
    parameter int WIDTH = 32;
    parameter int DEPTH = 16;

    typedef logic [WIDTH-1:0] data_t;
    localparam data_t SPLIT =  '1 << (WIDTH/2);

    class Packet;
    
        rand data_t data;

        rand bit read;
        rand bit write;

        int unsigned read_pct = 50;
        int unsigned write_pct = 50;

        constraint data_skewed  {
            data dist{
                [0:SPLIT-1] :/ 60,
                [SPLIT:$] :/ 40
            };
        }

        constraint read_c {
            read dist {
                1 :/ read_pct,
                0 :/ 100 - read_pct};
        }

        constraint write_c {
            write dist {
                1 :/ write_pct,
                0 :/ 100 - write_pct};
        }
        
        function void pre_randomize();
            if (read_pct > 100) 
                $fatal(1, "read expected to be less than 100, got %0d", read_pct);
            if (write_pct > 100) 
                $fatal(1, "write expected to be less than 100, got %0d", write_pct);
        endfunction
            
    endclass


endpackage