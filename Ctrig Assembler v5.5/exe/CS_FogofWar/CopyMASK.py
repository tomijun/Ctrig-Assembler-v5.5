# CS_FogofWar.exe v1.0 전용 MASK.chk 삽입용 플러그인

from eudplib import *
from os.path import getsize
filename = None
def onInit():
    for k, v in settings.items():
        if k.lower() == "mask":
            filename = v
    file_size = getsize(filename)
    file = open(filename, 'rb')

    byteBuffer = bytearray(file.read())

    chk = GetChkTokenized()
    DIM = chk.getsection('DIM')
    MapX = DIM[0]+DIM[1]*256 
    MapY = DIM[2]+DIM[3]*256

    if file_size != MapX*MapY:
        print("[CopyMASK] MASK.chk : Invaild File")
        return
        
    nMASK = bytearray()
    for i in range(0, file_size, MapX):
        nMASK += bytearray(byteBuffer[i:i+MapX])
        
    chk.setsection('MASK', nMASK)
    print(
            "[CopyMASK] MASK.chk : {} Loaded. ({} bytes)".format(
                file, file_size
        )
    )
    file.close()

onInit()