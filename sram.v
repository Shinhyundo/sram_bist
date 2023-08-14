module sram
(
    input           i_clka    ,
    input           i_ena     ,
    input           i_wea     ,
    input   [7:0]   i_addra   ,
    input   [9:0]   i_dina    ,


    output  [9:0]   o_douta
);

    /**********************************************************/
    generate
    genvar  idx;
    for (idx = 0; idx < 256; idx = idx+1) begin : sram_data
       wire [9:0] mem_sell;
       assign mem_sell = sram[idx];
    end
    endgenerate
    /**********************************************************/

    reg     [9:0]   sram [0:255];
    reg     [7:0]   r_addra;
    reg     [9:0]   r_douta;

    /* write */
    always @ (posedge i_clka) begin
        if (i_ena) begin
            if (i_wea) begin
                sram[i_addra] <= i_dina;
            end
            r_addra <= i_addra; 
        end 
    end

    /* read */
    always @ (posedge i_clka) begin
        if (i_ena) begin
            if (!i_wea)
                r_douta = sram[r_addra];
        end
    end
  
    assign o_douta = r_douta;
endmodule