/*=======================================================================================

 Parameters Definition for M24XXX_Parameters Behavioral Model

=========================================================================================

 This program is provided "as is" without warranty of any kind, either
 expressed or implied, including but not limited to, the implied warranty
 of merchantability and fitness for a particular purpose. The entire risk
 as to the quality and performance of the program is with you. Should the
 program prove defective, you assume the cost of all necessary servicing,
 repair or correction.
 
 Copyright 2012, STMicroelectronics Corporation, All Right Reserved.

=======================================================================================*/

`timescale 1ns/1ns

`ifdef "M1Kb"
   `define         Ei_Inputs       3
   `define         Data_Bits       8
   `define         Address_Byte    1
   `define         Address_Bits    7
   `define         Page_Size       16      //the number of bytes in one page
   `define         Page_No_Bits    3       //2^(Page_No_Bits) = Total Pages; Ex. 8 pages in M24C01, 2^3=8
   `define         Page_Addr_Bits  4
   `define         Memory_Size     128     //the number of bytes in memory
   `define         MEM_1K_to_16K 
   `define         Valid_Part      1       //Valid Part
`elsif "M2Kb"
   `define         Ei_Inputs       3
   `define         Data_Bits       8
   `define         Address_Byte    1
   `define         Address_Bits    8
   `define         Page_Size       16      //the number of bytes in one page
   `define         Page_No_Bits    4       //2^(Page_No_Bits) = Total Pages; Ex. 16 pages in M24C02, 2^4=16
   `define         Page_Addr_Bits  4
   `define         Memory_Size     256     //the number of bytes in memory
   `define         MEM_1K_to_16K 
   `define         Valid_Part      1       //Valid Part
`elsif "M4Kb"
   `define         Ei_Inputs       2
   `define         Data_Bits       8
   `define         Address_Byte    1
   `define         Address_Bits    9
   `define         Page_Size       16      //the number of bytes in one page
   `define         Page_No_Bits    5       //2^(Page_No_Bits) = Total Pages; Ex. 32 pages in M24C04, 2^5=32
   `define         Page_Addr_Bits  4
   `define         Memory_Size     512     //the number of bytes in memory
   `define         MEM_1K_to_16K 
   `define         Valid_Part      1       //Valid Part
`elsif "M8Kb"
   `define         Ei_Inputs       1
   `define         Data_Bits       8
   `define         Address_Byte    1
   `define         Address_Bits    10
   `define         Page_Size       16      //the number of bytes in one page
   `define         Page_No_Bits    6       //2^(Page_No_Bits) = Total Pages; Ex. 64 pages in M24C08, 2^6=64
   `define         Page_Addr_Bits  4
   `define         Memory_Size     1024    //the number of bytes in memory
   `define         MEM_1K_to_16K 
   `define         Valid_Part      1       //Valid Part
`elsif "M16Kb"
   `define         Ei_Inputs       0
   `define         Data_Bits       8
   `define         Address_Byte    1
   `define         Address_Bits    11
   `define         Page_Size       16      //the number of bytes in one page
   `define         Page_No_Bits    7       //2^(Page_No_Bits) = Total Pages; Ex. 128 pages in M24C16, 2^7=128
   `define         Page_Addr_Bits  4
   `define         Memory_Size     2048    //the number of bytes in memory
   `define         MEM_1K_to_16K 
   `define         Valid_Part      1       //Valid Part
`elsif "M32Kb"
   `define         Ei_Inputs       3
   `define         Data_Bits       8
   `define         Address_Byte    2
   `define         Address_Bits    12
   `define         Page_Size       32      //the number of bytes in one page
   `define         Page_No_Bits    7       //2^(Page_No_Bits) = Total Pages; Ex. 128 pages in M24C64, 2^7=128
   `define         Page_Addr_Bits  5
   `define         Memory_Size     4096    //the number of bytes in memory
   `define         MEM_32K_to_2M 
   `define         Valid_Part      1       //Valid Part
`elsif "M64Kb"
   `define         Ei_Inputs       3
   `define         Data_Bits       8
   `define         Address_Byte    2
   `define         Address_Bits    13
   `define         Page_Size       32      //the number of bytes in one page
   `define         Page_No_Bits    8       //2^(Page_No_Bits) = Total Pages; Ex. 256 pages in M24C64, 2^8=256
   `define         Page_Addr_Bits  5
   `define         Memory_Size     8192    //the number of bytes in memory
   `define         MEM_32K_to_2M 
   `define         Valid_Part      1       //Valid Part
