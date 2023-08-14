module sram_bist
#(
    parameter IDLE      = 3'b000     ,   // init state
    parameter WRITE_3FF = 3'b001    ,   // 0~255 3FF write
    parameter READ_3FF  = 3'b010    ,   // 0~255 3FF read
    parameter WRITE_00  = 3'b011    ,   // 0~255 00 write
    parameter READ_00   = 3'b100    ,   // 0~255 00 read
    parameter WRITE_2AA = 3'b101    ,   // 0~255 2AA write
    parameter READ_2AA  = 3'b110    ,   // 0~255 2AA read
    parameter DONE      = 3'b111        // done
)
(
    input           i_clock         ,
    input           i_reset         ,
    input           i_bist_en       ,
    input   [9:0]   i_rd_data       ,

    output          o_csn           ,
    output          o_wen           ,
    output  [9:0]   o_wr_data       ,
    output  [7:0]   o_wr_addr       ,
    output          o_b_done        ,
    output          o_b_err     
);
    reg     [7:0]   r_addr_cnt;         // address counter register   
    reg             r_cnt_done;         // if cnt==255, set 1

    reg     [2:0]   n_state;            //next state register
    reg     [2:0]   c_state;            //current state register

    reg             r_cnt_start;        /* output register */
    reg             r_csn;
    reg             r_wen;
    reg     [9:0]   r_wr_data;
    reg             r_b_done;
    reg             r_b_err;

    reg             q_rising;           
    wire            w_rising_start;     // csn rising signal

    /* address counter */
    always @ (posedge i_clock, negedge i_reset) begin
        if (!i_reset) begin
            r_addr_cnt <= 8'd0;
            r_cnt_done <= 1'b0;
        end
        else if (r_csn) begin
            if (r_addr_cnt == 8'd255) begin
                r_cnt_done <= 1'b1;
                r_addr_cnt <= 8'd0;
            end
            else if (r_cnt_start) begin
                r_addr_cnt <= r_addr_cnt + 8'd1;
                r_cnt_done <= 1'b0;
            end
        end
        else begin
            r_cnt_done <= 1'b0;
        end
    end

    /* state memory */
    always @ (posedge i_clock, negedge i_reset) begin
        if (!i_reset) 
            c_state <= IDLE;
        else
            c_state <= n_state;
    end
    
    /* next state logic */
    always @ (*) begin
        /* to prevent latch */
        n_state = IDLE;      
        r_cnt_start = 1'b0;
        r_csn = 1'b0;
        r_wen = 1'b0;
        r_wr_data = 10'd0;
        r_b_done = 1'b0;
        r_b_err = 1'b0;

        case (c_state) 
            /* init state */
            IDLE   : begin
                if (i_bist_en)
                    n_state = WRITE_3FF;
            end

            /* 3FF write */
            WRITE_3FF : begin
                r_cnt_start = 1'b1;
                r_csn = 1'b1;
                r_wr_data = 10'h3ff;
                r_wen = 1'b1;          
                n_state = WRITE_3FF;
                if (r_cnt_done) begin   
                    n_state = READ_3FF;
                    r_cnt_start = 1'b0;
                    r_csn = 1'b0;
                end
            end
            
            /* 3FF read */
            READ_3FF : begin
                r_csn = 1'b1;
                r_cnt_start = 1'b1;
                r_wen = 1'b0;    
                n_state = READ_3FF;   
                if (r_cnt_done) begin  
                    n_state = WRITE_00;
                    r_cnt_start = 1'b0;
                    r_csn = 1'b0;
                end
            end

            /* 00 write */
            WRITE_00 : begin
                r_csn = 1'b1;
                r_wr_data = 10'h0;
                r_cnt_start = 1'b1;
                r_wen = 1'b1;          
                n_state = WRITE_00;
                if (r_cnt_done) begin   
                    n_state = READ_00;
                    r_csn = 1'b0;
                end
            end

            /* 00 read */
            READ_00 : begin
                r_csn = 1'b1;
                r_cnt_start = 1'b1;
                r_wen = 1'b0;          
                n_state = READ_00;
                if (r_cnt_done) begin  
                    n_state = WRITE_2AA;
                    r_csn = 1'b0;
                end
            end

            /* 2AA write */
            WRITE_2AA : begin
                r_csn = 1'b1;
                r_wr_data = 10'h2aa;
                r_cnt_start = 1'b1;
                r_wen = 1'b1;           
                n_state = WRITE_2AA;
                if (r_cnt_done) begin   
                    n_state = READ_2AA;
                    r_csn = 1'b0;
                end
            end

            /* 2AA read */
            READ_2AA : begin
                r_csn = 1'b1;
                r_cnt_start = 1'b1;
                r_wen = 1'b0;       
                n_state = READ_2AA;    
                if (r_cnt_done) begin   
                    n_state = DONE;
                    r_csn = 1'b0;
                end
            end
            
            /* done */
            DONE : begin
                n_state = DONE;
                r_b_done = 1'b1;
                r_cnt_start = 1'b0;
            end

            default : r_b_err = 1'b1;
        endcase
    end

    /* r_csn rsinig dectector */
    always @ (posedge i_clock, negedge i_reset) begin
        if (!i_reset)
            q_rising <= 1'b0;
        else
            q_rising <= r_cnt_start;
    end

    assign w_rising_start = ~q_rising & r_cnt_start;

    /* output logic */
    assign o_csn  = r_csn;
    assign o_wen  = r_wen;
    assign o_wr_data = r_wr_data;
    assign o_wr_addr = r_addr_cnt;
    assign o_b_done = r_b_done;
    assign o_b_err = r_b_err;

endmodule