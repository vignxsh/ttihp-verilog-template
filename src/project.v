`default_nettype none

module tt_um_7seg_counter (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // 1. Unused pins setup
    // Turn off bidirectional pins to prevent electrical shorts
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    // Silence Verilator warnings about unused inputs
    wire _unused = &{ena, ui_in, uio_in, 1'b0};

    // 2. Clock Divider & Counter
    reg [25:0] clk_div; // 26 bits can hold up to 67 million
    reg [3:0]  counter; // 4 bits to hold 0-9

    always @(posedge clk) begin
        if (!rst_n) begin
            clk_div <= 26'b0;
            counter <= 4'b0;
        end else begin
            // 50,000,000 clock cycles = 1 second
            if (clk_div == 50_000_000 - 1) begin
                clk_div <= 26'b0;
                
                // Wrap around at 9
                if (counter == 4'd9)
                    counter <= 4'b0;
                else
                    counter <= counter + 1'b1;
            end else begin
                clk_div <= clk_div + 1'b1;
            end
        end
    end

    // 3. 7-Segment Decoder
    // Mapping: uo_out[0]=a, uo_out[1]=b, uo_out[2]=c, uo_out[3]=d, 
    //          uo_out[4]=e, uo_out[5]=f, uo_out[6]=g, uo_out[7]=Decimal Point
    reg [6:0] seg;
    
    always @(*) begin
        case (counter)
            //                gfedcba
            4'd0: seg = 7'b0111111;
            4'd1: seg = 7'b0000110;
            4'd2: seg = 7'b1011011;
            4'd3: seg = 7'b1001111;
            4'd4: seg = 7'b1100110;
            4'd5: seg = 7'b1101101;
            4'd6: seg = 7'b1111101;
            4'd7: seg = 7'b0000111;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
    end

    // Assign the segments to the output pins (with the decimal point turned off)
    assign uo_out = {1'b0, seg};

endmodule

`default_nettype wire
