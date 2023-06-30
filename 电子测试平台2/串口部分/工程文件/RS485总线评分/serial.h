#ifndef SERIAL_H
#define SERIAL_H

#include <cstring>
#include <vector>
#include <sys/termios.h>


class serial {
private:
    int board = -1, epfd = -1;
public:
    serial(const char *board_path, speed_t baud_rate);
    ~serial();
    std::vector<unsigned char> myRead(size_t n) const;
    void myWrite(const std::vector<unsigned char> &data) const;
};

#endif //SERIAL_H
