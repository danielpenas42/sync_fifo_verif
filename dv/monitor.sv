import fifo_pkg::*;

class Monitor;
    virtual fifo_if vif;
    mailbox #(data_t) mbx_r;
    mailbox #(data_t) mbx_w;

    function new(virtual fifo_if vif, mailbox #(data_t) mbx_r, mailbox #(data_t) mbx_w);
        this.vif = vif;
        this.mbx_r = mbx_r;
        this.mbx_w = mbx_w;
    endfunction

    task check(output data_t read_data, output logic read_valid, output data_t write_data, output logic write_valid);
        @(vif.cb);
        if (vif.cb.r_val && vif.cb.r_rdy) begin
            read_data = vif.cb.r_data;
            read_valid = 1;
        end
        else 
            read_valid = '0;

        if (vif.cb.w_val && vif.cb.w_rdy) begin
            write_data = vif.cb.w_data;
            write_valid = 1;
        end
        else 
            write_valid = '0;
    endtask
    
    task run();
        forever begin
            data_t r_data;
            data_t w_data;
            bit w_val;
            bit r_val;
            check(r_data, r_val, w_data, w_val);
            if (r_val)
                mbx_r.put(r_data);
            if (w_val)
                mbx_w.put(w_data);
        end 
    endtask
endclass