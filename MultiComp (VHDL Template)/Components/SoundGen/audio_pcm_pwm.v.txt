module audio_pcm_pwm (MAX10_CLK1_50, GPIO, KEY, LEDR);

input           MAX10_CLK1_50;
inout   [35:0]  GPIO;
input   [1:0]   KEY;
output  [9:0]   LEDR;

wire            sys_clk;
wire            sys_rst_n = KEY[0];

reg             pwm_out_ff;
reg     [7:0]   pwm_cnt_ff;
reg     [7:0]   pcm_sample_ff;
wire    [7:0]   uart_dat;

mypll pll_inst(.inclk0 (MAX10_CLK1_50),
                .c0 (sys_clk),          // 255 MHz clock
                .locked (LEDR[0])
                );

simple_uart_receiver uart_rec(.i_clk (sys_clk), 
                                .i_rst_n (sys_rst_n), 
                                .i_rx (GPIO[0]), 
                                .o_dat (uart_dat), 
                                .o_dat_vld ()
                                );

always @(posedge sys_clk)
    pcm_sample_ff <= uart_dat;

always @(posedge sys_clk)
    pwm_cnt_ff <= pwm_cnt_ff + 1'b1;

always @(posedge sys_clk)
    pwm_out_ff <= (pwm_cnt_ff < pcm_sample_ff);

assign GPIO[35] = pwm_out_ff;

endmodule


