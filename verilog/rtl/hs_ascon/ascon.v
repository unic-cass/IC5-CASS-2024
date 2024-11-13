module Ascon #(
    parameter k = 128,            // Key size
    parameter r = 64,             // Rate
    parameter a = 12,             // Initialization round no.
    parameter b = 6,              // Intermediate round no.
    parameter l = 40,             // Length of associated data
    parameter y = 104             // Length of Plain Text
)(
    input       clk,
    input       rst,
    input       keyxSI,
    input       noncexSI,
    input       associated_dataxSI,
    input       input_dataxSI,
    input       ascon_startxSI,
    input       decrypt,

    output reg  output_dataxSO,
    output reg  tagxSO,
    output ascon_readyxSO //
);
    
    reg     [k-1:0]     key; 
    reg     [127:0]     nonce; 
    reg     [l-1:0]     associated_data; 
    reg     [y-1:0]     input_data; 
    reg     [31:0]      i,j;
    reg                 flag_dec;
    wire    [y-1:0]     output_data;
    wire    [127:0]     tag;
    wire                ready, ascon_start, ascon_ready;
    wire                permutation_ready, permutation_start;
    // Left shift for Inputs
    always @(posedge clk) begin
        if(rst)
            {key,
            nonce,
            associated_data,
            input_data,
            flag_dec,
            i,j} <= 0;

        else begin
            if(i < k) begin
                key <= {key[k-2:0], keyxSI}; 
            end

            if (ascon_start) begin 
                flag_dec <= decrypt;
            end

            if(i < 128) begin
                nonce <= {nonce[126:0], noncexSI};
            end

            if(i < l) begin
                associated_data <= {associated_data[l-2:0], associated_dataxSI};
            end

            if(i < y) begin
                input_data <= {input_data[y-2:0], input_dataxSI};
            end

            i <= i+1;

            // Right Shift for encryption outputs
            if(ascon_ready) begin
                if(j < y)
                    output_dataxSO <= output_data[j];
                
                if(j < 128)
                    tagxSO <= tag[j];

                j <= j+1;
            end
        end
    end

    assign ready = ((i>k) && (i>128) && (i>l) && (i>y))? 1 : 0;
    assign ascon_start = ready & ascon_startxSI;
    assign ascon_readyxSO = ascon_ready;


    AsconCore#(
        k,r,a,b,l,y
    ) d1 (
        clk,
        rst,
        key, 
        nonce, 
        associated_data,
        input_data,
        ascon_start,
        flag_dec,
        output_data,
        tag,          
        ascon_ready
    );
endmodule
