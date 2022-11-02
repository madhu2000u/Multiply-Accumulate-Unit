/*
Authors:
Madhu Sudhanan - 115294248
Suvarna Tirur Ananthanarayanan - 115012264
Date: October 3, 2022
*/

module tb_part4_mac();

   logic clk, reset, valid_in, valid_out;
   logic signed [13:0] a, b;
   logic signed [27:0] f;

   part4_mac dut(.clk(clk), .reset(reset), .a(a), .b(b), .valid_in(valid_in), .f(f), .valid_out(valid_out));

   initial clk = 0;
   always #5 clk = ~clk;

    integer i, saturationFluctuationCheckers = 4, saturationRangeTest = 10, desiredInputs = 1000000;

    logic [13:0] testData[3000071:0];   // 3 * ((saturationFluctuationCheckers + desiredInputs + (2 * saturationRangeTest)))
    initial $readmemh("inputData", testData);

    //saturationRangeTest is just used for the loop that manually saturates the MAC by providing maximum values of a and b saturationRangeTest number of times.
    initial begin
        reset = 1;
        {a, b} = {14'b0,14'b0};
        valid_in = 0;
        
    //this formula gives the total number of lines in inputData as per testbench_part3.c which is the number of times it must loop
    for(i = 0; i < (saturationFluctuationCheckers + desiredInputs + (2 * saturationRangeTest)); i=i+1) begin
        @ (posedge clk);
        #1;
        reset = 0;
        valid_in = testData[3*i];
        a = testData[3*i+1][13:0];
        b = testData[3*i+2][13:0];
     end
     
    //These extra clk pulses are used to propogate the last input a, b into the ouput f. It is 4 in this particular case since output is available after 4 clock cycles from when we set input.
     for(i = 0; i < 4; i=i+1) begin
        @ (posedge clk);
     end
     $stop;
    end

    integer filehandle=$fopen("outValues");
    always @(posedge clk) 
        $fdisplay(filehandle, "%h, %h", f, valid_out);
    

endmodule 