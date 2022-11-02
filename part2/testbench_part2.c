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
    signed int f : 28;

} input;

int main()
{
    int desiredInputs = 1000000; 
    srand(time(NULL));        
    FILE *inputData, *expectedOutput;
    inputData = fopen("inputData", "w");
    expectedOutput = fopen("expectedOutput", "w");
    fprintf(expectedOutput, "xxxxxxx, x\n0000000, 0\n0000000, 0\n");
    int i;
    bool valid_in, valid_out;

    for (i = 0; i < desiredInputs; i++)
    {
        valid_out = false;
        valid_in = rand() % 2;
        input.a = (rand() % 16385 - 8192);
        input.b = (rand() % 16385 - 8192);
        if(valid_in){
            input.f = (input.f + (input.a * input.b));
            valid_out = true;
        }
        fprintf(inputData, "%x\n%x\n%x\n", valid_in, input.a & 0x3fff, input.b & 0x3fff);
        fprintf(expectedOutput, "%07x, %x\n",input.f & 0xfffffff, valid_out);  //If the last hex values is a 0, the fprintf function ignores that value. So %07x format specifier forces it to include the 0s
        
    }
    fclose(inputData);
    fclose(expectedOutput);
}