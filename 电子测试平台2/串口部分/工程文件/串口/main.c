#include<stdio.h>
#include "com.h"
#include "com.c"
#include <sys/epoll.h> 

#define LONG_STRING_LEN 12 //每次读的字符串的长度 取决于AA 55 后面的数字 每个人不一样
#define CODE_LEN 6         //密码长度（AA 55 + 四位密码）
#define ID_LEN 15          //学号长度15
#define MAX_REPEAT_TIMES 3      //重复N次则判定为读到最后 防止误判  


//用来打印字符串 参数为字符串和长度
void string_print(unsigned char *s, int len)
{
    int i;
    for (i = 0; i < len; i++)
    {
        printf("%02X ", s[i]);
    }
    printf("\n");
}

//重写read函数 读取固定长度的字符串（ComRead和read只会返回实际读取的数目）
int read_n_bytes(int fd,char* buf,int n)
{
    /*read_len用来记录每次读到的长度，len用来记录当前已经读取的长度*/
    int read_len = 0,len = 0;

    /*read_buf用来存储读到的数据*/
    char* read_buf = buf;
    while(len < n)
    {
        if((read_len = read(fd,read_buf,n)) > 0)  
        {
            len += read_len;         
            read_buf += read_len;
            read_len = 0;
        }

        //休眠时间视情况而定，可以参考波特率来确定数量级
        usleep(20);
    }
    return n;
}

int main(void)
{
    unsigned char ID[15] = {0xAA, 0x55, 0x02, 0x00, 0x02, 0x00, 0x00, 0x08, 0x00, 0x01, 0x00, 0x03, 0x01, 0x09, 0}; //学号
    unsigned char long_string[64] = {0};         //截取含有密码的字符串
    unsigned char last_code[7] = {0};            //保留最近的一次密码 用来对比是否已经读到了最后一个密码
    unsigned char code[7] = {0};                 //每次的密码 开头为AA 55 ;接着四位为密码
    code[0] = 0xAA;
    code[1] = 0x55;
    last_code[0] = 0xAA;
    last_code[1] = 0x55;
    int read_len = 0;     //读到字符的数量
    int code_num = 0;     //记录读到的密码的数量
    int flag = 0;         //标志位：读到最后一个密码
    int index=0;            //遍历用 
    int repeat_times=0;     //密码重复次数

    fd = openSerial("/dev/ttyUSB0"); //打开串口，ttyUSB0是串口文件
    if (fd < 0)
    {
        printf("open com fail!\n");
        return 0;
    }

    EpollInit(fd); //初始化终端事件触发函数epoll,设置要监听的事件及相关参数等

    write(fd, ID, ID_LEN); //第一次先写入学号
    //串口，学号字符串，长度

    usleep(200000); //等待写入完成 200ms

    printf("write ID successful\n\n");  //首次写入学号成功

    while (long_string[0]!=0xAA || long_string[1]!=0x55)    //读到第一个AA 55 用来对齐
    {
        read_len = read_n_bytes(fd,long_string,LONG_STRING_LEN); //读取
        tcflush(fd, TCIFLUSH);    //清空输入缓存
    }
    
    string_print(long_string,LONG_STRING_LEN);   

    int k=1;
    while(1){
        read_len = read_n_bytes(fd,long_string,LONG_STRING_LEN);   //读取以AA 55开始的字符串
        code[2] = long_string[8];
        code[3] = long_string[9];
        code[4] = long_string[10];            
        code[5] = long_string[11];
        
        write(fd,code,CODE_LEN);        //密码写回

        //判断时候为最后一个密码
        flag=0;
        for (index = 2; index <= 5; index++)        //对比前后两次密码
        {
            if (code[index] != last_code[index])
            {
                flag = 1;
                break;
            }
        }

        if (flag)   //前后密码不相等 有效密码
        {
            repeat_times=0;
            code_num++;	
        }else {          //读到最后一个密码
			break;
		}

        // else :记录新的密码
        for (index = 2; index <= 5; index++)
            last_code[index] = code[index];   

        printf("小华得到的当前密码： ");
        string_print(code, CODE_LEN);
        printf("已经读到的密码数： %d\n\n", code_num);
    }


    printf("读取到第 %d 个密码,最后的密码是：  ",code_num);
    string_print(&last_code[2], CODE_LEN-2); //输出最后4位密码
    printf("\n\n");

    close(epid);
    close(fd);

    return 0;
}
