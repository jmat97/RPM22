/**
 * Copyright (C) 2020  AGH University of Science and Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import uart_pkg::*;

module command_manager (
    input logic         i_clk,
    input logic         i_rst_n,
    input logic [7:0]   i_read_reg,
    input logic [7:0]   i_rx_data,
    input logic         i_rx_data_valid,
    output logic [7:0]  o_write_reg,
    output logic [7:0]  o_tx_data,
    output logic        o_tx_data_valid,
    output logic [2:0]  o_rwaddr,
    output logic        o_rd_req,
    output logic        o_wr_req
);


/**
 * Local variables and signals
 */
    typedef enum logic [2:0] {INIT, IDLE, DECODE, READ_REG, GET_DATA, WRITE_REG, TRANSMIT_REG} state_t;
    state_t state, state_nxt;

/**
 * Signals assignments
 */

 //assign o_rwaddr = i_rx_data[3:1];
 //assign o_tx_data_valid = (state == READ_REG);

/**
 * FSM state management
 */
    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if (!i_rst_n)
            state <= INIT;
        else
            state <= state_nxt;
    end

/**
 * Next state logic
 */
    always_comb begin
        case (state)
            INIT:       state_nxt = IDLE;
            IDLE:       state_nxt = i_rx_data_valid ? DECODE : IDLE;
            DECODE:     state_nxt = i_rx_data[0] ? GET_DATA : TRANSMIT_REG;
            GET_DATA    :state_nxt = i_rx_data_valid ? WRITE_REG : GET_DATA;
            WRITE_REG:  state_nxt = IDLE;
            TRANSMIT_REG:   state_nxt = IDLE;
        endcase
    end


/**
 * Tasks and functions definitions
 */

/**
 * Properties and assertions
 */

/**
 * Request logic
 */
    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_rd_req <= 1'b0;
            o_wr_req <= 1'b0;
            o_write_reg <= 8'b0;
            o_tx_data <= 8'b0;
            o_tx_data_valid <= 1'b0;
            o_rwaddr <= 3'b0;
            end
        else
            case(state)
            INIT:   begin
                o_rd_req <= 1'b0;
                o_wr_req <= 1'b0;
                o_write_reg <= 8'b0;
                o_tx_data <= 8'b0;
                o_tx_data_valid <= 1'b0;
                o_rwaddr <= 3'b0; ;
            end
            IDLE:   begin
                o_rd_req <= 1'b0;
                o_wr_req <= 1'b0;
                o_write_reg <= o_write_reg;
                o_tx_data <= o_tx_data;
                o_tx_data_valid <= 1'b0;
                o_rwaddr <= o_rwaddr;
            end
            DECODE:   begin
                o_rd_req <= !i_rx_data[0];
                o_wr_req <= o_wr_req;
                o_write_reg <= 8'b0;
                o_tx_data <= 8'b0;
                o_tx_data_valid <= 1'b0;
                o_rwaddr <= i_rx_data[3:1];
            end
            GET_DATA:   begin
                o_rd_req <= o_rd_req;
                o_wr_req <= o_wr_req;
                o_write_reg <= o_write_reg;
                o_tx_data <= o_tx_data;
                o_tx_data_valid <= o_tx_data_valid;
                o_rwaddr <= o_rwaddr;
            end
            TRANSMIT_REG:   begin
                o_rd_req <= 1'b0;
                o_wr_req <= 1'b0;
                o_write_reg <= 8'b0;
                o_tx_data <= i_read_reg;
                o_tx_data_valid <= 1'b1;
                o_rwaddr <= o_rwaddr;
            end
            WRITE_REG:  begin
                o_rd_req <= 1'b0;
                o_wr_req <= 1'b1;
                o_write_reg <= i_rx_data;
                o_tx_data <= 8'b0;
                o_tx_data_valid <= 1'b0;
                o_rwaddr <= o_rwaddr;
            end
            default: begin
                o_rd_req <= 1'b0;
                o_wr_req <= 1'b0;
                o_write_reg <= 8'b0;
                o_tx_data <= 8'b0;
                o_tx_data_valid <= 1'b0;
                o_rwaddr <= 3'b0; ;
            end
            endcase
    end


endmodule
