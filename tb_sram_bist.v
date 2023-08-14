`timescale 1ns / 100ps
module tb_sram_bist;

    localparam SIM_TIME = 16000;

    reg             clock;
    reg             reset;
    reg             bist_en;
    
    wire    [9:0]   w_rd_data;
    wire            w_csn;
    wire            w_wen;
    wire    [9:0]   w_wr_data;
    wire    [7:0]   w_wr_addr;
    wire            w_b_done;
    wire            o_b_err;

    sram_bist sram_bist
    (   
        //input
        .i_clock(clock)         ,
        .i_reset(reset)         ,
        .i_bist_en(bist_en)     ,
        .i_rd_data(w_rd_data)   ,

        //output
        .o_csn(w_csn)           ,
        .o_wen(w_wen)           ,
        .o_wr_data(w_wr_data)   ,
        .o_wr_addr(w_wr_addr)   ,
        .o_b_done(w_b_done)
    );

    sram sram
    (   
        //input
        .i_clka(clock)          ,
        .i_ena(w_csn)           , 
        .i_wea(w_wen)           ,
        .i_addra(w_wr_addr)     ,
        .i_dina(w_wr_data)      ,
        
        //output
        .o_douta(w_rd_data)
    );

    always #5 clock = ~clock;

    initial begin
        clock = 1'b0;
        reset = 1'b1;
        bist_en = 1'b0;
        #10
        reset = 1'b0;
        #10
        reset = 1'b1;

        #100
        bist_en = 1'b1;
    end

    initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, tb_sram_bist);

        #(SIM_TIME);
        $finish;
    end

endmodule