#include "serial.h"

#include <cerrno>
#include <cstdio>
#include <iostream>
#include <sys/epoll.h>
#include <sys/fcntl.h>
#include <sys/termios.h>
#include <sys/unistd.h>
#include <stdio.h>
#include <signal.h>

#define err_check(code) if ((code) < 0) {    \
    printf("Error: %s\n", strerror(errno));  \
    _exit(1);                                \
}



serial::serial(const char *board_path, speed_t baud_rate) {
    /**
     * O_RDWR 表示以读写模式 (myRead & myWrite) 打开文件
     * 参考：https://man7.org/linux/man-pages/man3/open.3p.html
     */
    err_check(board = open(board_path, O_RDWR | O_NOCTTY ))

    termios attrs {};
    tcgetattr(board, &attrs);


    
    // 设置波特率
    err_check(cfsetispeed(&attrs, baud_rate))
    err_check(cfsetospeed(&attrs, baud_rate))
    attrs.c_iflag &= ~( BRKINT | ICRNL | INPCK | ISTRIP | IXON | IXOFF );


    attrs.c_oflag &= ~( OPOST | ONLCR | OCRNL );
    attrs.c_lflag &= ~( ECHO | ICANON | IEXTEN | ISIG );
    attrs.c_cflag &= ~( CSIZE | PARENB );
    attrs.c_cflag |= CS8;
    attrs.c_cc[VMIN]  = 1;
    attrs.c_cc[VTIME] = 0;

    // 设置终端参数，所有改动立即生效
    err_check(tcsetattr(board, TCSANOW, &attrs))

    // 重新打开设备文件以应用新的终端参数
    close(board);
    err_check(board = open(board_path, O_RDWR | O_NOCTTY))

    
    // 创建一个新的 epoll 实例，并返回一个用于控制的文件描述符
    err_check(epfd = epoll_create(1))

    epoll_event event {
        .events = EPOLLIN | EPOLLET,  // 当对端变为可读时触发事件
        .data = {
            .fd = board
        }
    };

    
    // 将这个事件添加到 epoll 的监听列表中
    err_check(epoll_ctl(epfd, EPOLL_CTL_ADD, board, &event))
}

serial::~serial() {
    (~board) && close(board);
    (~epfd) && close(epfd);
}

std::vector<unsigned char> serial::myRead(size_t n) const {
    size_t count = 0;
    std::vector<unsigned char> buffer(n);

    while (count < n) 
    {
        epoll_event event {};
        // 等待串口对端发来数据
        epoll_wait(epfd, &event, 1, 5000);		// 指定超时值，避免无限期阻塞等待
        // 读取数据，然后根据读取到的数据数量决定是否需要继续读取
        count += ::read(board, &buffer[count], n); 
    }
    //tcflush(board,TCIOFLUSH);
    return buffer;
}

void serial::myWrite(const std::vector<unsigned char> &data) const {
    size_t count = 0;
    //tcflush(board,TCOFLUSH);
    while (count < data.size()) {
        // 向串口写入数据
        count += ::write(board, &data[count], data.size() - count);
    }
    
}