`elsif "M128Kb"
   `define         Ei_Inputs       3
   `define         Data_Bits       8
   `define         Address_Byte    2
   `define         Address_Bits    14
   `define         Page_Size       64      //the number of bytes in one page
   `define         Page_No_Bits    8       //2^(Page_No_Bits) = Total Pages; Ex. 256 pages in M24128, 2^8=256
   `define         Page_Addr_Bits  6
   `define         Memory_Size     16384   //the number of bytes in memory
   `define         MEM_32K_to_2M 
   `define         Valid_Part      1       //Valid Part
`elsif "M256Kb"
   `define         Ei_Inputs       3
   `define         Data_Bits       8
   `define         Address_Byte    2
   `define         Address_Bits    15
   `define         Page_Size       64      //the number of bytes in one page
   `define         Page_No_Bits    9       //2^(Page_No_Bits) = Total Pages; Ex. 512 pages in M24256, 2^9=512
   `define         Page_Addr_Bits  6
   `define         Memory_Size     32768   //the number of bytes in memory
   `define         MEM_32K_to_2M
   `define         Valid_Part      1       //Valid Part
`elsif "M512Kb"
   `define         Ei_Inputs       3
   `define         Data_Bits       8
   `define         Address_Byte    2
   `define         Address_Bits    16
   `define         Page_Size       128     //the number of bytes in one page
   `define         Page_No_Bits    9       //2^(Page_No_Bits) = Total Pages; Ex. 512 pages in M24512, 2^9=512
   `define         Page_Addr_Bits  7
   `define         Memory_Size     65536   //the number of bytes in memory
   `define         MEM_32K_to_2M 
   `define         Valid_Part      1       //Valid Part
`elsif "M1Mb"
   `define         Ei_Inputs       2
   `define         Data_Bits       8
   `define         Address_Byte    2
   `define         Address_Bits    17
   `define         Page_Size       256     //the number of bytes in one page
   `define         Page_No_Bits    9      //2^(Page_No_Bits) = Total Pages; Ex. 512 pages in M24M01, 2^10=1024
   `define         Page_Addr_Bits  8
   `define         Memory_Size     131072   //the number of bytes in memory
   `define         MEM_32K_to_2M
   `define         Valid_Part      1       //Valid Part
`elsif "M2Mb"
   `define         Ei_Inputs       1
   `define         Data_Bits       8
   `define         Address_Byte    2
   `define         Address_Bits    18
   `define         Page_Size       256     //the number of bytes in one page
   `define         Page_No_Bits    10      //2^(Page_No_Bits) = Total Pages; Ex. 1024 pages in M24M02, 2^10=1024
   `define         Page_Addr_Bits  8
   `define         Memory_Size     262144   //the number of bytes in memory
   `define         MEM_32K_to_2M
   `define         Valid_Part      1       //Valid Part
`else
   `define         Ei_Inputs       1
   `define         Data_Bits       8
   `define         Address_Byte    2
   `define         Address_Bits    18
   `define         Page_Size       256     //the number of bytes in one page
   `define         Page_No_Bits    10      //2^(Page_No_Bits) = Total Pages; Ex. 1024 pages in M24M02, 2^10=1024
   `define         Page_Addr_Bits  8
   `define         Memory_Size     262144   //the number of bytes in memory
   `define         MEM_32K_to_2M 
   `define         Valid_Part      0       //Valid Part
`endif

`ifdef "M1Kb"
   `define M1Kb_var               1             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M2Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               1
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M4Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               1
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M8Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               1
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M16Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              1
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M32Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              1
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M64Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              1
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M128Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             1
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M256Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             1
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M512Kb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             1
   `define M1Mb_var               0
   `define M2Mb_var               0
`elsif "M1Mb"
   `define M1Kb_var               0            
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               1
   `define M2Mb_var               0
`elsif "M2Mb"
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               1
`else
   `define M1Kb_var               0             
   `define M2Kb_var               0
   `define M4Kb_var               0
   `define M8Kb_var               0
   `define M16Kb_var              0
   `define M32Kb_var              0
   `define M64Kb_var              0
   `define M128Kb_var             0
   `define M256Kb_var             0
   `define M512Kb_var             0
   `define M1Mb_var               0
   `define M2Mb_var               0
`endif  

`ifdef "A125"
   `define A125_var               1
`else
   `define A125_var               0
`endif

`ifdef "S125"
   `define S125_var                1
`else
   `define S125_var                0
`endif

`ifdef "S125"
   `define IDPAGE           0
`elsif "A125"
   `define IDPAGE           1
`elsif "ID"
   `define IDPAGE           1
`else
   `define IDPAGE           0
`endif

`ifdef "W"
   `define W_var                  1
   `define R_var                  0
   `define F_var                  0
   `define X_var                  0
`elsif "R"
   `define W_var                  0
   `define R_var                  1
   `define F_var                  0
   `define X_var                  0
`elsif "F"
   `define W_var                  0
   `define R_var                  0
   `define F_var                  1
   `define X_var                  0
`elsif "X"
   `define W_var                  0
   `define R_var                  0
   `define F_var                  0
   `define X_var                  1
`else
   `define W_var                  0
   `define R_var                  0
   `define F_var                  0
   `define X_var                  0
`endif


//`ifdef MEM_1K_to_16K
//`ifdef MEM_32K_to_2M
//`define MEM_1K_to_16K

//`ifdef MEM_1M_to_2M
