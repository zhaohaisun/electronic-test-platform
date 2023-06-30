/*=======================================================================================

 Macro Definitions for M24XXX Behavioral Model

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

//=====================================
//Definition AC,DC specification
//=====================================
`ifdef "S125"
      `define  t_delay  650
      `define  tL_DIV2  650
      `define  tH_DIV2  650

      `define         tCHCL           600     //Min. Clock high pulse width
      `define         tCLCH           1300    //Min. Clock low pulse width
      `define         tDXCX           100     //Min. Data in set up time
      `define         tCLDX           0       //Min. Data in hold time
      `define         tCLQX           100     //Min. Data out hold time
      `define         tCHDX           600     //Min. I2C start condition set up time
      `define         tDLCL           600     //Min. I2C start condition hold time
      `define         tCHDH           600     //Min. I2C stop condition set up time
      `define         tDHDL           1300    //Min. Time between stop condition and next start condition 
      `define         tCLQV_MIN       200     //Min. Clock low to next data valid (access time)
      `define         tCLQV_MAX       900     //Max. Clock low to next data valid (access time)
      `define         tWR             5e6     //Max. Write Time
`elsif "A125"
      `define  t_delay  350
      `define  tL_DIV2  350
      `define  tH_DIV2  350

      `define         tCHCL           260     //Min. Clock high pulse width
      `define         tCLCH           500     //Min. Clock low pulse width
      `define         tDXCX           50      //Min. Data in set up time
      `define         tCLDX           0       //Min. Data in hold time
      `define         tCLQX           100     //Min. Data out hold time
      `define         tCHDX           250     //Min. I2C start condition set up time
      `define         tDLCL           250     //Min. I2C start condition hold time
      `define         tCHDH           250     //Min. I2C stop condition set up time
      `define         tDHDL           500     //Min. Time between stop condition and next start condition 
      `define         tCLQV_MIN       100     //Min. Clock low to next data valid (access time)
      `define         tCLQV_MAX       450     //Max. Clock low to next data valid (access time)
      `define         tWR             4e6     //Max. Write Time
`else
   `ifdef "FREQ1MHz"
      `define  t_delay  350
      `define  tL_DIV2  350
      `define  tH_DIV2  350

      `ifdef "M512Kb"
         `define         tCHCL           300     //Min. Clock high pulse width
         `define         tCLCH           500     //Min. Clock low pulse width
         `define         tDXCX           80      //Min. Data in set up time
         `define         tCLDX           0       //Min. Data in hold time
         `define         tCLQX           50      //Min. Data out hold time
         `define         tCHDX           250     //Min. I2C start condition set up time
         `define         tDLCL           250     //Min. I2C start condition hold time
         `define         tCHDH           250     //Min. I2C stop condition set up time
         `define         tDHDL           500     //Min. Time between stop condition and next start condition 
         `define         tCLQV_MIN       100     //Min. Clock low to next data valid (access time)
         `define         tCLQV_MAX       450     //Max. Clock low to next data valid (access time)
         `define         tWR             5e6     //Max. Write Time
      `elsif "M1Mb"
         `define         tCHCL           300     //Min. Clock high pulse width
         `define         tCLCH           500     //Min. Clock low pulse width
         `define         tDXCX           80      //Min. Data in set up time
         `define         tCLDX           0       //Min. Data in hold time
         `define         tCLQX           50      //Min. Data out hold time
         `define         tCHDX           250     //Min. I2C start condition set up time
         `define         tDLCL           250     //Min. I2C start condition hold time
         `define         tCHDH           250     //Min. I2C stop condition set up time
         `define         tDHDL           500     //Min. Time between stop condition and next start condition 
         `define         tCLQV_MIN       100     //Min. Clock low to next data valid (access time)
         `define         tCLQV_MAX       450     //Max. Clock low to next data valid (access time)
         `define         tWR             5e6     //Max. Write Time
      `elsif "M2Mb"
         `define         tCHCL           260     //Min. Clock high pulse width
         `define         tCLCH           500     //Min. Clock low pulse width
         `define         tDXCX           50      //Min. Data in set up time
         `define         tCLDX           0       //Min. Data in hold time
         `define         tCLQX           100     //Min. Data out hold time
         `define         tCHDX           250     //Min. I2C start condition set up time
         `define         tDLCL           250     //Min. I2C start condition hold time
         `define         tCHDH           250     //Min. I2C stop condition set up time
         `define         tDHDL           500     //Min. Time between stop condition and next start condition 
         `define         tCLQV_MIN       100     //Min. Clock low to next data valid (access time)
         `define         tCLQV_MAX       450     //Max. Clock low to next data valid (access time)
         `define         tWR             10e6    //Max. Write Time
      `else
         `define  t_delay  350
         `define  tL_DIV2  350
         `define  tH_DIV2  350

         `define         tCHCL           260     //Min. Clock high pulse width
         `define         tCLCH           500     //Min. Clock low pulse width
         `define         tDXCX           50      //Min. Data in set up time
         `define         tCLDX           0       //Min. Data in hold time
         `define         tCLQX           100     //Min. Data out hold time
         `define         tCHDX           250     //Min. I2C start condition set up time
         `define         tDLCL           250     //Min. I2C start condition hold time
         `define         tCHDH           250     //Min. I2C stop condition set up time
         `define         tDHDL           500     //Min. Time between stop condition and next start condition 
         `define         tCLQV_MIN       100     //Min. Clock low to next data valid (access time)
         `define         tCLQV_MAX       450     //Max. Clock low to next data valid (access time)
         `define         tWR             5e6     //Max. Write Time
      `endif   
   `else
      `define  t_delay  650
      `define  tL_DIV2  650
      `define  tH_DIV2  650

      `define         tCHCL           600     //Min. Clock high pulse width
      `define         tCLCH           1300    //Min. Clock low pulse width
      `define         tDXCX           100     //Min. Data in set up time
      `define         tCLDX           0       //Min. Data in hold time
      `define         tCLQX           100     //Min. Data out hold time
      `define         tCHDX           600     //Min. I2C start condition set up time
      `define         tDLCL           600     //Min. I2C start condition hold time
      `define         tCHDH           600     //Min. I2C stop condition set up time
      `define         tDHDL           1300    //Min. Time between stop condition and next start condition 
      `define         tCLQV_MIN       200     //Min. Clock low to next data valid (access time)
      `define         tCLQV_MAX       900     //Max. Clock low to next data valid (access time)
      `define         tWR             5e6     //Max. Write Time
   `endif
`endif

