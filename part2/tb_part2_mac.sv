/*
Authors:
Madhu Sudhanan - 115294248
Suvarna Tirur Ananthanarayanan - 115012264
Date: October 3, 2022
*/


module tb_part2_mac();

    logic clk, reset, valid_in, valid_out;
    logic signed [13:0] a, b;
    logic signed [27:0] f;

    part2_mac dut(.clk(clk), .reset(reset), .a(a), .b(b), .valid_in(valid_in), .f(f), .valid_out(valid_out));

    initial clk = 0;
    always #5 clk = ~clk;

    logic [13:0] testData[2999999:0];
    initial $readmemh("inputData", testData);

    integer i;
    initial begin
        reset = 1;
    for(i = 0; i<1000000; i=i+1) begin
        @ (posedge clk);
        #1;
        reset = 0;
        valid_in = testData[3*i];
        a = testData[3*i+1][13:0];
        b = testData[3*i+2][13:0];
    end

    //These 3 extra clk pulse used to propogate the last input a, b into the ouput f.
    @ (posedge clk);
    @ (posedge clk);
    @ (posedge clk);
    $stop;
    end

    integer filehandle=$fopen("outValues");
    always @(posedge clk) 
        $fdisplay(filehandle, "%h, %h", f, valid_out);
    
endmodule 