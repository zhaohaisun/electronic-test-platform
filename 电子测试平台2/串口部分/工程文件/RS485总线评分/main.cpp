#include <cstdio>
#include <iostream>
#include <string>
#include <unistd.h>
#include <signal.h>
#include "serial.h"
#include <setjmp.h>
using namespace std;
typedef unsigned char uchar;


/* 基于RS485总线的评分系统-主机程序-双机评分 */
string format(const vector<uchar> &data);			//数据处理为字符串
int check(serial &pipe, int addr);				//设备检测
int get_score(serial &pipe, int addr);			//获取分数
void reset(serial &pipe);					//从机复位

int main() {
    serial pipe("/dev/ttyUSB0", B9600);
    int addr, check_ret, score;
    while(1){
        cout<<"输入说明：\n输入合法从机地址查询分数\n输入-2将从机复位\n输入-1退出程序\n如果程序无法正确运行，不能接收从机回应，请重启重试\n请输入指令：";
        cin>>addr;
        if(addr == -1) break;
        if(addr == -2) {
            reset(pipe);
            continue;
        }
        check_ret = check(pipe, addr);
        if(check_ret == 1){
            cout<<"设备检测正常"<<endl;
            sleep(1);
    	    if(!(score = get_score(pipe, addr)))
    	        cout<<"获取分数失败"<<endl;
    	    else 
    	        cout<<"分数："<<score<<endl;
        }
        else if(check_ret == 0){
            cout<<"地址错误，请输入地址重试"<<endl;
            continue;
        }
	else{
	    cout<<"数据传输错误,请重启从机"<<endl;
	}        

        //reset(pipe);
        cout<<"从机已复位，输入-1退出"<<endl;
    }
    return 0;
}
/***************************************************** 
将数据处理为字符串
******************************************************/
string format(const vector<uchar> &data) {
    std::string str(2 * data.size() + 1, '\x00');
    for (int i = 0; i < data.size(); i++) {
        sprintf(&str[i * 2], "%02X", data[i]);
    }
    return str;
}
/***************************************************** 
从机地址检测：
参数：serial串口，从机地址
主机发送进行数据检测：5a + 从机地址 + 检测功能码08 + 13 + 校验码 
返回值：1(地址正确)；0(地址错误)；-1(数据错误)
******************************************************/
int check(serial &pipe,int addr){
	int check_code = 117 + addr, ret;				//校验码为累加和
	vector<uchar> code = {0x5a, 0x08, 0x13};
	vector<uchar> rec;
	code.insert(code.begin()+1, (uchar)addr);			//插入从机地址
	code.push_back((uchar)check_code);				//插入校验码
	//cout << format(code) << endl;				
	
	/* 写入并接收回应数据包 */
	pipe.myWrite(code);
	sleep(1);
	rec = pipe.myRead(5);
	if(format(rec) == format(code))				//检验接收数据包是否与发送相同，相同则从机地址正确
	    ret = 1;
	else{
	    if(rec[3] == 0x6f) ret = 0;
	    else ret = -1;
	}
	return ret;
	    
}
/***************************************************** 
获取从机分数：
参数：serial串口，从机地址
主机发送进行分数获取：5a + 00 + 读取功能码03 + 从机地址 + 校验码 
返回值：分数(数据正确)；-1(从机未准备好)；-2(数据错误)
******************************************************/
int get_score(serial &pipe, int addr){
	int check_code = 93 + addr, ret;				//校验码为累加和
	vector<uchar> code = {0x5a, 0x00, 0x03};
	vector<uchar> rec;
	code.insert(code.begin()+3, (uchar)addr);			//插入从机地址
	code.push_back((uchar)check_code);				//插入校验码
	//cout << format(data) << endl;				
	
	/* 写入并接收回应数据包 */
	pipe.myWrite(code);
	sleep(1);
	rec = pipe.myRead(5);
	if(rec[3] == 0x6f) ret = -1;					//检验是否错误
	else {
	    ret = (int)rec[3];						//转为数字
	    if(ret < 0 || ret > 100) ret =-2;				//检测数字是否合法
	}
	return ret;
	    
}
/***************************************************** 
从机复位：
参数：serial串口，从机分数值
主机发送进行从机复位：5a + 广播地址00 + 复位功能码01 + 00 +校验字节
******************************************************/
void reset(serial &pipe){
	vector<uchar> code = {0x5a, 0x00, 0x01,0x00,0x5b};
	//cout <<"reset:"<< format(code) << endl;				
	/* 发送数据包 */
	for(int i=0;i<600;i++) {
	    pipe.myWrite(code);
	}
	return;	    
}

