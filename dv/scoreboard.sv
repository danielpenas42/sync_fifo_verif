import fifo_pkg::*;

class Scoreboard;
    // packed array [31:0] data
    // unpacked array data[0:31]
    // associative array data_t dict[int] this is more like unordered_map
    // dyamic array     data_t dict[] this is more like unordered_set
    data_t queue [$];
    int errors;
    mailbox #(data_t) mbx_r;
    mailbox #(data_t) mbx_w;

    function new();
        mbx_r = new();
        mbx_w = new();
    endfunction

    function void write(data_t data);
        if( queue.size() < DEPTH) begin
            queue.push_back(data);
        end
        else begin
            $error("Size is of the queue is greater than 16");
            errors++;
        end
    endfunction

    function void read(data_t actual);
        if (queue.size() > 0) begin
            data_t expected = queue.pop_front();
            assert(expected === actual) 
                else begin
                    $error("Expected %0d, but got this %0d when reading", expected, actual);
                    errors++;
                end
        end
        else begin
            $error("Size is of the queue is 0");
            errors++;
        end
    endfunction

    task run();
            fork
                forever begin
                    data_t d_read;
                    mbx_r.get(d_read);
                    read(d_read);
                end
                forever begin
                    data_t d_write;
                    mbx_w.get(d_write);
                    write(d_write);
                end
                
            join
        
    endtask

    function void report();
        $display("there were %0d errors",errors);
    endfunction



endclass