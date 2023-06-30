import serial.tools.list_ports

ser = None
deviceIDs = None


# 初始化
def Init():
    global ser, deviceIDs
    # 连接设备
    try:
        ser = serial.Serial("COM3", 9600, timeout=3)
        print(f"[连接设备]成功")
    except:
        print(f"[连接设备]失败")
        raise Exception("设备连接失败")

    # 读入下位机编号列表
    deviceIDs = list(map(int, input("[下位机编号列表]输入(空格分隔):").split()))
    assert(len(deviceIDs) != 0)
    print(f"[下位机编号列表]你指定的编号为:{deviceIDs}")


# 读取串口数据
def ReadData():
    data = ser.read(5)
    if data != b'':
        data = list(map(int, data))
        return data
    else:
        return []


# 校验下位机设备
def CheckDevice():
    count = [0, 0]
    for ID in deviceIDs:
        # 构造校验数据包
        data = [0x5A, ID, 0x08, 0x13]
        data.append(sum(data))
        print(f"[校验开始]下位机编号:{ID} 发送数据包:{data}")
        # 轮询校验
        flag = True
        for _ in range(100):
            # 发送校验数据包
            ser.write(data)
            # 读取返回数据包
            result = ReadData()
            if len(result) != 0:
                # 判断返回数据包是否正常
                if result == data:
                    print(f"[校验成功]编号为[{ID}]的下位机正常 返回数据包:{result}")
                    count[0] += 1
                else:
                    print(f"[校验失败]编号为[{ID}]的下位机异常 返回数据包:{result}")
                    count[1] += 1
                flag = False
                break
        if flag:
            print(f"[校验失败]编号为[{ID}]的下位机异常 无返回数据包")
            count[1] += 1
    count.append(sum(count))
    assert(count[2] == len(deviceIDs))
    print(f"[校验完成]下位机总数:{count[2]} 正常数:{count[0]} 异常数:{count[1]}")


# 读取下位机设置的分数
def ReadScore():
    score = []
    for ID in deviceIDs:
        # 构造读分数数据包
        data = [0x5A, 0x00, 0x03, ID]
        data.append(sum(data))
        print(f"[读取分数开始]下位机编号:{ID} 发送数据包:{data}")
        # 轮询
        flag = True
        for _ in range(100):
            # 发送读分数数据包
            ser.write(data)
            # 读取返回数据包
            result = ReadData()
            if len(result) != 0:
                # 判断返回数据包是否正常
                if result[3] == 0x6F:
                    print(f"[读取分数失败]下位机编号:{ID} 分数设置大于100 返回数据包:{result}")
                    score.append(0)
                elif result[1] == ID and result[4] == sum(result[:4]):
                    print(f"[读取分数成功]下位机编号:{ID} 分数:{result[3]} 返回数据包:{result}")
                    score.append(result[3])
                else:
                    print(f"[读取分数失败]下位机编号:{ID} 返回结果异常 返回数据包:{result}")
                    score.append(0)
                flag = False
                break
        if flag:
            print(f"[读取分数失败]编号为[{ID}]的下位机异常 无返回数据包")
            score.append(0)
    assert(len(score) == len(deviceIDs))
    print(f"[读取分数完成]分数列表:{score} 平均分数:{round(sum(score)/len(score),2)}")


# 复位下位机
def ResetDevice():
    # 构造复位数据包
    data = [0x5A, 0x00, 0x01, 0x00, 0x5B]
    ser.write(data)
    print(f"[复位]已广播复位指令 发送数据包:{data}")


if __name__ == "__main__":
    Init()
    CheckDevice()
    ReadScore()
    ResetDevice()
