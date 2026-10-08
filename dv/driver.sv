
import fifo_pkg::*;

class Driver;
    virtual fifo_if vif;
    mailbox #(Packet) mbx;

    function new(virtual fifo_if vif);
        this.vif = vif;
        mbx = new(1);
    endfunction

    task reset();
        vif.rst = 1;
        @(vif.cb);
        vif.rst <= 0;
    endtask

    task drive_data(Packet transaction);
        @(vif.cb);
        vif.cb.w_data <= transaction.data;
        vif.cb.w_val <= transaction.write;
        vif.cb.r_rdy <= transaction.read;

    endtask
     task run();
        Packet pkt;
        forever begin
            mbx.get(pkt);
            drive_data(pkt);
        end
        
    endtask
    
endclass