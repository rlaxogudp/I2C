`timescale 1ns / 1ps

module I2C_Master (
    // global signals
    input logic clk,
    input logic reset,
    // internal signals
    input logic i2c_en,
    input logic i2c_start,
    input logic i2c_stop,
    input logic i2c_ack,
    input logic [7:0] tx_data,
    output logic tx_done,
    output logic tx_ready,
    output logic [7:0] rx_data,
    output logic rx_done,
    //external signals
    output logic scl,
    inout logic sda
);

    typedef enum {
        IDLE,
        START1,
        START2,
        DATA1,
        DATA2,
        DATA3,
        DATA4,
        ACK1_W,
        ACK2_W,
        ACK3_W,
        ACK4_W,
        HOLD,
        STOP1,
        STOP2,
        READ1,
        READ2,
        READ3,
        READ4,
        ACK1_R,
        ACK2_R,
        ACK3_R,
        ACK4_R
    } state_t;

    state_t state, state_next;
    logic sda_en, sda_out;
    logic [8:0] clk_cnt_reg, clk_cnt_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic [7:0] tx_data_reg, tx_data_next;
    logic [7:0] rx_data_reg, rx_data_next;
    logic ack_signal_reg, ack_signal_next;

    assign sda = sda_en ? sda_out : 1'bz;

    assign rx_data = rx_data_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state          <= IDLE;
            clk_cnt_reg    <= 0;
            bit_cnt_reg    <= 0;
            tx_data_reg    <= 0;
            rx_data_reg    <= 0;
            ack_signal_reg <= 0;
        end else begin
            state          <= state_next;
            clk_cnt_reg    <= clk_cnt_next;
            bit_cnt_reg    <= bit_cnt_next;
            tx_data_reg    <= tx_data_next;
            rx_data_reg    <= rx_data_next;
            ack_signal_reg <= ack_signal_next;
        end
    end

    always_comb begin
        state_next      = state;
        clk_cnt_next    = clk_cnt_reg;
        bit_cnt_next    = bit_cnt_reg;
        tx_data_next    = tx_data_reg;
        rx_data_next    = rx_data_reg;
        sda_en          = 1'b1;
        sda_out         = 1'b1;
        scl             = 1'b1;
        tx_done         = 0;
        tx_ready        = 0;
        rx_done         = 0;
        ack_signal_next = ack_signal_reg;
        case (state)
            IDLE: begin
                sda_en   = 1'b1;
                sda_out  = 1'b1;
                scl      = 1'b1;
                tx_ready = 1'b1;
                if (i2c_en) begin
                    tx_data_next = tx_data;
                    state_next   = START1;
                end
            end
            START1: begin
                sda_en   = 1'b1;
                sda_out  = 0;
                scl      = 1'b1;
                tx_ready = 0;
                if (clk_cnt_reg == 499) begin
                    clk_cnt_next = 0;
                    state_next   = START2;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            START2: begin
                sda_en  = 1'b1;
                sda_out = 0;
                scl     = 0;
                tx_done = 0;
                if (clk_cnt_reg == 499) begin
                    clk_cnt_next = 0;
                    state_next   = HOLD;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            HOLD: begin
                sda_en   = 1'b1;
                sda_out  = 0;
                scl      = 0;
                tx_done  = 0;
                tx_ready = 1'b1;
                case ({
                    i2c_start, i2c_stop
                })
                    2'b00: begin
                        tx_data_next = tx_data;
                        state_next   = DATA1;
                    end
                    2'b01: begin
                        state_next = STOP1;
                    end
                    2'b10: begin
                        state_next = START1;
                    end
                    2'b11: begin
                        state_next = READ1;
                    end
                    default: state_next = IDLE;
                endcase
            end
            DATA1: begin
                sda_en  = 1'b1;
                sda_out = tx_data_reg[7];
                scl     = 0;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = DATA2;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            DATA2: begin
                sda_en  = 1'b1;
                sda_out = tx_data_reg[7];
                scl     = 1'b1;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = DATA3;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            DATA3: begin
                sda_en  = 1'b1;
                sda_out = tx_data_reg[7];
                scl     = 1'b1;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = DATA4;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            DATA4: begin
                sda_en  = 1'b1;
                sda_out = tx_data_reg[7];
                scl     = 0;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    if (bit_cnt_reg == 7) begin
                        bit_cnt_next = 0;
                        state_next   = ACK1_W;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1;
                        tx_data_next = {tx_data_reg[6:0], 1'b0};
                        state_next   = DATA1;
                    end
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            ACK1_W: begin
                sda_en = 0;
                scl    = 0;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = ACK2_W;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            ACK2_W: begin
                sda_en = 0;
                scl    = 1;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = ACK3_W;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            ACK3_W: begin
                sda_en          = 0;
                scl             = 1;
                ack_signal_next = sda;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = ACK4_W;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            ACK4_W: begin
                sda_en = 0;
                scl    = 0;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    tx_done      = 1'b1;
                    if (ack_signal_reg == 1'b0) begin
                        state_next = HOLD;
                    end else begin
                        state_next = STOP1;
                    end
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            STOP1: begin
                sda_en  = 1'b1;
                sda_out = 0;
                scl     = 1'b1;
                if (clk_cnt_reg == 499) begin
                    clk_cnt_next = 0;
                    state_next   = STOP2;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            STOP2: begin
                sda_en  = 1'b1;
                sda_out = 1'b1;
                scl     = 1'b1;
                if (clk_cnt_reg == 499) begin
                    clk_cnt_next = 0;
                    state_next   = IDLE;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            READ1: begin
                sda_en = 0;
                scl    = 0;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = READ2;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            READ2: begin
                sda_en = 0;
                scl    = 1;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = READ3;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            READ3: begin
                sda_en       = 0;
                scl          = 1;
                rx_data_next = {rx_data_reg[6:0], sda};
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = READ4;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            READ4: begin
                sda_en = 0;
                scl    = 0;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    if (bit_cnt_reg == 7) begin
                        bit_cnt_next = 0;
                        rx_done      = 1;
                        state_next   = ACK1_R;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1;
                        state_next   = READ1;
                    end
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            ACK1_R: begin
                sda_en  = 1;
                sda_out = i2c_ack ? 0 : 1;
                scl     = 0;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = ACK2_R;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            ACK2_R: begin
                sda_en  = 1;
                sda_out = i2c_ack ? 0 : 1;
                scl     = 1;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = ACK3_R;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            ACK3_R: begin
                sda_en  = 1;
                sda_out = i2c_ack ? 0 : 1;
                scl     = 1;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = ACK4_R;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            ACK4_R: begin
                sda_en  = 1;
                sda_out = i2c_ack ? 0 : 1;
                scl     = 0;
                if (clk_cnt_reg == 249) begin
                    clk_cnt_next = 0;
                    state_next   = HOLD;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
        endcase
    end

endmodule
