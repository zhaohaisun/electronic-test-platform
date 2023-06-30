#include "com.h"
 
int openSerial(char *cSerialName)
{
    int iFd;
 
    struct termios opt;  //定义一个终端结构体
 
    iFd = open(cSerialName, O_RDWR | O_NOCTTY |O_NONBLOCK); //打开串口
	//iFd = open(cSerialName, O_RDWR | O_NOCTTY | O_NDELAY);//阻塞 |O_RSYNC
    if(iFd < 0) {
        perror(cSerialName);
        return -1;
    }
 
    tcgetattr(iFd, &opt); //取得终端介质（iFd）初始值，并把其值赋给opt; 相当于把iFd与终端结构体opt关联起来，从而用终端结构体中的变量和函数来设置iFd的终端属性    
 
    cfsetispeed(&opt, B1200); //设置串口输入数据的波特率
    cfsetospeed(&opt, B1200); //设置串口输出数据的波特率
 
    
    /*
     * raw mode
     */
    opt.c_lflag   &=   ~(ECHO   |   ICANON   |   IEXTEN   |   ISIG);
    opt.c_iflag   &=   ~(BRKINT   |   ICRNL   |   INPCK   |   ISTRIP   |   IXON);
    opt.c_oflag   &=   ~(OPOST);
    opt.c_cflag   &=   ~(CSIZE   |   PARENB);
    opt.c_cflag   |=   CS8;
 
    /*
     * 'DATA_LEN' bytes can be read by serial
     */
    opt.c_cc[VMIN]   =   DATA_LEN;                                      
    opt.c_cc[VTIME]  =   150;
 
    if (tcsetattr(iFd,   TCSANOW,   &opt)<0) {
        return   -1;
    }
	//设置与终端相关的参数 (除非需要底层支持却无法满足)，使用termios_p 引用的termios 结构。optional_actions（tcsetattr函数的第二个参数）指定了什么时候改变会起作用： 
	//TCSANOW：改变立即发生  
	//TCSADRAIN：改变在所有写入fd 的输出都被传输后生效。这个函数应当用于修改影响输出的参数时使用。(当前输出完成时将值改变)  
	//TCSAFLUSH：改变在所有写入fd 引用的对象的输出都被传输后生效，所有已接受但未读入的输入都在改变发生前丢弃(同TCSADRAIN，但会舍弃当前所有值)。
 
 
    return iFd;
}
 
 
int EpollInit(int cfd)
{
	//epoll是用来监听事件的
	epid = epoll_create(6);//放在初始化
	
	event.events = EPOLLET | EPOLLIN;
	event.data.fd = cfd;
	if (epoll_ctl(epid, EPOLL_CTL_ADD, cfd, &event) != 0) {//epoll的事件注册函数，epoll_ctl向 epoll对象中添加、修改或者删除感兴趣的事件，返回0表示成功，否则返回–1，此时需要根据errno错误码判断错误类型.
	//第一个参数是epoll_create()的返回值，第二个参数表示动作，用三个宏来表示：
	//EPOLL_CTL_ADD：注册新的fd到epfd中；
	//EPOLL_CTL_MOD：修改已经注册的fd的监听事件；
	//EPOLL_CTL_DEL：从epfd中删除一个fd；
	//第三个参数是需要监听的fd，第四个参数是告诉内核需要监听什么事(events),events可以是以下几个宏的集合：
	//EPOLLIN ：表示对应的文件描述符可以读（包括对端SOCKET正常关闭）；
	//EPOLLOUT：表示对应的文件描述符可以写；
	//EPOLLPRI：表示对应的文件描述符有紧急的数据可读（这里应该表示有带外数据到来）；
	//EPOLLERR：表示对应的文件描述符发生错误；
	//EPOLLHUP：表示对应的文件描述符被挂断；
	//EPOLLET： 将EPOLL设为边缘触发(Edge Triggered)模式，这是相对于水平触发(Level Triggered)来说的。
	//EPOLLONESHOT：只监听一次事件，当监听完这次事件之后，如果还需要继续监听这个socket的话，需要再次把这个socket加入到EPOLL队列里
		printf("set epoll error!\n");
		return 0;
	}
	printf("set epoll ok!\n");
	
	return 1;
}
 
int ComRead(char * ReadBuff,const int ReadLen)
{
	
	int read_len = 0;
	int len = 0;
 
	//下面开始epoll等待
	int i =0,witeNum= 0;
	while (1) 
	{
		witeNum = epoll_wait(epid, events, 1, 5000); //等待事件的产生。 epfd是 epoll的描述符,参数events用来从内核得到事件的集合，maxevents告之内核这个events有多大，这个 maxevents的值不能大于创建epoll_create()时的size，参数timeout是超时时间（毫秒，0会立即返回，-1将不确定，也有说法说是永久阻塞）。该函数返回需要处理的事件数目，如返回0表示已超时。如果返回–1，则表示出现错误，需要检查 errno错误码判断错误类型。
		printf("witeNum0 = %d\n   ", witeNum);
		if( witeNum == 0)
				return 0;
		//printf("witeNum = %d\n", witeNum);
		
		for (i = 0; i < witeNum; i++) 
		{
 
			if ((events[i].events & EPOLLERR)
					|| (events[i].events & EPOLLHUP)
					|| (!(events[i].events & EPOLLIN))) 
			{
				printf("no data!\n");
				break;
			} 
			else if (events[i].events & EPOLLIN) 
			{//有数据进入  接受数据
				len = read(events[i].data.fd, ReadBuff, ReadLen); //read(int fd, void * buf, size_t count)会把参数fd所指的文件传送count 个字节到buf 指针所指的内存中。
				//tcdrain(fd); //等待直到所有写入 fd 引用的对象的输出都被传输
	           		//tcflush(fd,TCIOFLUSH); //丢弃要写入 引用的对象，但是尚未传输的数据，或者收到但是尚未读取的数据，取决于 queue_selector 的值
				//TCIFLUSH ：刷新收到的数据但是不读；TCOFLUSH ：刷新写入的数据但是不传送；TCIOFLUSH ：同时刷新收到的数据但是不读，并且刷新写入的数据但是不传送
 
				//if(len != ReadLen) //如何保证每次都读到这些字节又不阻塞！ 
				//{
					//bzero(ReadBuff,15); //将指定内存块的前15个字节全部设置为零
				//}
				
				//if( len == ReadLen)
				 return len;
		 
			}
		}
	}
 
	return len ;
}
