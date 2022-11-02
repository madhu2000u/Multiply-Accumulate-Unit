/*
Authors:
Madhu Sudhanan - 115294248
Suvarna Tirur Ananthanarayanan - 115012264
Date: October 3, 2022
*/

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
using namespace std;

struct{

    signed int a : 14;
    signed int b : 14;
    signed int prod : 28;
    signed int f : 28;

} input;

void filePrintHelper(FILE *inputData, FILE *expectedOutput, int a, int b, int f, bool valid_in, bool valid_out){
    fprintf(inputData, "%x\n%x\n%x\n", valid_in, a & 0x3fff, b & 0x3fff);
    fprintf(expectedOutput, "%07x, %x\n",f & 0xfffffff, valid_out);   //when the most significant hex value is 0, the c code does not print it out the %07x is the format specifier tho print out the 0s as well
        
}

int saturationController(int a, int b, int f){

    input.prod = a * b;
    int temp_sum = input.prod + f;
    if((input.prod & 0x8000000) == 0 && (f & 0x8000000) == 0 && (temp_sum & 0x8000000) == 0x8000000){
        f = 0x7ffffff;
    }else if((input.prod & 0x8000000) == 0x8000000 && (f & 0x8000000) == 0x8000000 && (temp_sum & 0x8000000) == 0){
        f = 0x8000000;
    }
    else{
        f = (input.f + input.prod);
    }
    return f; 

}

void saturationFluctuationCheckers(FILE *inputData, FILE *expectedOutput, int a, int b, int f, bool valid_in, bool valid_out){
    f = saturationController(a, b, f); 
    valid_out = true; 
    filePrintHelper(inputData, expectedOutput, a, b, f, valid_in, valid_out);

}

int main()
{
    int desiredInputs = 1000000; 
    int pipelineStagesMult = 2; 
    srand(time(NULL));        
    FILE *inputData, *expectedOutput;
    inputData = fopen("inputData", "w");
    expectedOutput = fopen("expectedOutput", "w");
    fprintf(expectedOutput, "xxxxxxx, x\n0000000, 0\n0000000, 0\n0000000, 0\n");

    if(pipelineStagesMult == 2){
        fprintf(expectedOutput, "0000000, 0\n");
    }
    else if(pipelineStagesMult == 3){
        fprintf(expectedOutput, "0000000, 0\n0000000, 0\n");
    }
    else if(pipelineStagesMult == 4){
        fprintf(expectedOutput, "0000000, 0\n0000000, 0\n0000000, 0\n");
    }
    else if(pipelineStagesMult == 5){
        fprintf(expectedOutput, "0000000, 0\n0000000, 0\n0000000, 0\n0000000, 0\n");
    }
    else if(pipelineStagesMult == 6){
        fprintf(expectedOutput, "0000000, 0\n0000000, 0\n0000000, 0\n0000000, 0\n0000000,0\n");
    }

    int i, saturationRangeTest = 10, reset = 0;  // SaturationRangeTest is just used for the loop that manually saturates the MAC by providing maximum values of a and b saturationRangeTest number of times.
    bool valid_in, valid_out;
    
    input.f = 0;
    for(i = 0; i < saturationRangeTest; i++){
        valid_out = false;
        valid_in = 1;
        input.a = 8191;         // Testing for +ve saturation by inputing the highest possible values so that we can reach saturation faster. 
        input.b = 8191;         // Since the product, sum and other parts of the design work correctly, this testing can indeed be considered comprehensive or throrough as we are only testing for saturation here.
        if(valid_in){
            input.f = saturationController(input.a, input.b, input.f);                              
            valid_out = true;
        }    

        filePrintHelper(inputData, expectedOutput, input.a, input.b, input.f, valid_in, valid_out);   
    }

    
    // This manual testing is done to check whether the overflow value reduces to a non-overflow value from the +ve saturation. So just one test value is enough
    // saturationFluctuaitonChecker #1
    saturationFluctuationCheckers(inputData, expectedOutput, 5800, -3500, input.f, valid_in, valid_out);

    // Add the below product of +ve a and +ve b back to sum to check if the non-overflow value that reduced from +ve saturation in the above step goes back to +ve saturation.
    // saturationFluctuaitonChecker #2
    saturationFluctuationCheckers(inputData, expectedOutput, 5800, 3600, input.f, valid_in, valid_out);


    for(i = 0; i < saturationRangeTest; i++){   // By keeping a resonably high saturationRangeTest value we can gaurantee that it will reach the -ve saturation from +ve saturation (provided the a and b are the max or fairly high values).
        valid_out = false;
        valid_in = 1;
        input.a = 8191;
        input.b = -8191;     // Testing for -ve saturation by inputing the highest possible values so that we can reach saturation faster.
        if(valid_in){
            input.f = saturationController(input.a, input.b, input.f);                              
            valid_out = true;
        }       
        filePrintHelper(inputData, expectedOutput, input.a, input.b, input.f, valid_in, valid_out);
    }


    // This manual testing is done to check whether the overflow value increses to a non-overflow value from the -ve saturation.
    // saturationFluctuaitonChecker #3
    saturationFluctuationCheckers(inputData, expectedOutput, 5200, 7777, input.f, valid_in, valid_out);  

    // Add the below product of +ve a and -ve b back to sum to check if the non-overflow value that inreased from -ve saturation in the above step reduces back to -ve saturation.
    // saturationFluctuaitonChecker #4
    saturationFluctuationCheckers(inputData, expectedOutput, 5800, -7800, input.f, valid_in, valid_out);
    


    // Saturation is tested comprehensively, now the following test is the usual random numbers generator test.
    for (i = 0; i < desiredInputs; i++)
    {
        valid_out = false;
        valid_in = rand() % 2;
        input.a = (rand() % 16385 - 8192);
        input.b = (rand() % 16385 - 8192);
        if(valid_in){
            input.f = saturationController(input.a, input.b, input.f);                              
            valid_out = true;
        }

        filePrintHelper(inputData, expectedOutput, input.a, input.b, input.f, valid_in, valid_out);
    }
    fclose(inputData);
    fclose(expectedOutput);
}