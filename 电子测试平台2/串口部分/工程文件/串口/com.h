#ifndef _COM_H_
#define _COM_H_
 
#include <stdio.h>
#include <stdlib.h> 
#include <unistd.h>  
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h> 
#include <termios.h>
#include <errno.h>   
#include <limits.h> 
#include <asm/ioctls.h>
#include <time.h>
#include <pthread.h>
#include <sys/ioctl.h>
#include <sys/epoll.h> 
#include <string.h>
 
//#define MAXLEN 15
 
#define DATA_LEN                0xFF         
 
int fd;//文件描述符
int epid; //epoll标识符
struct epoll_event event;
struct epoll_event events[6];//事件集合
//char RecvBuff[MAXLEN];//接受到的数据
 
int ComRead(char * ReadBuff,const int ReadLen);//com口读数据
int EpollInit(int cfd);
 
int  openSerial(char *cSerialName);
 
 
#endif