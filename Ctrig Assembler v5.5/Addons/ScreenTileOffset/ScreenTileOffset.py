#Screen Tile Offset v1.2 Made by Ninfia
from eudplib import *
import math

Scrdx = 0x58F450
Scrdy = 0x58F454
Scrflag = 0x58F458
Scrlock = 0x58F45C

for k, v in settings.items():
	if k.lower() == 'offset':
		Scroff = v.split(',')
		if len(Scroff) >= 1:
			Scrdx = int(Scroff[0],16)
		if len(Scroff) >= 2:
			Scrdy = int(Scroff[1],16)
		if len(Scroff) >= 3:
			Scrflag = int(Scroff[2],16)
		if len(Scroff) >= 4:
			Scrlock = int(Scroff[3],16)
	if k.lower() == "dx":
		Scrdx = int(v,16)
	if k.lower() == "dy":
		Scrdy = int(v,16)
	if k.lower() == "flag":
		Scrflag = int(v,16)
	if k.lower() == "lock":
		Scrlock = int(v,16)

idx, val = EUDCreateVariables(2)
Scroll = Db(0x100)
SEPD = EPD(Scroll)
def onPluginStart():
	if EUDWhile()((idx.AtMost(12))):
		val << f_maskread_epd(EPD(0x513B68)+idx,0xFFFFFFFF)
		DoActions([SetDeaths(SEPD+idx,SetTo,val,0),idx.AddNumber(1)])
	EUDEndWhile()

def afterTriggerExec():
	ScrX, ScrY, dX, dY, TilePos, Plock, NX, NY, ScrSet, LockSet = EUDCreateVariables(10)

	DoActions([ScrSet.SetNumber(0),LockSet.SetNumber(0)])
	for i in range(8):
		RawTrigger(conditions=[Memory(0x512684,Exactly,i),MemoryX(Scrflag,Exactly,2**i,2**i)],actions=[ScrSet.SetNumber(1)])
		RawTrigger(conditions=[Memory(0x512684,Exactly,i),MemoryX(Scrlock,Exactly,2**i,2**i)],actions=[LockSet.SetNumber(1)])
	RawTrigger(conditions=[Memory(0x512684,AtLeast,128),Memory(0x512684,AtMost,131),MemoryX(Scrflag,Exactly,2**8,2**8)],actions=[ScrSet.SetNumber(1)])
	RawTrigger(conditions=[Memory(0x512684,AtLeast,128),Memory(0x512684,AtMost,131),MemoryX(Scrlock,Exactly,2**8,2**8)],actions=[LockSet.SetNumber(1)])

	if EUDIf()((ScrSet.Exactly(1))):
		ScrX << f_maskread_epd(EPD(0x62848C),0xFFFF)
		ScrY << f_maskread_epd(EPD(0x6284A8),0xFFFF)
		dX << f_maskread_epd(EPD(Scrdx),0xFFFFFFFF)
		dY << f_maskread_epd(EPD(Scrdy),0xFFFFFFFF)
		NX << ScrX//32 + dX
		NY << ScrY//32 + dY
		RawTrigger(conditions=[NX.AtLeast(0x80000000)],actions=[NX.SetNumber(0)])
		RawTrigger(conditions=[NY.AtLeast(0x80000000)],actions=[NY.SetNumber(0)])
		TilePos << NX + NY * 65536
		DoActions([SetMemory(0x57F1D0,SetTo,TilePos)])
	EUDEndIf()

	ScrlockAct = [Plock.SetNumber(1)]
	for i in range(12):
		ScrlockAct.append(SetMemory(0x513B68+4*i,SetTo,0))
	ScrlockAct.append(SetMemoryX(0x513B68+4*12,SetTo,0,0xFF))
	RawTrigger(conditions=[LockSet.Exactly(1)],actions=ScrlockAct)

	if EUDIf()((LockSet.Exactly(0),Plock.Exactly(1))):
		DoActions([idx.SetNumber(0),Plock.SetNumber(0)])
		if EUDWhile()((idx.AtMost(11))):
			val << f_maskread_epd(SEPD+idx,0xFFFFFFFF)
			DoActions([SetDeaths(EPD(0x513B68)+idx,SetTo,val,0),idx.AddNumber(1)])
		EUDEndWhile()
		DoActions([SetDeathsX(EPD(0x513B68)+idx,SetTo,val,0,0xFF)])
	EUDEndIf()