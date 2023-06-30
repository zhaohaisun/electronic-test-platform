/*=======================================================================================

 M24XXX: XXXK bits Serial I2C Bus EEPROM Verilog Simulation Model

=========================================================================================

 This program is provided "as is" without warranty of any kind, either
 expressed or implied, including but not limited to, the implied warranty
 of merchantability and fitness for a particular purpose. The entire risk
 as to the quality and performance of the program is with you. Should the
 program prove defective, you assume the cost of all necessary servicing,
 repair or correction.
 
 Copyright 2012, STMicroelectronics Corporation, All Right Reserved.

=======================================================================================*/


/*=======================================================================================
                                   REVISION HISTORY

rev1.0 (29 Jan 2013)
- first release
rev1.1 (19 Nov 2013)
- current and random read: fix for the automatic address increment at the end
of the transaction.
=======================================================================================*/
`define M2Kb
`include "../I2C_Tes/M24XXX_Macro.v"
`include "../I2C_Tes/M24XXX_Parameters.v"



//`include "M24XXX_Macro.v"
//`include "M24XXX_Parameters.v"

//=====================================
//M24XXX behavior simulation model
//=====================================
module M24XXX (
                    Ei,
                    SDA,
                    SCL,
                    WC,
                    VCC
              );

//=====================================
//Definition Signal IO Direction
//=====================================
input[`Ei_Inputs-1:0] Ei;
inout SDA;
input SCL,WC,VCC;

//=====================================
//Variables Definition
//=====================================
integer i,bit;  //loop variable,data bit shift output ctr

wire SDA;
reg reset,byte_ok,ack_cycle,dur_wr_ins;
reg power_on,power_off,power_on_reset;
reg start_flag,stop_flag,wr_protect,wr_busy,wc_glitch;
reg sda_out,sda_out_en,write_en,byte_data_in;
reg address_h,address_l,address_h_ok,address_l_ok;
reg address,address_ok;
reg random_address_read_en,current_address_read_en;
reg dev_sel_code1,dev_sel_again;
reg bit_counter_en,bit_counter_ld;
reg wr_cycle_id,random_rd_id,data_write_in_en;
reg curd_wait_ack,rnrd_wait_ack;
reg curd_over,rnrd_over,curd_acked,rnrd_acked;

reg[2:0] operation,bit_counter;
reg[7:0] shift_reg,dev_sel_1,dev_sel_2,address_lsb,address_byte;
reg[`Address_Bits-9:0] address_msb;
reg[6:0] dev_sel_1_cmp;
reg[`Page_No_Bits-1:0] page_number;
reg[`Data_Bits-1:0] internal_latch[`Page_Size-1:0];
reg[`Data_Bits-1:0] memory_id[`Page_Size-1:0];
reg[`Data_Bits-1:0] dat_out,memory[`Memory_Size-1:0];
reg[`Address_Bits-1:0] memory_address,start_address,end_address;
reg id_page,id_page_lock,no_wrap_flag;

//=========================================================
//Define Parameter Regarding Operation Mode
//=========================================================
parameter   no_operation         = 3'b000;
parameter   current_address_read = 3'b001;
parameter   random_address_read  = 3'b010;
parameter   write_in             = 3'b011;
parameter   stand_by             = 3'b100;
parameter   write_id_in          = 3'b101;

//===============================================
//Initialization
//===============================================
initial begin
            reset = 1'b0;
            power_on_reset = 1'b0;
            id_page_lock   = 1'b0;
        end

