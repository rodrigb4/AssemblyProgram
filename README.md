# Assembly Program - String Primitives and Macros

## Description

Built using x86 MASM Assembly Language.

This program receives a total of 10 signed decimal integers from the user. Each must be able to fit in a 32 bit register. If an input is in some way invalid, an error message is displayed to the user, and the user is prompted to enter another value. 

During the validation of each input, each string of ASCII digits is converted to its numeric value representation through the use of string primitives. 

Once 10 valid values are received and stored, each is converted from a numeric value back to a string of ASCII digits, and then displayed to the user. Their combined sum and their truncated average are also displayed.
