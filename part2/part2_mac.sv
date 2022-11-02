/*
Authors:
Madhu Sudhanan - 115294248
Suvarna Tirur Ananthanarayanan - 115012264
Date: October 3, 2022
*/


module D_FF_13b(d, q, clk, enable_ab, reset);
    input [13:0] d;
    input clk, reset, enable_ab;
    output logic [13:0] q;
    always_ff @(posedge clk) begin
        if (reset == 1)
            q <= 0;
        else if(enable_ab == 1)
            q <= d;

    end
endmodule

module D_FF_28b(sum, f, clk, enable_f, reset);
    input clk, enable_f, reset;
    input signed [27:0] sum;
    output logic signed [27:0] f;

    always_ff @(posedge clk) begin
        if(reset == 1)
            f <= 0;
        else if(enable_f == 1)
            f <= sum;
    end
endmodule

module Controller(clk, valid_in, enable_ab, enable_f, valid_out,reset);
    input clk, valid_in, reset;
    output logic enable_ab, enable_f, valid_out;
    logic vin_temp_out;

    always_comb begin 
        enable_ab = valid_in;
    end

    always_ff @(posedge clk) begin 
        enable_f <= valid_in;
        vin_temp_out <= valid_in;
        valid_out <= vin_temp_out;
        if(reset == 1) begin
            enable_f <= 0;
            vin_temp_out <= 0;
            valid_out <=0;
        end

    end
endmodule

module part2_mac(clk, reset, a, b,  valid_in, f, valid_out);
    input clk, reset, valid_in;
    input signed [13:0] a, b;
    output logic signed [27:0] f;
    output logic valid_out;
    logic enable_ab, enable_f;
    logic signed [27:0] sum;
    logic signed [13:0] q1,q2;

    Controller controller(clk, valid_in, enable_ab, enable_f, valid_out, reset);
    D_FF_13b D1(a,q1,clk,enable_ab, reset);
    D_FF_13b D2(b,q2,clk,enable_ab, reset);    
    
    always_comb begin
        sum = (q1 * q2) + f;
    end

    D_FF_28b D_FF_28b(sum, f, clk, enable_f, reset);

endmodule