//=====================================
//Device Power On/Off
//=====================================
always@(VCC)
begin
    if(VCC == 1'b1)
    begin
        power_on  = 1'b1;
        power_off = 1'b0;
        power_on_reset = 1'b1;
        $display("%t, NOTE: Device Power On!\n",$realtime);
    end
    else begin
        if(power_on == 1'b1) $display("%t, NOTE: Device Power Off!\n",$realtime);
        power_on  = 1'b0;
        power_off = 1'b1;
    end
end

//================================
//Device Power On Reset
//================================
always@(power_on_reset)
begin
    if(power_on_reset == 1'b1)
    begin
        operation      = no_operation;
        reset          = 1'b1;
        sda_out_en     = 1'b1;
        start_flag     = 1'b0;
        memory_address = {`Address_Bits {1'b0}};
        $display("%t, NOTE: RESETING DEVICE!\n",$realtime);
    end
end

//================================
//I2C START Condition Reset
//================================
always@(reset)
begin
    if(reset == 1'b1)
    begin
        reset          = 1'b0;
        write_en       = 1'b0;
        wc_glitch      = 1'b0;
        stop_flag      = 1'b0;
        ack_cycle      = 1'b0;
        byte_ok        = 1'b0;
        wr_busy        = 1'b0;
        wr_protect     = 1'b0;
        random_rd_id   = 1'b0;
        dur_wr_ins     = 1'b1;
        curd_over      = 1'b0;
        rnrd_over      = 1'b0;
        curd_acked     = 1'b0;
        rnrd_acked     = 1'b0;
        address_h      = 1'b0;
        address_l      = 1'b0;
        address_h_ok   = 1'b0;
        address_l_ok   = 1'b0;
        address        = 1'b0;
        address_ok     = 1'b0;
        curd_wait_ack  = 1'b0;
        rnrd_wait_ack  = 1'b0;
        dev_sel_code1  = 1'b0;
        dev_sel_again  = 1'b0;
        bit_counter_en = 1'b0;
        bit_counter_ld = 1'b0;
        random_address_read_en  = 1'b0;
        current_address_read_en = 1'b0;
        id_page        = 1'b0;
        no_wrap_flag   = 1'b0;

    end
end
//===============================================
//SDA IO mode control(direction select)
//--- sda_out_en=1: SDA as input
//--- sda_out_en=0: SDA as output
//===============================================
assign SDA = sda_out_en ? 1'bz : sda_out;

//================================
//Write Protection identify
//================================
always@(WC)
begin
    if(dur_wr_ins == 1'b1)
    begin
        wc_glitch = 1'b1;
        if(WC== 1'b1) wr_protect = 1'b1; //WC = 1,write inhibited
    end
end

//=============================================================================
//Detect I2C START,STOP CONDITION
//------ I2C stop:set stop_flag, into "no_operation mode", wait re-start.
//------ I2C start:set start_flag, into "stand_by mode", wait dev sel code.
//=============================================================================
always@(negedge SDA)
begin
    if((SCL==1)&&(SDA==0))        //when clock is high, falling edge happens on SDA.
    begin                         //I2C start condition.
        if(((power_off == 1'b0)&&(power_on == 1'b1))&&(wr_busy == 1'b0))
        begin
            stop_flag  = 1'b0;
            start_flag = 1'b1;
            if(random_rd_id == 1'b1) reset = 1'b0;
            else begin
                if(operation == write_in)
                    $display("%t, ERROR: I2C Start Condition happens in the middle of write in data byte.\n",$realtime);
                if(operation == write_id_in)
                    $display("%t, ERROR: I2C Start Condition happens in the middle of write ID in data byte.\n",$realtime);
                if(operation == current_address_read)
                    $display("%t, ERROR: I2C Start Condition happens in ACK waiting cycle during Current address read.\n",$realtime);
                if(operation == random_address_read)
                    $display("%t, ERROR: I2C Start Condition happens in ACK waiting cycle during Random address read.\n",$realtime);
                if(operation == stand_by)
                begin
                    if(curd_over == 1'b1)
                        $display("%t, ERROR: I2C Start Condition happens after last data byte read out,this time needs I2C Stop Condition to terminate the current address read operation.\n",$realtime);
                    else if(rnrd_over == 1'b1)
                        $display("%t, ERROR: I2C Start Condition happens after last data byte read out,this time needs I2C Stop Condition to terminate the random address read operation.\n",$realtime);
                    else if(dev_sel_code1 == 1'b1)
                        $display("%t, ERROR: I2C Start Condition happens during the first Device Select Code input.\n",$realtime);
                    else if(address_h == 1'b1)
                        $display("%t, ERROR: I2C Start Condition happens during the high byte address input.\n",$realtime);
                    else if(address_l == 1'b1)
                        $display("%t, ERROR: I2C Start Condition happens during the low byte address input.\n",$realtime);
                    else if(address == 1'b1)
                        $display("%t, ERROR: I2C Start Condition happens during the address byte input.\n",$realtime);
                    else if(dev_sel_again == 1'b1)
                        $display("%t, ERROR: I2C Start Condition happens during the second Device Select Code input.\n",$realtime);
                end
                if(WC == 1'b1) wr_protect = 1'b1;
                operation = stand_by;
                reset = 1'b1;     //random read identify flag is not set,device reset 
            end
        end
        else begin
            if(wr_busy == 1'b1)
                $display("%t, WARNING: During the internal Write cycle, SDA is disabled and the device does not respond to any requests.",$realtime);
            if((power_off == 1'b1) && (power_on == 1'b0)) 
                $display("%t, ERROR: Device is not Powered On, the device will not respond to any command.",$realtime);
        end
    end
    else start_flag = 1'b0;
end
//-----------------------------------------------
always@(posedge SDA)
begin
    if((SCL==1)&&(SDA==1))              //when clock is high, rising edge happens on SDA.
    begin
        if(((power_off == 1'b0)&&(power_on == 1'b1))&&(wr_busy == 1'b0))
        begin                           //I2C stop condition.
            stop_flag  = 1'b1;
            start_flag = 1'b0;
        end
        else begin
            if(wr_busy == 1'b1)
                $display("%t, WARNING: During the internal Write cycle, SDA is disabled and the device does not respond to any requests.",$time);
            if((power_off == 1'b1)&&(power_on == 1'b0))
                $display("%t, ERROR: Device is not Powered On, the device will not respond to any command.",$realtime);
        end
    end
    else stop_flag = 1'b0;
end

//=====================================================================================//
// Serial Data Bit on I2C Bus Input Control                                            //
// ------when one byte data on I2C bus input complete,ser "BYTE_OK"                    //
//=====================================================================================//
always@(posedge SCL)
begin
    if(((power_off == 1'b0)&&(power_on == 1'b1))&&(wr_busy == 1'b0))
    begin
        if((bit_counter_en) && (bit_counter_ld))
        begin
            sda_out_en = 1'b1;                      //SDA as input mode
            shift_reg = {shift_reg[6:0],SDA};
            bit_counter = 3'b111;                   //I2C start or one byte begin transfer,load counter.
        end
        else if((bit_counter_en) && (!bit_counter_ld))
        begin
            sda_out_en = 1'b1;                      //SDA as input mode
            shift_reg = {shift_reg[6:0],SDA};
            bit_counter = bit_counter - 3'b001;     //During 1 byte transfer, bit counter decrease.
        end

        if((bit_counter_en) && (bit_counter == 3'b000))
        begin
            byte_ok = 1'b1;
            bit_counter_en = 1'b0;                  //1 byte ok, bit counter disable.
        end
        else if(bit_counter_en) bit_counter_ld = 1'b0;
    end
    else begin
        if(wr_busy == 1'b1) $display("%t, WARNING: During the internal Write cycle, SDA is disabled and the device does not respond to any requests.",$realtime);
        if((power_off == 1'b1)&&(power_on == 1'b0))
            $display("%t, ERROR: Device is not Powered On, the device will not respond to any command.",$realtime);
    end
end

//=======================================================//
// Wait ACK from Master after One Data Byte Read Out     //
//=======================================================//
always@(posedge SCL)
begin
    if(curd_wait_ack == 1'b1)
    begin
        curd_wait_ack = 1'b0;
        if(SDA==0)      //if bus master ACK,address increment read out next byte
        begin
            bit=8;
            curd_acked = 1'b1;
            if(id_page == 1'b1) begin
               if(memory_address[`Page_Addr_Bits-1:0] == {`Page_Addr_Bits {1'b1}}) begin
                  $display("%t, NOTE: End of ID boundry reached on current read\n",$realtime);
                  no_wrap_flag = 1'b1;
                  memory_address[`Page_Addr_Bits-1:0] = {`Page_Addr_Bits {1'b0}}; 
               end
               else begin
                  if(no_wrap_flag) $display("%t, NOTE: Wrapping of ID Memory on current read.",$realtime); 
                  memory_address[`Page_Addr_Bits-1:0] = memory_address[`Page_Addr_Bits-1:0] + {{`Page_Addr_Bits-1 {1'b0}},1'b1};
               end
            end
            else begin
               if(memory_address == {`Address_Bits {1'b1}}) 
                  memory_address = {`Address_Bits {1'b0}}; 
               else 
                  memory_address = memory_address + {{`Address_Bits-1 {1'b0}},1'b1};
            end
        end
        else            //if bus master not ACK,terminal the data transfer and into stand_by
        begin
            if(no_wrap_flag) $display("%t, ERROR: Wrapping of ID Memory on current read.",$realtime); 
            else begin
               if(memory_address == {`Address_Bits {1'b1}}) 
                  memory_address = {`Address_Bits {1'b0}}; 
               else 
                  memory_address = memory_address + {{`Address_Bits-1 {1'b0}},1'b1};
            end 

            no_wrap_flag = 1'b0;
            curd_over    = 1'b1;
            operation    = stand_by;
        end
    end
    //-----------------------------------------------
    if(rnrd_wait_ack == 1'b1)
    begin
        rnrd_wait_ack = 1'b0;
        if(SDA==0)      //if bus master ACK,address increment read out next byte
        begin
            bit=8;
            rnrd_acked = 1'b1;
            if(id_page == 1'b1) begin
               if(memory_address[`Page_Addr_Bits-1:0] == {`Page_Addr_Bits {1'b1}}) begin
                  $display("%t, NOTE: End of ID boundry reached on ramdom read.",$realtime);
                  no_wrap_flag = 1'b1;
                  memory_address[`Page_Addr_Bits-1:0] = {`Page_Addr_Bits {1'b0}}; 
               end
               else begin
                  if(no_wrap_flag) $display("%t, ERROR: Wrapping of ID Memory on current read.",$realtime); 
                  memory_address[`Page_Addr_Bits-1:0] = memory_address[`Page_Addr_Bits-1:0] + {{`Page_Addr_Bits-1 {1'b0}},1'b1};
               end
            end
            else begin
               if(memory_address == {`Address_Bits {1'b1}}) 
                  memory_address = {`Address_Bits {1'b0}};
               else 
                 memory_address = memory_address + {{`Address_Bits-1 {1'b0}},1'b1};
            end
        end
        else            //if bus master not ACK,terminal the data transfer and into stand_by
        begin
            if(no_wrap_flag) $display("%t, ERROR: Wrapping of ID Memory on current read.",$realtime); 
            else begin
               if(memory_address == {`Address_Bits {1'b1}}) 
                  memory_address = {`Address_Bits {1'b0}};
               else 
                 memory_address = memory_address + {{`Address_Bits-1 {1'b0}},1'b1};
            end

            no_wrap_flag = 1'b0;
            rnrd_over    = 1'b1;
            operation    = stand_by;
        end
    end
end

//======================================================//
//=====       memory operation state machine       =====//
//======================================================//
always@(negedge SCL or posedge stop_flag)
begin
//////////////////////////////////////////////////////////
    //"STOP" dosen't happen in 10th time slot, then continue to write next byte data
    if((stop_flag == 1'b0)&&(wr_cycle_id == 1'b1))  wr_cycle_id = 1'b0;
    //-----------------------------------------------
    if(stop_flag == 1'b1)                               //"STOP" condition happens
    begin
        stop_flag = 1'b0;       sda_out_en = 1'b1;      //SDA input mode
        bit_counter_en = 1'b0;  bit_counter_ld = 1'b0;  //disable bit_counter
    //---------------------------------------
        if(operation == stand_by)                       //"STOP" happens during memory in stand_by mode
        begin
            operation = no_operation;
            if(curd_over == 1'b1)
            begin
                curd_over = 1'b0;
                $display("%t, NOTE: Current Address Read Operation Completed Successfully.\n",$realtime);
            end
            else if(rnrd_over == 1'b1)
            begin
                rnrd_over = 1'b0;
                $display("%t, NOTE: Random Address Read Operation Completed Successfully.\n",$realtime);
            end
            else if(dev_sel_code1 == 1'b1)
            begin
                dev_sel_code1 = 1'b0;
                $display("%t, ERROR: I2C STOP Condition happens during the first Device Select Code input.\n",$realtime);
            end
            else if(address_h == 1'b1)
            begin
                address_h = 1'b0;
                $display("%t, ERROR: I2C STOP Condition happens during the high byte address input.\n",$realtime);
            end
            else if(address_l == 1'b1)
            begin
                if(id_page) begin
                   reset = 1'b1;
                   if(id_page_lock)
                     $display("%t, NOTE: Read Lock status -- ID Memory Page Locked.",$realtime);
                   else
                     $display("%t, NOTE: Read Lock status -- ID Memory Page Unlocked.",$realtime);
                   
                   $display("%t, NOTE: Read Lock status complete\n",$realtime);
                end
                else begin
                   address_l = 1'b0;
                   $display("%t, ERROR: I2C STOP Condition happens during the low byte address input.\n",$realtime);
                end
            end
            else if(address == 1'b1)
            begin
                address = 1'b0;
                $display("%t, ERROR: I2C STOP Condition happens during the address byte input.\n",$realtime);
            end
            else if(dev_sel_again == 1'b1)
            begin
                dev_sel_again = 1'b0;
                $display("%t, ERROR: I2C STOP Condition happens during the second Device Select Code input.\n",$realtime);
            end
        end 
    //---------------------------------------
        else if(operation == current_address_read)  //"STOP" happens during current address read operation
        begin
            operation = no_operation;
            if(curd_acked == 1'b1)
            begin
                curd_acked   = 1'b0;
                no_wrap_flag = 1'b0;
                $display("%t, ERROR: I2C STOP Condition happens in ACK waiting cycle during Current address read.\n",$realtime);
                $display("%t, ERROR: To terminate the Current Address Read Operation, Bus master must not ACK the last byte before I2C STOP Condition.\n",$realtime);
            end
            //else $display("%t, ERROR: The STOP Condition is in the middle of one byte data read out.\n",$realtime);
        end        
    //---------------------------------------
        else if(operation == random_address_read)   //"STOP" happens during random address read operation
        begin
            operation = no_operation;
            if(rnrd_acked == 1'b1)
            begin
                rnrd_acked   = 1'b0;
                no_wrap_flag = 1'b0;
                $display("%t, ERROR: I2C STOP Condition happens in ACK waiting cycle during Random address read.\n",$time);
                $display("%t, ERROR: To terminate the Random Address Read Operation, Bus master must not ACK the last byte before I2C STOP Condition.\n",$time);
            end
            //else $display("%t, ERROR: The STOP Condition is in the middle of one byte data read out.\n",$realtime);
        end
    //---------------------------------------
        else if(operation == write_in)              //"STOP" happens during write data operation
        begin
            data_write_in_en = 1'b0;                //Clear the data write operation flag
            operation = no_operation;
            if((wr_cycle_id == 1'b1)&&(wr_protect == 1'b0))
            begin                                   //"STOP" in 10th time slot&write enable,internal Write Cycle triggered
                wr_cycle_id = 1'b0;
                wr_busy = 1'b1;
                if(start_address == end_address)
                begin
                    for(i=1;i<=`Page_Size;i=i+1)
                    begin
                        memory[start_address] = internal_latch[start_address[`Page_Addr_Bits-1:0]];
                        if(start_address[`Page_Addr_Bits-1:0] == {`Page_Addr_Bits {1'b1}})
                            start_address[`Page_Addr_Bits-1:0] = {`Page_Addr_Bits {1'b0}};
                        else start_address = start_address + 1;
                    end
                end
                else begin
                    while(!(start_address == end_address))
                    begin
                        memory[start_address] = internal_latch[start_address[`Page_Addr_Bits-1:0]];
                        if(start_address[`Page_Addr_Bits-1:0] == {`Page_Addr_Bits {1'b1}})
                            start_address[`Page_Addr_Bits-1:0] = {`Page_Addr_Bits {1'b0}};
                        else start_address = start_address + 1;
                    end
                end
                //#(`tWR);
                
                #(64);  //pjj
                
                wr_busy = 1'b0;
                $display("%t, NOTE: Page[%d] Write Operation Complete.\n",$realtime,page_number);
            end
            else if((wr_cycle_id == 1'b1)&&(wr_protect == 1'b1))
                $display("%t, WARNING: Device replies to each data byte with NoAck! The Content of Memory is not modified.\n",$realtime);
            else if(wr_cycle_id == 1'b0)            //"STOP" happens in an error time slot
            begin
                $display("%t, ERROR: Stop Condition doesn't happen in 10th bit time slot,Internal Memory Write Cycle cann't be triggered!\n",$realtime);
                $display("%t, ERROR: Write Operation Failed!\n",$realtime);
            end
        end
    //---------------------------------------
        else if(operation == write_id_in)              //"STOP" happens during write data operation
        begin
            data_write_in_en = 1'b0;                //Clear the data write operation flag
            operation = no_operation;
            if((wr_cycle_id == 1'b1)&&(id_page_lock == 1'b0) && (id_page == 1'b1))
            begin                                   //"STOP" in 10th time slot&write enable,internal Write Cycle triggered
                wr_cycle_id = 1'b0;
                wr_busy = 1'b1;
                if(start_address[`Page_Addr_Bits-1:0] == end_address[`Page_Addr_Bits-1:0])
                begin
                    if (start_address[`Page_Addr_Bits-1:0] >= end_address[`Page_Addr_Bits-1:0]) begin
                       if (end_address[`Page_Addr_Bits-1:0] !== 0)
                          $display("%t, start=%h end=%h WARNING1: Wrap Around write on Memory ID block.",$realtime,start_address,end_address);
                    end
                    for(i=1;i<=`Page_Size;i=i+1)
                    begin : loop1
                        memory_id[start_address[`Page_Addr_Bits-1:0]] = internal_latch[start_address[`Page_Addr_Bits-1:0]];
                        if(start_address[`Page_Addr_Bits-1:0] == {`Page_Addr_Bits {1'b1}}) begin
                            //start_address[`Page_Addr_Bits-1:0] = {`Page_Addr_Bits {1'b0}};
                            start_address[`Page_Addr_Bits-1:0] = {`Page_Addr_Bits {1'b0}};  //take out if wrap around not allowed
                            $display("%t, NOTE1: Writing the last address in the ID Page!",$realtime);  //must warn if wraps
                            //disable loop1;//insert if wrap is not allowed
                        end
                        else start_address[`Page_Addr_Bits-1:0] = start_address[`Page_Addr_Bits-1:0] + 1;
                    end
                end
                else begin 
                    if (start_address[`Page_Addr_Bits-1:0] >= end_address[`Page_Addr_Bits-1:0]) begin
                       if (end_address[`Page_Addr_Bits-1:0] !== 0)
                          $display("%t, start=%h end=%h WARNING2: Wrap Around write on Memory ID block.",$realtime,start_address,end_address);
                    end

                    while(!(start_address[`Page_Addr_Bits-1:0] == end_address[`Page_Addr_Bits-1:0]))
                    begin : loop2
                        memory_id[start_address[`Page_Addr_Bits-1:0]] = internal_latch[start_address[`Page_Addr_Bits-1:0]];
                        if(start_address[`Page_Addr_Bits-1:0] == {`Page_Addr_Bits {1'b1}}) begin
                            start_address[`Page_Addr_Bits-1:0] = {`Page_Addr_Bits {1'b0}};  //take out if wrap around not allowed
                            $display("%t, NOTE2: Writing the last address in the ID Page!",$realtime);  //must warn if wraps
                            //disable loop2; //insert if wrap is not allowed
                        end
                        else start_address[`Page_Addr_Bits-1:0] = start_address[`Page_Addr_Bits-1:0] + 1;
                    end
                end                
                //#(`tWR);
                
                #(64);  //pjj
                wr_busy = 1'b0;
                $display("%t, NOTE: ID Memory Page Write Operation Complete.\n",$realtime);
            end
            else if((wr_cycle_id == 1'b1)&&(id_page_lock == 1'b1) && (id_page == 1'b1))
                $display("%t, WARNING: Device replies to each data byte with NoAck! The Content of ID Memory is not modified.\n",$realtime);
            else if(wr_cycle_id == 1'b0)            //"STOP" happens in an error time slot
            begin
                $display("%t, ERROR: Stop Condition doesn't happen in 10th bit time slot,Internal ID Memory Write Cycle cann't be triggered!\n",$realtime);
                $display("%t, ERROR: Write ID Operation Failed!\n",$realtime);
            end
        end
    //---------------------------------------
        //else if(operation == no_operation)
        //    $display("%t, WARNING: The I2C Bus has been in STOP status,please send I2C Start Condition to begin a new communication.\n",$time);
    end
//////////////////////////////////////////////////////////
    if((start_flag == 1'b1) && (random_rd_id == 1'b0))  //start or re-start for a new communication.
    begin
        start_flag     = 1'b0;                          //clear I2C start flag
        dev_sel_code1  = 1'b1;
        bit_counter_en = 1'b1;                          //enable bit_counter
        bit_counter_ld = 1'b1;                          //load bit_counter initial value
    end
//------------------------------------------------------//
    else
    if((start_flag == 1'b1) && (random_rd_id == 1'b1))  //re-start and continue to decode instruction
    begin
        start_flag       = 1'b0;                        //clear I2C start flag
        random_rd_id     = 1'b0;                        //clear random read identification
        dev_sel_again    = 1'b1;                        //next byte,receive the second device select code
        bit_counter_en   = 1'b1;                        //enable bit_counter
        bit_counter_ld   = 1'b1;                        //load bit_counter initial value
        data_write_in_en = 1'b0;
        operation        = stand_by;                    //don't execute write operation continue.
    end
//------------------------------------------------------//
    else
    if((start_flag == 1'b0) && (random_rd_id == 1'b1) && (id_page == 1'b0))  //no re-start, then execute data write operation
    begin
        random_rd_id = 1'b0;                            //clear random read identification.
        operation = write_in;
        if((wr_protect == 1'b1)||(WC == 1'b1))          //WC = 1: write inhibited
        begin
            wr_protect = 1'b1;
            if(wc_glitch == 1'b0)
              $display("%t, ERROR: /WC=1, the WRITE instruction is not executed!",$realtime);            
            if(wc_glitch == 1'b1)
              $display("%t, ERROR: a glitch on /WC=1 inside the transmission of the instruction is NOT specified in the M24xxx data sheet and this must not happen for a proper use of the M24xxx!",$realtime);
        end
        if((wr_protect == 1'b0)&&(WC != 1'b1))          //WC = 0: write enable, HiZ on /WC is decoded as "0"
        begin
            wr_protect = 1'b0;
            $display("%t, NOTE: Write Operation Begin!",$realtime);
        end
    end
    else
    if((start_flag == 1'b0) && (random_rd_id == 1'b1) && (id_page == 1'b1))  //no re-start, then execute data write operation
    begin
        random_rd_id = 1'b0;                            //clear random read identification.
        operation = write_id_in;
        if(id_page_lock == 1'b1)          //id_page_lock = 1: write inhibited
            $display("%t, ERROR: The ID memory is locked, the WRITE ID instruction is not executed!",$realtime);            
        else
            $display("%t, NOTE: Write ID Operation Begin!",$realtime);
    end
//////////////////////////////////////////////////////////////////
    if(ack_cycle)                               //memory ACK to master
    begin
        ack_cycle = 1'b0;
        //-----------------------------
        if(current_address_read_en)
        begin
            bit=8;
            current_address_read_en = 1'b0;
            operation = current_address_read;
            $display("%t, NOTE: Current Address Read Operation Begin!",$realtime);
            //#(`t_delay) sda_out_en = 1'b0;           //SDA as output mode
        end
        //-----------------------------
        if(random_address_read_en)
        begin
            bit=8;
            random_address_read_en = 1'b0;
            operation = random_address_read;
`ifdef MEM_32K_to_2M
            if(`Ei_Inputs == 3) memory_address={address_msb,address_lsb};
            if(`Ei_Inputs == 2) memory_address={dev_sel_1[1],address_msb[7:0],address_lsb};
            if(`Ei_Inputs == 1) memory_address={dev_sel_1[2:1],address_msb[7:0],address_lsb};
            if(`Ei_Inputs == 0) begin $display("\n ERROR: Ei_Inputs CANNOT BE SET AT 0!"); $stop; end
`elsif MEM_1K_to_16K
            if(`Ei_Inputs == 3) memory_address = address_byte;
            if(`Ei_Inputs == 2) memory_address = {dev_sel_1[1],address_byte};    //m4k
            if(`Ei_Inputs == 1) memory_address = {dev_sel_1[2:1],address_byte};  //m8k
            if(`Ei_Inputs == 0) memory_address = {dev_sel_1[3:1],address_byte};  //m16k
`else
            $display("\n ERROR: NO MEMORY SIZE DEFINE SPECIFIED!");
            $stop;
`endif
            $display("%t, NOTE: Random Address Read Operation Begin!",$realtime);
            //#(`t_delay) sda_out_en = 1'b0;           //SDA as output mode
        end
        //-----------------------------
        if(write_en)
        begin
            write_en        = 1'b0;
            bit_counter_en  = 1'b1;
            bit_counter_ld  = 1'b1;
            #(`t_delay) sda_out_en = 1'b1;             //SDA as input mode
        end
        //-----------------------------
`ifdef MEM_32K_to_2M
        if(address_h_ok)
        begin
            address_h_ok    = 1'b0;
            bit_counter_en  = 1'b1;
            bit_counter_ld  = 1'b1;
            #(`t_delay) sda_out_en = 1'b1;             //SDA as input mode
        end
        //-----------------------------
        if(address_l_ok)
        begin
            address_l_ok     = 1'b0;
            random_rd_id     = 1'b1;            //flag for random read instruction sequence decode
            data_write_in_en = 1'b1;
            if(`Ei_Inputs == 3) memory_address={address_msb,address_lsb};
            if(`Ei_Inputs == 2) memory_address={dev_sel_1[1],address_msb[7:0],address_lsb};  
            if(`Ei_Inputs == 1) memory_address={dev_sel_1[2:1],address_msb[7:0],address_lsb};
            if(`Ei_Inputs == 0) begin $display("\n ERROR: Ei_Inputs CANNOT BE SET AT 0!"); $stop; end
            start_address    = memory_address;
            bit_counter_en   = 1'b1;
            bit_counter_ld   = 1'b1;
            #(`t_delay)
            sda_out_en       = 1'b1;            //SDA as input mode
            dur_wr_ins       = 1'b0;            //end to detect the /WC signal 
        end
        //-----------------------------
`elsif MEM_1K_to_16K
        if(address_ok)
        begin
            address_ok       = 1'b0;
            random_rd_id     = 1'b1;            //flag for random read instruction sequence decode
            data_write_in_en = 1'b1;
            if(`Ei_Inputs == 3) memory_address = address_byte;
            if(`Ei_Inputs == 2) memory_address = {dev_sel_1[1],address_byte};
            if(`Ei_Inputs == 1) memory_address = {dev_sel_1[2:1],address_byte};
            if(`Ei_Inputs == 0) memory_address = {dev_sel_1[3:1],address_byte};
            start_address    = memory_address;
            bit_counter_en   = 1'b1;
            bit_counter_ld   = 1'b1;
            #(`t_delay)
            sda_out_en       = 1'b1;            //SDA as input mode
            dur_wr_ins       = 1'b0;            //end to detect the /WC signal 
        end
`endif
        //-----------------------------
        if(byte_data_in)
        begin
            byte_data_in    = 1'b0;
            wr_cycle_id     = 1'b1;             //set Internal Write Cycle trigger flag
            bit_counter_en  = 1'b1;
            bit_counter_ld  = 1'b1;
            #(`t_delay) sda_out_en = 1'b1;             //SDA as input mode

            if(memory_address[`Page_Addr_Bits-1:0] == {`Page_Addr_Bits {1'b1}})
            begin
                memory_address[`Page_Addr_Bits-1:0] = {`Page_Addr_Bits {1'b0}};
                end_address = memory_address;
            end
            else begin
                memory_address[`Page_Addr_Bits-1:0] = memory_address[`Page_Addr_Bits-1:0] + {{`Page_Addr_Bits-1 {1'b0}},1'b1};
                end_address = memory_address;
            end
        end
    end
//////////////////////////////////////////////////////////
    if((byte_ok) && (dev_sel_code1 == 1))       //if the first byte(Dev Sel Code) after START received.
    begin
        byte_ok = 1'b0;
        dev_sel_code1 = 1'b0;
        dev_sel_1 = shift_reg;
        dev_sel_1_cmp = {dev_sel_1[7:5],dev_sel_1[3:0]};
//        if((dev_sel_1[7:5] == 4'b101) && (dev_sel_1[3:(4-`Ei_Inputs)] == Ei))
`ifdef M16Kb
        if(dev_sel_1_cmp[6:4] == {4'b101})
`else
        if(dev_sel_1_cmp[6:(4-`Ei_Inputs)] == {4'b101,Ei})
`endif   
        begin
            if(dev_sel_1[4] == 1'b1)
              id_page = 1'b1;
            else
              id_page = 1'b0;

            dev_sel_1[0] = shift_reg[0];
            if(dev_sel_1[0] == 1'b1)
            begin
                current_address_read_en = 1'b1;
                ack_cycle = 1'b1;
                #(`t_delay);
                sda_out = 1'b0;                 //ack
                sda_out_en = 1'b0;              //SDA as output
            end
            else if(dev_sel_1[0] == 1'b0)
            begin
                write_en = 1'b1;
`ifdef MEM_32K_to_2M
                address_h = 1'b1;
`elsif MEM_1K_to_16K
                address = 1'b1;
`endif
                ack_cycle = 1'b1;
                #(`t_delay);
                sda_out = 1'b0;                 //ack
                sda_out_en = 1'b0;              //SDA as output
            end
        end
        else begin
            operation = no_operation;
            $display("%t, ERROR: Device Select Code is Incorrect!\n",$realtime);
            $display("%t, ERROR: The Correct Code should equal 1010%b;But the Received Code is %b\n",$realtime,Ei,dev_sel_1[7:1]);
            #(`t_delay);
            sda_out = 1'b1;                     //not ack
            sda_out_en = 1'b0;                  //SDA as output
        end
    end
    //-------------------------------------------
`ifdef MEM_32K_to_2M
    if((byte_ok == 1'b1) && (address_h == 1'b1))
    begin
        byte_ok = 1'b0;
        address_h = 1'b0;
        address_l = 1'b1;
        address_h_ok = 1'b1;
        address_msb = shift_reg[`Address_Bits-9:0];
        if (address_msb[2] && id_page) begin 
//          id_page_lock = 1'b1;
          $display("%t, NOTE: Checking if Lock Identification Page is Set.\n",$realtime);
        end
        ack_cycle = 1'b1;
        #(`t_delay);
        if (id_page_lock)
           sda_out = 1'b1;                         //noack
        else
           sda_out = 1'b0;                         //ack
        sda_out_en = 1'b0;                      //SDA as output
    end
    //-------------------------------------------
    if((byte_ok == 1'b1) && (address_l == 1'b1))
    begin
        byte_ok = 1'b0;
        address_l = 1'b0;
        address_l_ok = 1'b1;
        address_lsb = shift_reg;
        ack_cycle = 1'b1;
        #(`t_delay);
        if (id_page_lock)
           sda_out = 1'b1;                         //noack
        else
           sda_out = 1'b0;                         //ack
        sda_out_en = 1'b0;                      //SDA as output
    end
`elsif MEM_1K_to_16K
    if((byte_ok == 1'b1) && (address == 1'b1))
    begin
        byte_ok = 1'b0;
        address = 1'b0;
        address_ok = 1'b1;
        address_byte = shift_reg;
        ack_cycle = 1'b1;
        #(`t_delay);
        sda_out = 1'b0;                         //ack
        sda_out_en = 1'b0;                      //SDA as output
    end
`endif
    //-------------------------------------------
    if((byte_ok == 1'b1) && (dev_sel_again == 1'b1))
    begin
        byte_ok = 1'b0;
        dev_sel_again = 1'b0;
        dev_sel_2 = shift_reg;
        if((dev_sel_2[7:1] == dev_sel_1[7:1])&&(dev_sel_2[0] == 1'b1))
        begin                                   //the bit7~1 of twice Dev Sel Code must be identical
            random_address_read_en = 1'b1;
            ack_cycle = 1'b1;
            #(`t_delay);
            sda_out = 1'b0;                     //ack
            sda_out_en = 1'b0;                  //SDA as output
        end
        else
        begin
            operation = no_operation;
            $display("%t, ERROR: Twice Device Select Code is not identical!\n",$realtime);
            $display("%t, ERROR: Dev_Sel_1=%b,Dev_Sel_2=%b\n",$time,dev_sel_1[7:1],dev_sel_2[7:1]);
            #(`t_delay);
            sda_out = 1'b1;                     //not ack
            sda_out_en = 1'b0;                  //SDA as output
        end
    end
    //-------------------------------------------
    if((byte_ok == 1'b1) && (data_write_in_en == 1'b1))
    begin
        byte_ok = 1'b0;
        if(id_page == 1'b1) begin
`ifndef MEM_1K_to_16K
           if(id_page_lock == 1'b0)
           begin
               if (address_msb[2]) begin //A10
                  if(shift_reg[1]) begin //the lock bit, the rest is x
                     id_page_lock = 1'b1;
                     $display("%t, NOTE: ID PAGE is now LOCKED!",$realtime);
                     $display("%t, NOTE: ID Memory Page Write Lock Operation Complete!\n",$realtime); 
                  end
               end
               else 
                  internal_latch[memory_address[`Page_Addr_Bits-1:0]] = shift_reg;
               
               byte_data_in = 1'b1;
               ack_cycle = 1'b1;
               #(`t_delay);
               sda_out = 1'b0;
               sda_out_en = 1'b0;                   //ack
           end
           else                //write operation is disable
           begin
               byte_data_in = 1'b1;
               ack_cycle = 1'b1;
               #(`t_delay);
               sda_out = 1'b1;                      //no ack
               sda_out_en = 1'b0;
           end
`endif
        end
        else begin
           if(wr_protect == 1'b0) 
           begin
               internal_latch[memory_address[`Page_Addr_Bits-1:0]] = shift_reg;
               for(i=0;i<=(`Memory_Size/`Page_Size-1);i=i+1)
               begin
                   if(memory_address[`Address_Bits-1:`Page_Addr_Bits] == i)   page_number = i;
               end
               byte_data_in = 1'b1;
               ack_cycle = 1'b1;
               #(`t_delay);
               sda_out = 1'b0;
               sda_out_en = 1'b0;                   //ack
           end
           else if(wr_protect == 1'b1)              //write operation is disable
           begin
               byte_data_in = 1'b1;
               ack_cycle = 1'b1;
               #(`t_delay);
               sda_out = 1'b1;                      //no ack
               sda_out_en = 1'b0;
           end
        end
    end
//////////////////////////////////////////////////////////
    case(operation)
    //-----------------------
    current_address_read:
    begin
        curd_acked = 1'b0;

      if(id_page == 1'b1)
        if (no_wrap_flag)
           dat_out = 1'bx;
        else
           dat_out = memory_id[memory_address];
      else
        dat_out = memory[memory_address];

	    if(bit>0)
        begin
            #(`t_delay);
            sda_out_en = 1'b0;                   //SDA as output mode
            sda_out = dat_out[bit-1];
            bit=bit-1;
        end
        else if(bit==0)
        begin
            #(`t_delay);
            sda_out_en = 1'b1;                   //SDA as input mode
            curd_wait_ack = 1'b1;                //wait for ACK from master
        end
    end
    //-----------------------
    random_address_read:
    begin
        rnrd_acked = 1'b0;

      if(id_page == 1'b1)
        if (no_wrap_flag)
           dat_out = 1'bx;
        else
           dat_out = memory_id[memory_address];
      else
        dat_out = memory[memory_address];

	    if(bit>0)
        begin
            #(`t_delay);
            sda_out_en = 1'b0;                  //SDA as output mode
            sda_out = dat_out[bit-1];
            bit=bit-1;
        end
        else if(bit==0)
        begin
            #(`t_delay);
            sda_out_en = 1'b1;                  //SDA as input mode
            rnrd_wait_ack = 1'b1;               //wait for ACK from master
        end
    end
    //-----------------------
    endcase     
end

//*****************************************************************************
//*****************************************************************************
//*****                AC,DC timing Characteristics Check                 *****
//*****************************************************************************
//*****************************************************************************
time tSR_SET;           //start condition set up time
time tSR_HLD;           //start condition hold time
time tC_LO,tC_HI;       //clock low and high pulse width
time tST_SR;            //time between stop and next start
time tST_SET;           //stop condition set up time
time tDI_SET;           //data in set up time
time tDI_HLD;           //data in hold time
time tDO_VLD;           //data out hold time clock low to next data valid time
time tCH_SDA;           //save the time of SDA change happen
time tSTART,tSTOP;      //save the time of I2C start and stop condition happen
time tR_SCL,tF_SCL;     //save SCL rising and falling edge time
//-----------------------------------------------------------------------------
reg r_edge,f_edge,r_start,r_stop,sda_in_change,sda_out_change;
//-----------------------------------------------------------------------------
initial begin
        tSTART  = 0;
        tSTOP   = 0;
        tCH_SDA = 0;
        tR_SCL  = 0;
        tF_SCL  = 0;
end
///////////////////////////////////////////////////////////////////////////////
always@(posedge SCL)
begin
    if(operation != no_operation)
    begin
        r_edge = 1'b1;                 //clock rising edge flag
        tR_SCL = $time;                //save time of rising edge on SCL.
//==========================================
//"Clock Low Pulse Width" check. --tCLCH--
//==========================================
        if(f_edge == 1'b1)
        begin
            tC_LO = tR_SCL - tF_SCL;   //Clock Pulse Width Low
            if(tC_LO < `tCLCH) $display("%t, ERROR: Clock Pulse Width Low(tCLCH) violated.\n",$realtime);
        end
//==========================================
//"Data In Set Up Time" check. --tDXCX--
//==========================================
        if(sda_in_change == 1'b1)
        begin
            tDI_SET = tR_SCL - tCH_SDA;
            if(tDI_SET < `tDXCX) $display("%t, ERROR: Data In Set Up Time(tDXCX) violated.\n",$realtime);
        end
    end
end
///////////////////////////////////////////////////////////////////////////////
always@(negedge SCL)
begin
    if(operation != no_operation)
    begin
        f_edge = 1'b1;
        tF_SCL = $time;                //save time of falling edge on SCL.
//==========================================
//"Clock High Pulse Width" check. --tCHCL--
//==========================================
        if(r_edge == 1'b1)
        begin
            tC_HI = tF_SCL - tR_SCL;   //CLock Pluse Width High
            if(tC_HI < `tCHCL) $display("%t, ERROR: Clock Pulse Width High(tCHCL) violated.\n",$realtime);
        end
//===============================================
//"Start Condition Hold Time" check. --tDLCL--
//===============================================
        if(r_start == 1'b1)
        begin
            tSR_HLD = tF_SCL - tSTART;
            if(tSR_HLD < `tDLCL) $display("%t, ERROR: Start Condition Hold Time(tDLCL) violated.\n",$realtime);
        end
    end
end
///////////////////////////////////////////////////////////////////////////////
always@(SDA)
begin
    if(operation != no_operation)
    begin
        if(sda_out_en == 1'b1)  sda_in_change = 1;  //flag for input data change
        if(sda_out_en == 1'b0)  sda_out_change = 1; //flag for output data change
        tCH_SDA = $time;                            //save time of data change on SDA.
//==========================================
//"Data In Hold Time" check. --tCLDX--
//==========================================
        if((f_edge == 1'b1) && (sda_in_change == 1'b1))
        begin
            tDI_HLD = tCH_SDA - tF_SCL;
            if(tDI_HLD < `tCLDX) $display("%t, ERROR: Data In Hold Time(tCLDX) violated.\n",$realtime);
        end
//==================================================================================
//"Data Out Hold Time" and "CLK to next valid data Time" check. --tCLQX & tCLQV--
//==================================================================================
        if((f_edge == 1'b1) && (sda_out_change == 1))
        begin
            f_edge = 1'b0;
            sda_out_change = 1'b0;
            tDO_VLD = tCH_SDA - tF_SCL;
            if(tDO_VLD < `tCLQV_MIN) $display("%t, ERROR: Data Out Hold Time(tCLQX) violated.\n",$realtime);
            if(tDO_VLD > `tCLQV_MAX) $display("%t, ERROR: CLK Low to Next Data Valid Time(tCLQV) violated.tDO_VLD=%d,tCH_SDA=%d,tF_SCL=%d, tCLQV_MAX=%d\n",$realtime,tDO_VLD,tCH_SDA,tF_SCL,`tCLQV_MAX);
        end
    end
end
///////////////////////////////////////////////////////////////////////////////
always@(negedge SDA)
begin
    if((SCL == 1) && (SDA == 0))       //I2C start flag
    begin
        r_start = 1'b1;
        tSTART = $time;
//======================================================
//"Start Condition Set Up Time" check. --tCHDX--        
//======================================================
        if(r_edge == 1'b1)
        begin
            tSR_SET = tSTART - tR_SCL;
            if(tSR_SET < `tCHDX) $display("%t, ERROR: Start Condition Set Up Time(tCHDX) violated.\n",$realtime);
        end
//===========================================================================
// "Time Between Stop Condition and Next Start Condition" check. --tDHDL--
//===========================================================================
         if(r_stop == 1'b1)
         begin
            tST_SR = tSTART - tSTOP;
            if(tST_SR < `tDHDL) $display("%t, ERROR: Time between Stop and next Start(tDHDL) violated.\n",$realtime);
         end
    end
end
///////////////////////////////////////////////////////////////////////////////
always@(posedge SDA)
begin
    if((SCL == 1) && (SDA == 1))       //I2C stop flag
    begin
        r_stop = 1'b1;
        tSTOP = $time;
//======================================================
//"Stop Condition Set Up Time" check. --tCHDH--
//======================================================
        if(r_edge == 1'b1)
        begin
            tST_SET = tSTOP - tR_SCL;
            if(tST_SET < `tCHDH) $display("%t, ERROR: Stop Condition Set Up Time(tCHDH) violated.\n",$realtime);
        end
    end
end
///////////////////////////////////////////////////////////////////////////////

endmodule
