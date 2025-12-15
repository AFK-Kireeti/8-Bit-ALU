This project is about creating an 8 bit alu that can take in two numbers as input from a pmod keypad and then display the result of the operation on the 7 segment displays. 
To understnad the working of this code we first need to understand all the inputs and output. A pmod keypad can only generate a 4 bit output 0-F(Hexadecimal). but we need 
two 8 bit inputs (why two we need registers A and B from which the ALU will take in the input annd produce the result), hence we will attach a mux at the input that will 
take in a generic 4 bit input and then assign it directlyy to either A0-A3 or A4-A7 or B0-B3 or B4-B7.

The code PMOD_Keypad.vhd takes care of reading the input from the keypad and then assigning the input to a variable which will be the output of this module. It treats the
keypad as a matrix and then one by one it checks the input every 1ms. Then after reading the input the value which was read is sent to the top module which is the 
Interface_Top.vhd file.

This will take the input from theh keypad and then assign it directlyy to either A0-A3 or A4-A7 or B0-B3 or B4-B7. Mind that the input given is signed input hence to check
if the correct input has been fed set the input to A3-A0 set the op code to add and then look at the 7 seg display if it displays the same as the input that you have given 
then the codoe is working properly.

After giving the input set the op code and then wait for the 7 segment display to change.

There are extra codes because the output of the alu is in binary and we need to display it in theh seven seg display. Hence to do that the code set also includes Bin_BCD.vhd
which converts binary to bcd and then displays the output for eg 255 is the output which is 1111 1111 now to display this directly is very diffiult hence we can change it
to a 12 bit output that displays 0001(2) 0101(5) 0101(5). this number now when sent one by one each of the 4 seven segnments can be set individually.
