module counter(
    input clk,
    input reset,
    input enb,
    output reg done
);
    reg [15:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count   <= 0;
            done    <= 0;
        end else begin
            if (enb == 1'b1) begin
                if (count != {(16){1'b1}}) begin
                    count   <= count + 1;
                    done    <= 1'b0;
                end else begin
                    count   <= 0;
                    done    <= 1'b1;
                end
            end
        end
    end

endmodule
`default_nettype wire