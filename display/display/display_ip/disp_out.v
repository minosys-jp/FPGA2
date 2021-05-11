/* Copyright(C) 2020 Cobac.Net All Rights Reserved. */
/* chapter: 第9章        */
/* project: display      */
/* outline: 表示出力作成 */

module disp_out
  (
    input               PCK,
    input               PRST,
    input               DISPON,
    output  reg         FIFORD,
    input   [11:0]      VGAOUT,
    input   [9:0]       HCNT,
    input   [9:0]       VCNT,
    output  reg         AXISTART,
    output  reg [3:0]   VGA_R, VGA_G, VGA_B,
    output  reg         VGA_DE
    );

/* VGA(640×480)用パラメータ読み込み */
`include "vga_param.vh"

/* FIFO読み出し信号 */
wire [9:0] rdstart = HFRONT + HWIDTH + HBACK - 10'd4;
wire [9:0] rdend   = HPERIOD - 10'd4;

always @( posedge PCK ) begin
    if ( PRST )
        FIFORD <= 1'b0;
    else if ( VCNT < VFRONT + VWIDTH + VBACK )
        FIFORD <= 1'b0;
    else if ( (HCNT==rdstart) & DISPON )
        FIFORD <= 1'b1;
    else if ( HCNT==rdend )
        FIFORD <= 1'b0;
end

/* FIFORDを2クロック遅らせて表示の最終イネーブルを作る */
reg [1:0] disp_enable;

always @( posedge PCK ) begin
    if ( PRST )
        disp_enable  <= 2'b0;
    else  begin
        disp_enable[1]  <= disp_enable[0];
        disp_enable[0]  <= FIFORD;
    end
end

/* VGA_R～VGA_B出力 */
always @( posedge PCK ) begin
    if ( PRST )
        {VGA_R, VGA_G, VGA_B} <= 24'h0;
    else if ( disp_enable )
        {VGA_R, VGA_G, VGA_B} <= VGAOUT[11:0];
    else
        {VGA_R, VGA_G, VGA_B} <= 24'h0;
end

/* VGA_DEを作成 */
always @( posedge PCK ) begin
    if ( PRST )
        VGA_DE <= 1'b0;
    else
        VGA_DE <= disp_enable[1];
end

/* VRAM読み出し開始 */
always @( posedge PCK ) begin
    if ( PRST )
        AXISTART <= 1'b0;
    else
        AXISTART <= (VCNT == VFRONT + VWIDTH + VBACK -10'd1);
end

endmodule
