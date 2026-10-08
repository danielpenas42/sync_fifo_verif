module sync_fifo#(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
)(
    input               clk,
    input               rst,
    
    input  [WIDTH-1:0]  w_data,
    input               w_val,
    output              w_rdy,

    output [WIDTH-1:0]  r_data,
    output              r_val,
    input               r_rdy

);
    localparam int PTR_WIDTH = $clog2(DEPTH);
    logic [PTR_WIDTH:0] read_ptr;
    logic [PTR_WIDTH:0] write_ptr;
    logic full;
    logic empty;
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    assign empty = (read_ptr == write_ptr);
    assign full = (read_ptr[PTR_WIDTH-1:0] == write_ptr[PTR_WIDTH-1:0]) && 
                    (read_ptr[PTR_WIDTH] != write_ptr[PTR_WIDTH]);

    assign w_rdy = !full;
    assign r_val = !empty;
    assign r_data = mem[read_ptr[PTR_WIDTH-1:0]];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            read_ptr <= '0;
            write_ptr <= '0;
        end
        else begin
            if (!full && w_val) begin
                write_ptr <= write_ptr + 1;
                mem[write_ptr[PTR_WIDTH-1:0]] <= w_data;
            end
            if (!empty && r_rdy) begin
                read_ptr <= read_ptr + 1;
            end
        end
    end

endmodule