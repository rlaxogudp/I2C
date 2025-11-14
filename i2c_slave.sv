`timescale 1ns/1ps

module I2C_Slave(
    input clk,
    input reset,
    input SCL,
    inout SDA,
    output [7:0] LED
);
    parameter IDLE=0, ADDR=1, ACK0=2, ACK1=3, ACK2=4, DATA=5, DACK0=6, DACK1 = 7, DACK2=8, DACK3=9, STOP=10;

    reg [3:0] state, state_next;
    reg [7:0] temp_rx_data_reg, temp_rx_data_next;
    reg [7:0] temp_addr_reg, temp_addr_next;
    reg [7:0] bit_counter_reg, bit_counter_next;
    reg en;
    reg o_data;
    
    reg sclk_sync0, sclk_sync1;
    reg [7:0] led_reg, led_next;
    assign SDA= en? o_data: 1'bz;
    assign LED=led_reg;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
            sclk_sync0 <=0;
            sclk_sync1 <=0;
            temp_rx_data_reg <=0;
            bit_counter_reg <=0;
            temp_addr_reg <=0;
            led_reg <=0;
        end else begin
            state <= state_next;
            sclk_sync0 <= SCL;
            sclk_sync1 <= sclk_sync0;
            temp_rx_data_reg <= temp_rx_data_next;
            bit_counter_reg <= bit_counter_next;
            temp_addr_reg <= temp_addr_next;
            led_reg <= led_next;
        end
    end

    wire sclk_rising = sclk_sync0 & ~sclk_sync1;
    wire sclk_falling = ~sclk_sync0 & sclk_sync1;

    always @(*) begin
        state_next = state;
        en = 1'b0;
        o_data = 1'b0;
        temp_rx_data_next = temp_rx_data_reg;
        bit_counter_next = bit_counter_reg;
        temp_addr_next = temp_addr_reg;
        case (state)
            IDLE: begin
                if(SCL && ~SDA) begin
                    state_next = ADDR;
                    bit_counter_next = 0;
                end
            end
            ADDR: begin
                if(sclk_rising) begin
                    temp_addr_next = {temp_addr_reg[6:0], SDA};
                    if (bit_counter_reg == 8-1) begin
                        bit_counter_next = 0;
                        state_next = ACK0;
                    end else begin
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end
            ACK0: begin
                if (temp_addr_reg[7:1] == 7'b1010101) begin
                    en = 1'b1;
                    if(sclk_falling) begin
                        o_data= 1'b0;
                        state_next= ACK1;
                    end
                end else begin
                    state_next= IDLE;
                end
            end
            ACK1: begin
                en=1'b1;
                o_data = 1'b0;
                if(sclk_rising) begin
                    state_next= ACK2;
                end
            end
            ACK2: begin
                en=1'b1;
                o_data = 1'b0;
                if(sclk_falling) begin
                    state_next= DATA;
                end
            end
            DATA: begin
                if(sclk_rising) begin
                    temp_rx_data_next = {temp_rx_data_reg[6:0], SDA};
                    if (bit_counter_reg == 8-1) begin
                        bit_counter_next = 0;
                        state_next = DACK0;
                    end else begin
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end
            DACK0: begin
                if(sclk_falling) begin
                    state_next= DACK1;
                end
            end
            DACK1: begin
                en=1'b1;
                o_data= 1'b0;
                if(sclk_rising) begin
                    state_next= DACK2;
                end
            end
            DACK2: begin
                en=1'b1;
                o_data= 1'b0;
                if(sclk_falling) begin
                    state_next= DACK3;
                end
            end
            DACK3: begin
                en=1'b1;
                o_data = 1'b0;
                if(sclk_rising) begin
                    state_next= STOP;
                end
            end
            STOP: begin
                if(SDA && SCL) begin
                    state_next = IDLE;
                    led_next = temp_rx_data_reg;
                end
            end
        endcase
    end

endmodule