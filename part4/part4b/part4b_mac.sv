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

module D_FF_PipelineReg_28b(regProdIn, regProdOut, clk, reset); //Register used for pipelining
    input [27:0] regProdIn;
    input clk, reset;
    output logic [27:0] regProdOut;
    always_ff @(posedge clk) begin
        if (reset == 1)
            regProdOut <= 0;
        else
            regProdOut <= regProdIn;

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


module Controller(clk, valid_in, enable_ab, enable_f, valid_out, reset);
    input clk, valid_in, reset;
    output logic enable_ab, enable_f, valid_out;
    logic vin_temp_out1, vin_temp_out2, vin_temp_out3, vin_temp_out4, vin_temp_out5, vin_temp_out6, vin_temp_out7;  
    logic f_temp_out1, f_temp_out2, f_temp_out3, f_temp_out4, f_temp_out5, f_temp_out6;

    parameter MULT_PIPELINED_STAGES = 6;       // Used to instantiate flip-flop delay based of multiplier's pipeline stages. Default is 6


    always_comb begin 
        enable_ab = valid_in;
    end

    always_ff @(posedge clk) begin
        f_temp_out1 <= valid_in;             // These are common to designs with any number of pipeline stages
        f_temp_out2 <= f_temp_out1;
        vin_temp_out1 <= valid_in;
        vin_temp_out2 <= vin_temp_out1;
        vin_temp_out3 <= vin_temp_out2;

        if(MULT_PIPELINED_STAGES == 2 || MULT_PIPELINED_STAGES == 3 || MULT_PIPELINED_STAGES == 4 || MULT_PIPELINED_STAGES == 5 || MULT_PIPELINED_STAGES == 6) begin
            if(MULT_PIPELINED_STAGES == 2) begin
                enable_f <= f_temp_out2; 
                valid_out <= vin_temp_out3;
            end

            if(reset == 1) begin        // This if block is common to designs with any number of pipeline stages
                enable_f <= 0;
                valid_out <= 0;
                f_temp_out1 <= 0;
                f_temp_out2 <= 0;               
                vin_temp_out1 <= 0;
                vin_temp_out2 <= 0;
                vin_temp_out3 <= 0;
            end     
        end
        

        if(MULT_PIPELINED_STAGES == 3 || MULT_PIPELINED_STAGES == 4 || MULT_PIPELINED_STAGES == 5 || MULT_PIPELINED_STAGES == 6) begin
            f_temp_out3 <= f_temp_out2;
            vin_temp_out4 <= vin_temp_out3;

            if(MULT_PIPELINED_STAGES == 3) begin
                enable_f <= f_temp_out3;        // These apply only for design with 3 stage pipelined multiplier
                valid_out <= vin_temp_out4;
            end

            if(reset == 1) begin        // This if block common to stages 3, 4, 5, and 6 only
                enable_f <= 0;
                f_temp_out3 <= 0;
                valid_out <= 0; 
                vin_temp_out4 <= 0;   
            end            
        end


        if(MULT_PIPELINED_STAGES == 4 || MULT_PIPELINED_STAGES == 5 || MULT_PIPELINED_STAGES == 6) begin
            f_temp_out4 <= f_temp_out3;
            vin_temp_out5 <= vin_temp_out4;

            if(MULT_PIPELINED_STAGES == 4) begin
                enable_f <= f_temp_out4;
                valid_out <= vin_temp_out5;
            end
            
            if(reset == 1) begin
                enable_f <= 0;
                f_temp_out4 <= 0;
                valid_out <= 0; 
                vin_temp_out5 <= 0;
            end
        end


        if(MULT_PIPELINED_STAGES == 5 || MULT_PIPELINED_STAGES == 6) begin
            f_temp_out5 <= f_temp_out4;
            vin_temp_out6 <= vin_temp_out5;

            if(MULT_PIPELINED_STAGES == 5) begin
                enable_f <= f_temp_out5;
                valid_out <= vin_temp_out6;
            end

            if(reset == 1) begin  
                enable_f <= 0;
                f_temp_out5 <= 0;  
                valid_out <= 0; 
                vin_temp_out6 <= 0;
            end
        end


        if(MULT_PIPELINED_STAGES == 6) begin
            f_temp_out6 <= f_temp_out5;
            enable_f <= f_temp_out6;
            vin_temp_out7 <= vin_temp_out6;
            valid_out <= vin_temp_out7;
        
            if(reset == 1) begin
                enable_f <= 0;
                f_temp_out6 <= 0;
                vin_temp_out7 <= 0;
            end
        end
            
    end



endmodule

module part4b_mac(clk, reset, a, b, f, valid_in, valid_out);
    input clk, reset, valid_in;
    input signed [13:0] a, b;

    output logic signed [27:0] f;
    output logic valid_out;
    
    logic signed [27:0] prod, sum;
    logic enable_ab, enable_f;
    logic signed [27:0] pipelinedRegOut;
    logic signed [13:0] q1,q2;

    parameter multPipelinedStages = 2;

    // The parameter for the below Controller module specifies the number of multiplier stages required. 
    // **Imp: multPipelinedStages variable should match with the parameter passed to Controller.
    // **Imp: multPipelinedStages must be changed in tb_part4b_mac.sv testbench as well as in testbench_part4b.c.
    Controller #(2) controller(.clk(clk), .valid_in(valid_in), .enable_ab(enable_ab), .enable_f(enable_f), .valid_out(valid_out), .reset(reset));
    D_FF_13b D1(a,q1,clk,enable_ab, reset);
    D_FF_13b D2(b,q2,clk,enable_ab, reset); 

    logic [27:0] MIN_VALUE, MAX_VALUE;
    assign MAX_VALUE = 28'h7ffffff;
    assign MIN_VALUE = 28'h8000000;   
    
    always_comb begin
        sum = pipelinedRegOut + f;        
        if(pipelinedRegOut[27] && f[27] && ~sum[27]) begin
            sum = MIN_VALUE;  
        end
        else if(~pipelinedRegOut[27] && ~f[27] && sum[27]) begin
            sum = MAX_VALUE;
        end
    end
    

    generate
        if(multPipelinedStages == 2)      DW02_mult_2_stage #(14, 14) pipelinedMultiplier(q1, q2, 1'b1, clk, prod);
        else if(multPipelinedStages == 3) DW02_mult_3_stage #(14, 14) pipelinedMultiplier(q1, q2, 1'b1, clk, prod);
        else if(multPipelinedStages == 4) DW02_mult_4_stage #(14, 14) pipelinedMultiplier(q1, q2, 1'b1, clk, prod);
        else if(multPipelinedStages == 5) DW02_mult_5_stage #(14, 14) pipelinedMultiplier(q1, q2, 1'b1, clk, prod);
        else if(multPipelinedStages == 6) DW02_mult_6_stage #(14, 14) pipelinedMultiplier(q1, q2, 1'b1, clk, prod);    
    endgenerate   

    
    D_FF_PipelineReg_28b pipelineReg(prod, pipelinedRegOut, clk, reset);
    D_FF_28b D_FF_28b(sum, f, clk, enable_f, reset);

endmodule
