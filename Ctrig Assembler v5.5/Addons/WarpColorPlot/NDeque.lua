function NDeque(PlayerID,Number,Size)
	-- ptr : EPD + Rear(0x30) / ptr2 : Next + EPD Mask + Front(0x30) 
	if TEP30Flag == 1 then
		__STRxSwitchX = __STRxSwitch
	else
		__STRxSwitchX = -1
	end

	if Number < 1 or Number > 32 then
		NDeque_InputData_Error()
	end

	local NVArr = CreateSVArr(Number,Size+1,PlayerID)

	local PID = "X"
	if type(PlayerID) == "number" then
		PID = PlayerID
	end
	CreateVarXAlloc = CreateVarXAlloc + 4
	if CreateVarXAlloc > CreateMaxVAlloc then
		CreateVariable_IndexAllocation_Overflow()
	end
	table.insert(CreateVarPArr,{["STRx"]=__STRxSwitchX,"NP1",PlayerID,Number,NVArr[2]})
	table.insert(CreateVarPArr,{["STRx"]=__STRxSwitchX,"NP2",PlayerID,Number,NVArr[2]})
	table.insert(CreateVarPArr,{["STRx"]=__STRxSwitchX,"NP1",PlayerID,Number,NVArr[2]})
	table.insert(CreateVarPArr,{["STRx"]=__STRxSwitchX,"NP2",PlayerID,Number,NVArr[2]})

	local Nptr1 = {PID,CreateVarXAlloc-3,0,"V"} -- rear 
	local Nptr2 = {PID,CreateVarXAlloc-2,0,"V"} -- front
	local Nptr3 = {PID,CreateVarXAlloc-1,0,"V"} -- Rrear
	local Nptr4 = {PID,CreateVarXAlloc,0,"V"}  -- Rfront

	-- rear : filled -> rear+1 : (void->fill)
	-- front : void -> front+1 : (filled->void)
	-- rear = Rfront, front = Rrear
	-- Rrear : (void->fill) -> Rrear-1 : void
	-- Rfront : (filled->void) -> Rfront-1 : filled

	return {NVArr, Nptr1, Nptr2, "Deque", Nptr3, Nptr4}
end

function NPush_back(PlayerID,Deque,Source,Mask)
	STPopTrigArr(PlayerID)
	local Number = Deque[1][5]
	local Size = Deque[1][6]
	if Number == 1 then -- V/SVA1
		if Mask == nil then
			Mask = 0xFFFFFFFF
		end
		if type(Source) == "table" and Source[4] == "VA" then
			local TempRet = {"X",CRet[7],0,"V"}
			MovX(PlayerID,TempRet,Source)
			Source = TempRet
		elseif type(Source) == "table" and Source[4] == "SVA" then
			local TempRet = {"X",SRet[Source[5][5]][3],0,"SV",Source[5][5],Source[5][7]}
			MovS(PlayerID,TempRet,Source)
			Source = TempRet
		end

		if type(Source) == "number" then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,1); -- rear
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,604);

					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,1); -- Rfront
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,604);

					SetCtrigX(Deque[2][1],Deque[2][2],0x158,Deque[2][3],SetTo,"X","X",0x158,1,2);
					SetCtrigX("X","X",0x4,1,SetTo,Deque[2][1],Deque[2][2],0x0,0,Deque[2][3]);
					SetCtrigX(Deque[2][1],Deque[2][2],0x4,Deque[2][3],SetTo,"X","X",0x0,0,2);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[2][1],Deque[2][2],0x30,Deque[2][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,-604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,-604*Size);

					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,-604*Size);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetMemoryX(0,SetTo,Source,Mask);
				},
				flag = {Preserved}
			}
		elseif Source[4] == "V" or (Source[4] == "SV" and Source[5] == 1) then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,1); -- rear
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,604);

					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,1); -- Rfront
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,604);

					SetCtrigX(Deque[2][1],Deque[2][2],0x158,Deque[2][3],SetTo,Source[1],Source[2],0x158,1,Source[3]);
					SetCtrig1X(Source[1],Source[2],0x148,Source[3],SetTo,Mask);
					SetCtrig1X(Source[1],Source[2],0x160,Source[3],SetTo,SetTo*16777216,0xFF000000);

					SetCtrigX("X","X",0x4,1,SetTo,Deque[2][1],Deque[2][2],0x0,0,Deque[2][3]);
					SetCtrigX(Deque[2][1],Deque[2][2],0x4,Deque[2][3],SetTo,Source[1],Source[2],0x0,0,Source[3]);
					SetCtrigX(Source[1],Source[2],0x4,Source[3],SetTo,"X","X",0x0,0,2);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[2][1],Deque[2][2],0x30,Deque[2][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,-604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,-604*Size);

					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,-604*Size);
				},
				flag = {Preserved}
			}
		else
			NPush_back_InputData_Error()
		end
	elseif Number == 2 then -- W/SVA2
		if Mask == nil then
			Mask = {0xFFFFFFFF,0xFFFFFFFF}
		elseif type(Mask) == "number" then
			Mask = {Mask,Mask}
		end
		if type(Source) == "table" and Source[4] == "WA" then
			local TempRet = {"X",WRet[7],0,"W"}
			MovW(PlayerID,TempRet,Source)
			Source = TempRet
		elseif type(Source) == "table" and Source[4] == "SVA" then
			local TempRet = {"X",SRet[Source[5][5]][3],0,"SV",Source[5][5],Source[5][7]}
			MovS(PlayerID,TempRet,Source)
			Source = TempRet
		end

		if type(Source) == "number" or type(Source) == "string" or (type(Source) == "table" and type(Source[1]) == "number" and type(Source[2]) == "number" and #Source == 2) then
			if type(Source) == "number" then
				Source = {Source,0}
			elseif type(Source) == "string" then
				Source = I64(Source)
			end

			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,1); -- rear
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x19C,Deque[2][3],Add,604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x1B8,Deque[2][3],Add,604);

					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,1); -- Rfront
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x1B8,Deque[6][3],Add,604);

					SetCtrigX(Deque[2][1],Deque[2][2],0x158,Deque[2][3],SetTo,"X","X",0x158,1,2);
					SetCtrigX(Deque[2][1],Deque[2][2],0x198,Deque[2][3],SetTo,"X","X",0x178,1,2);
					SetCtrigX("X","X",0x4,1,SetTo,Deque[2][1],Deque[2][2],0x0,0,Deque[2][3]);
					SetCtrigX(Deque[2][1],Deque[2][2],0x4,Deque[2][3],SetTo,"X","X",0x0,0,2);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[2][1],Deque[2][2],0x30,Deque[2][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,-604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,-604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x19C,Deque[2][3],Add,-604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x1B8,Deque[2][3],Add,-604*Size);

					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,-604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x1B8,Deque[6][3],Add,-604*Size);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetMemoryX(0,SetTo,Source[1],Mask[1]);
					SetMemoryX(0,SetTo,Source[2],Mask[2]);
				},
				flag = {Preserved}
			}
		elseif Source[4] == "W" or (Source[4] == "SV" and Source[5] == 2) then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,1); -- rear
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x19C,Deque[2][3],Add,604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x1B8,Deque[2][3],Add,604);

					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,1); -- Rfront
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x1B8,Deque[6][3],Add,604);

					SetCtrigX(Deque[2][1],Deque[2][2],0x158,Deque[2][3],SetTo,Source[1],Source[2],0x158,1,Source[3]);
					SetCtrigX(Deque[2][1],Deque[2][2],0x198,Deque[2][3],SetTo,Source[1],Source[2],0x198,1,Source[3]);
					SetCtrig1X(Source[1],Source[2],0x148,Source[3],SetTo,Mask[1]);
					SetCtrig1X(Source[1],Source[2],0x188,Source[3],SetTo,Mask[2]);
					SetCtrig1X(Source[1],Source[2],0x160,Source[3],SetTo,SetTo*16777216,0xFF000000);
					SetCtrig1X(Source[1],Source[2],0x1A0,Source[3],SetTo,SetTo*16777216,0xFF000000);
					
					SetCtrigX("X","X",0x4,1,SetTo,Deque[2][1],Deque[2][2],0x0,0,Deque[2][3]);
					SetCtrigX(Deque[2][1],Deque[2][2],0x4,Deque[2][3],SetTo,Source[1],Source[2],0x0,0,Source[3]);
					SetCtrigX(Source[1],Source[2],0x4,Source[3],SetTo,"X","X",0x0,0,2);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[2][1],Deque[2][2],0x30,Deque[2][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,-604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,-604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x19C,Deque[2][3],Add,-604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x1B8,Deque[2][3],Add,-604*Size);

					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,-604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x1B8,Deque[6][3],Add,-604*Size);
				},
				flag = {Preserved}
			}
		else
			NPush_back_InputData_Error()
		end
	else -- SVA3~32
		if Mask == nil then
			Mask = {}
			for i = 1, Number do
				table.insert(Mask,0xFFFFFFFF)
			end
		elseif type(Mask) == "number" then
			Mask = {Mask}
			for i = 2, Number do
				table.insert(Mask,Mask[1])
			end
		else
			for i = 1, Number do
				if Mask[i] == nil then
					Mask[i] = 0xFFFFFFFF
				end
			end
		end

		if type(Source) == "table" and Source[4] == "SVA" then
			local TempRet = {"X",SRet[Source[5][5]][3],0,"SV",Source[5][5],Source[5][7]}
			MovS(PlayerID,TempRet,Source)
			Source = TempRet
		end

		if type(Source) == "number" or (type(Source) == "table" and type(Source[4]) == "number" and #Source == Number) then
			if type(Source) == "number" then
				Source = {Source}
				for i = 2, Number do
					table.insert(Source,Source[1])
				end
			end

			local Box0 = {}
			local Box1 = {}
			local Box2 = {}
			local Box3 = {}
			local Box4 = {}
			local Box5 = {}
			for i = 1, Number do
				table.insert(Box0,SetCtrig1X(Deque[2][1],Deque[2][2],0x15C+0x40*(i-1),Deque[2][3],Add,-604*Size))
				table.insert(Box0,SetCtrig1X(Deque[2][1],Deque[2][2],0x178+0x40*(i-1),Deque[2][3],Add,-604*Size))
				table.insert(Box1,SetCtrigX(Deque[2][1],Deque[2][2],0x158+0x40*(i-1),Deque[2][3],SetTo,"X","X",0x158+0x20*(i-1),1,3))
				table.insert(Box2,SetMemoryX(0,SetTo,Source[i],Mask[i]))
				table.insert(Box3,SetCtrig1X(Deque[2][1],Deque[2][2],0x15C+0x40*(i-1),Deque[2][3],Add,604))
				table.insert(Box3,SetCtrig1X(Deque[2][1],Deque[2][2],0x178+0x40*(i-1),Deque[2][3],Add,604))
				table.insert(Box4,SetCtrig1X(Deque[6][1],Deque[6][2],0x198+0x20*(i-1),Deque[6][3],Add,604))
				table.insert(Box5,SetCtrig1X(Deque[6][1],Deque[6][2],0x198+0x20*(i-1),Deque[6][3],Add,-604*Size))
			end
			
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					Box4;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					Box3;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,1); -- rear
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,1); -- Rfront
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604);
					Box1;
					SetCtrigX("X","X",0x4,2,SetTo,Deque[2][1],Deque[2][2],0x0,0,Deque[2][3]);
					SetCtrigX(Deque[2][1],Deque[2][2],0x4,Deque[2][3],SetTo,"X","X",0x0,0,3);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[2][1],Deque[2][2],0x30,Deque[2][3],AtLeast,Size);
				},
				actions = {
					Box0;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[2][1],Deque[2][2],0x30,Deque[2][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604*Size);
					Box5;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					Box2;
				},
				flag = {Preserved}
			}
		elseif Source[4] == "SV" and Source[5] == Number then
			local Box0 = {}
			local Box1 = {}
			local Box2 = {}
			local Box3 = {}
			local Box4 = {}
			for i = 1, Number do
				table.insert(Box0,SetCtrig1X(Deque[2][1],Deque[2][2],0x15C+0x40*(i-1),Deque[2][3],Add,-604*Size))
				table.insert(Box0,SetCtrig1X(Deque[2][1],Deque[2][2],0x178+0x40*(i-1),Deque[2][3],Add,-604*Size))
				table.insert(Box2,SetCtrigX(Deque[2][1],Deque[2][2],0x158+0x40*(i-1),Deque[2][3],SetTo,Source[1],Source[2],0x158+0x40*(i-1),1,Source[3]))
				table.insert(Box3,SetCtrig1X(Deque[2][1],Deque[2][2],0x15C+0x40*(i-1),Deque[2][3],Add,604))
				table.insert(Box3,SetCtrig1X(Deque[2][1],Deque[2][2],0x178+0x40*(i-1),Deque[2][3],Add,604))
				table.insert(Box3,SetCtrig1X(Source[1],Source[2],0x148+0x40*(i-1),Source[3],SetTo,Mask[i]))
				table.insert(Box3,SetCtrig1X(Source[1],Source[2],0x160+0x40*(i-1),Source[3],SetTo,SetTo*16777216,0xFF000000))
				table.insert(Box3,SetCtrig1X(Deque[6][1],Deque[6][2],0x198+0x20*(i-1),Deque[6][3],Add,604))
				table.insert(Box4,SetCtrig1X(Deque[6][1],Deque[6][2],0x198+0x20*(i-1),Deque[6][3],Add,-604*Size))
			end

			DoActions2X(PlayerID,Box3)
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,1); -- rear
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,1); -- Rfront
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604);
					Box2;
					SetCtrigX("X","X",0x4,2,SetTo,Deque[2][1],Deque[2][2],0x0,0,Deque[2][3]);
					SetCtrigX(Deque[2][1],Deque[2][2],0x4,Deque[2][3],SetTo,Source[1],Source[2],0x0,0,Source[3]);
					SetCtrigX(Source[1],Source[2],0x4,Source[3],SetTo,"X","X",0x0,0,3);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[2][1],Deque[2][2],0x30,Deque[2][3],AtLeast,Size);
				},
				actions = {
					Box0;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[2][1],Deque[2][2],0x30,Deque[2][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604*Size);
					Box4;
				},
				flag = {Preserved}
			}
		else
			NPush_back_InputData_Error()
		end
	end
end

function NPush_front(PlayerID,Deque,Source,Mask)
	STPopTrigArr(PlayerID)
	local Number = Deque[1][5]
	local Size = Deque[1][6]
	if Number == 1 then -- V/SVA1
		if Mask == nil then
			Mask = 0xFFFFFFFF
		end
		if type(Source) == "table" and Source[4] == "VA" then
			local TempRet = {"X",CRet[7],0,"V"}
			MovX(PlayerID,TempRet,Source)
			Source = TempRet
		elseif type(Source) == "table" and Source[4] == "SVA" then
			local TempRet = {"X",SRet[Source[5][5]][3],0,"SV",Source[5][5],Source[5][7]}
			MovS(PlayerID,TempRet,Source)
			Source = TempRet
		end

		if type(Source) == "number" then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX(Deque[5][1],Deque[5][2],0x158,Deque[5][3],SetTo,"X","X",0x158,1,1);
					SetCtrigX("X","X",0x4,0,SetTo,Deque[5][1],Deque[5][2],0x0,0,Deque[5][3]);
					SetCtrigX(Deque[5][1],Deque[5][2],0x4,Deque[5][3],SetTo,"X","X",0x0,0,1);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetMemoryX(0,SetTo,Source,Mask);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,-604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,-604);

					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,-604);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[5][1],Deque[5][2],0x30,Deque[5][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604*Size);

					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604*Size);
				},
				flag = {Preserved}
			}
		elseif Source[4] == "V" or (Source[4] == "SV" and Source[5] == 1) then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX(Deque[5][1],Deque[5][2],0x158,Deque[5][3],SetTo,Source[1],Source[2],0x158,1,Source[3]);
					SetCtrig1X(Source[1],Source[2],0x148,Source[3],SetTo,Mask);
					SetCtrig1X(Source[1],Source[2],0x160,Source[3],SetTo,SetTo*16777216,0xFF000000);

					SetCtrigX("X","X",0x4,0,SetTo,Deque[5][1],Deque[5][2],0x0,0,Deque[5][3]);
					SetCtrigX(Deque[5][1],Deque[5][2],0x4,Deque[5][3],SetTo,Source[1],Source[2],0x0,0,Source[3]);
					SetCtrigX(Source[1],Source[2],0x4,Source[3],SetTo,"X","X",0x0,0,1);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,-604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,-604);

					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,-604);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[5][1],Deque[5][2],0x30,Deque[5][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604*Size);

					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604*Size);
				},
				flag = {Preserved}
			}
		else
			NPush_front_InputData_Error()
		end
	elseif Number == 2 then -- W/SVA2
		if Mask == nil then
			Mask = {0xFFFFFFFF,0xFFFFFFFF}
		elseif type(Mask) == "number" then
			Mask = {Mask,Mask}
		end
		if type(Source) == "table" and Source[4] == "WA" then
			local TempRet = {"X",WRet[7],0,"W"}
			MovW(PlayerID,TempRet,Source)
			Source = TempRet
		elseif type(Source) == "table" and Source[4] == "SVA" then
			local TempRet = {"X",SRet[Source[5][5]][3],0,"SV",Source[5][5],Source[5][7]}
			MovS(PlayerID,TempRet,Source)
			Source = TempRet
		end

		if type(Source) == "number" or type(Source) == "string" or (type(Source) == "table" and type(Source[1]) == "number" and type(Source[2]) == "number" and #Source == 2) then
			if type(Source) == "number" then
				Source = {Source,0}
			elseif type(Source) == "string" then
				Source = I64(Source)
			end

			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX(Deque[5][1],Deque[5][2],0x158,Deque[5][3],SetTo,"X","X",0x158,1,1);
					SetCtrigX(Deque[5][1],Deque[5][2],0x198,Deque[5][3],SetTo,"X","X",0x178,1,1);
					SetCtrigX("X","X",0x4,0,SetTo,Deque[5][1],Deque[5][2],0x0,0,Deque[5][3]);
					SetCtrigX(Deque[5][1],Deque[5][2],0x4,Deque[5][3],SetTo,"X","X",0x0,0,1);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetMemoryX(0,SetTo,Source[1],Mask[1]);
					SetMemoryX(0,SetTo,Source[2],Mask[2]);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,-604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,-604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x19C,Deque[5][3],Add,-604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x1B8,Deque[5][3],Add,-604);

					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,-604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1B8,Deque[3][3],Add,-604);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[5][1],Deque[5][2],0x30,Deque[5][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x19C,Deque[5][3],Add,604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x1B8,Deque[5][3],Add,604*Size);

					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1B8,Deque[3][3],Add,604*Size);
				},
				flag = {Preserved}
			}
		elseif Source[4] == "W" or (Source[4] == "SV" and Source[5] == 2) then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX(Deque[5][1],Deque[5][2],0x158,Deque[5][3],SetTo,Source[1],Source[2],0x158,1,Source[3]);
					SetCtrigX(Deque[5][1],Deque[5][2],0x198,Deque[5][3],SetTo,Source[1],Source[2],0x198,1,Source[3]);
					SetCtrig1X(Source[1],Source[2],0x148,Source[3],SetTo,Mask[1]);
					SetCtrig1X(Source[1],Source[2],0x188,Source[3],SetTo,Mask[2]);
					SetCtrig1X(Source[1],Source[2],0x160,Source[3],SetTo,SetTo*16777216,0xFF000000);
					SetCtrig1X(Source[1],Source[2],0x1A0,Source[3],SetTo,SetTo*16777216,0xFF000000);
					
					SetCtrigX("X","X",0x4,0,SetTo,Deque[5][1],Deque[5][2],0x0,0,Deque[5][3]);
					SetCtrigX(Deque[5][1],Deque[5][2],0x4,Deque[5][3],SetTo,Source[1],Source[2],0x0,0,Source[3]);
					SetCtrigX(Source[1],Source[2],0x4,Source[3],SetTo,"X","X",0x0,0,1);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,-604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,-604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x19C,Deque[5][3],Add,-604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x1B8,Deque[5][3],Add,-604);

					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,-604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1B8,Deque[3][3],Add,-604);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[5][1],Deque[5][2],0x30,Deque[5][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x19C,Deque[5][3],Add,604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x1B8,Deque[5][3],Add,604*Size);

					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1B8,Deque[3][3],Add,604*Size);
				},
				flag = {Preserved}
			}
		else
			NPush_front_InputData_Error()
		end
	else -- SVA3~32
		if Mask == nil then
			Mask = {}
			for i = 1, Number do
				table.insert(Mask,0xFFFFFFFF)
			end
		elseif type(Mask) == "number" then
			Mask = {Mask}
			for i = 2, Number do
				table.insert(Mask,Mask[1])
			end
		else
			for i = 1, Number do
				if Mask[i] == nil then
					Mask[i] = 0xFFFFFFFF
				end
			end
		end

		if type(Source) == "table" and Source[4] == "SVA" then
			local TempRet = {"X",SRet[Source[5][5]][3],0,"SV",Source[5][5],Source[5][7]}
			MovS(PlayerID,TempRet,Source)
			Source = TempRet
		end

		if type(Source) == "number" or (type(Source) == "table" and type(Source[4]) == "number" and #Source == Number) then
			if type(Source) == "number" then
				Source = {Source}
				for i = 2, Number do
					table.insert(Source,Source[1])
				end
			end

			local Box0 = {}
			local Box1 = {}
			local Box2 = {}
			local Box3 = {}
			local Box4 = {}
			local Box5 = {}
			for i = 1, Number do
				table.insert(Box0,SetCtrig1X(Deque[5][1],Deque[5][2],0x15C+0x40*(i-1),Deque[5][3],Add,604*Size))
				table.insert(Box0,SetCtrig1X(Deque[5][1],Deque[5][2],0x178+0x40*(i-1),Deque[5][3],Add,604*Size))
				table.insert(Box1,SetCtrigX(Deque[5][1],Deque[5][2],0x158+0x40*(i-1),Deque[5][3],SetTo,"X","X",0x158+0x20*(i-1),1,1))
				table.insert(Box2,SetMemoryX(0,SetTo,Source[i],Mask[i]))
				table.insert(Box3,SetCtrig1X(Deque[5][1],Deque[5][2],0x15C+0x40*(i-1),Deque[5][3],Add,-604))
				table.insert(Box3,SetCtrig1X(Deque[5][1],Deque[5][2],0x178+0x40*(i-1),Deque[5][3],Add,-604))
				table.insert(Box4,SetCtrig1X(Deque[3][1],Deque[3][2],0x198+0x20*(i-1),Deque[3][3],Add,-604))
				table.insert(Box5,SetCtrig1X(Deque[3][1],Deque[3][2],0x198+0x20*(i-1),Deque[3][3],Add,604*Size))
			end
	
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					Box1;
					SetCtrigX("X","X",0x4,0,SetTo,Deque[5][1],Deque[5][2],0x0,0,Deque[5][3]);
					SetCtrigX(Deque[5][1],Deque[5][2],0x4,Deque[5][3],SetTo,"X","X",0x0,0,1);
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					Box2;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-1); -- Rrear
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604);
					Box4;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					Box3;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[5][1],Deque[5][2],0x30,Deque[5][3],AtLeast,0x80000000);
				},
				actions = {
					Box0;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[5][1],Deque[5][2],0x30,Deque[5][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604*Size);
					Box5;
				},
				flag = {Preserved}
			}
			
		elseif Source[4] == "SV" and Source[5] == Number then
			local Box0 = {}
			local Box1 = {}
			local Box2 = {}
			local Box3 = {}
			local Box4 = {}
			for i = 1, Number do
				table.insert(Box0,SetCtrig1X(Deque[5][1],Deque[5][2],0x15C+0x40*(i-1),Deque[5][3],Add,604*Size))
				table.insert(Box0,SetCtrig1X(Deque[5][1],Deque[5][2],0x178+0x40*(i-1),Deque[5][3],Add,604*Size))
				table.insert(Box2,SetCtrigX(Deque[5][1],Deque[5][2],0x158+0x40*(i-1),Deque[5][3],SetTo,Source[1],Source[2],0x158+0x40*(i-1),1,Source[3]))
				table.insert(Box3,SetCtrig1X(Deque[5][1],Deque[5][2],0x15C+0x40*(i-1),Deque[5][3],Add,-604))
				table.insert(Box3,SetCtrig1X(Deque[5][1],Deque[5][2],0x178+0x40*(i-1),Deque[5][3],Add,-604))
				table.insert(Box3,SetCtrig1X(Source[1],Source[2],0x148+0x40*(i-1),Source[3],SetTo,Mask[i]))
				table.insert(Box3,SetCtrig1X(Source[1],Source[2],0x160+0x40*(i-1),Source[3],SetTo,SetTo*16777216,0xFF000000))
				table.insert(Box3,SetCtrig1X(Deque[3][1],Deque[3][2],0x198+0x20*(i-1),Deque[3][3],Add,-604))
				table.insert(Box4,SetCtrig1X(Deque[3][1],Deque[3][2],0x198+0x20*(i-1),Deque[3][3],Add,604*Size))
			end

			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					Box2;
					SetCtrigX("X","X",0x4,0,SetTo,Deque[5][1],Deque[5][2],0x0,0,Deque[5][3]);
					SetCtrigX(Deque[5][1],Deque[5][2],0x4,Deque[5][3],SetTo,Source[1],Source[2],0x0,0,Source[3]);
					SetCtrigX(Source[1],Source[2],0x4,Source[3],SetTo,"X","X",0x0,0,1);
				},
				flag = {Preserved}
			}
			DoActions2X(PlayerID,{
				SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-1); -- Rrear
				SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-1); -- front
				SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970);
				SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604);
				Box3;
			})
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[5][1],Deque[5][2],0x30,Deque[5][3],AtLeast,0x80000000);
				},
				actions = {
					Box0;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[5][1],Deque[5][2],0x30,Deque[5][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604*Size);
					Box4;
				},
				flag = {Preserved}
			}
		else
			NPush_front_InputData_Error()
		end
	end
end

function NPop_front(PlayerID,Deque,Dest)
	STPopTrigArr(PlayerID)
	local Number = Deque[1][5]
	local Size = Deque[1][6]
	if Number == 1 then -- V/Mem/SVA1
		local PDest
		if type(Dest) == "table" and Dest[4] == "VA" then
			PDest = Dest
			Dest = {"X",CRet[8],0,"V"}
		elseif type(Dest) == "table" and Dest[4] == "A" then
			PDest = Dest
			Dest = {"X",CRet[8],0,"V"}
		elseif type(Dest) == "table" and Dest[4] == "SVA" then
			PDestS = Dest
			Dest = {"X",SRet[Dest[5][5]][4],0,"SV",Dest[5][5],Dest[5][7]}
		end

		if type(Dest) == "number" then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604);

					SetCtrigX("X","X",0x4,1,SetTo,Deque[3][1],Deque[3][2],0x0,0,Deque[3][3]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x17C,Deque[3][3],SetTo,"X","X",0x0,0,2);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x19C,Deque[3][3],SetTo,EPD(Dest));
				},
				flag = {Preserved}
			}
		elseif Dest[4] == "V" or (Dest[4] == "SV" and Dest[5] == 1) then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604);

					SetCtrigX("X","X",0x4,1,SetTo,Deque[3][1],Deque[3][2],0x0,0,Deque[3][3]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x17C,Deque[3][3],SetTo,"X","X",0x0,0,2);
					SetCtrigX(Deque[3][1],Deque[3][2],0x19C,Deque[3][3],SetTo,Dest[1],Dest[2],0x15C,1,Dest[3]);
				},
				flag = {Preserved}
			}
		else -- Mem
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604);

					SetCtrigX("X","X",0x4,1,SetTo,Deque[3][1],Deque[3][2],0x0,0,Deque[3][3]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x17C,Deque[3][3],SetTo,"X","X",0x0,0,2);
					SetCtrigX(Deque[3][1],Deque[3][2],0x19C,Deque[3][3],SetTo,Dest[1],Dest[2],Dest[3],1,Dest[4]);
				},
				flag = {Preserved}
			}
		end
		Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[3][1],Deque[3][2],0x30,Deque[3][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,-604*Size);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,-604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,-604*Size);
				},
				flag = {Preserved}
			}
		if PDest ~= nil then
			MovX(PlayerID,PDest,Dest)
		end
	elseif Number == 2 then -- W/LMem/SVA2
		local PDest
		if type(Dest) == "table" and Dest[4] == "WA" then
			PDest = Dest
			Dest = {"X",WRet[8],0,"W"}
		elseif type(Dest) == "table" and Dest[4] == "LA_V" then
			PDest = Dest
			Dest = {"X",WRet[8],0,"W"}
		elseif type(Dest) == "table" and Dest[4] == "LA_W" then
			PDest = Dest
			Dest = {"X",WRet[8],0,"W"}
		elseif type(Dest) == "table" and Dest[4] == "SVA" then
			PDestS = Dest
			Dest = {"X",SRet[Dest[5][5]][4],0,"SV",Dest[5][5],Dest[5][7]}
		end

		if type(Dest) == "number" or (type(Dest) == "table" and type(Dest[1]) == "number" and (type(Dest[2]) == "number" or (type(Dest[2]) == "table" and type(Dest[2][1]) == "number")) and #Dest == 2) then
			if type(Dest) == "number" then
				Dest = {Dest,Dest+4}
			elseif type(Dest) == "table" and type(Dest[2]) == "table" then
				Dest = {Dest[1],Dest[1]+Dest[2][1]}
			end

			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1B8,Deque[3][3],Add,604);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x19C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x1B8,Deque[5][3],Add,604);

					SetCtrigX("X","X",0x4,1,SetTo,Deque[3][1],Deque[3][2],0x0,0,Deque[3][3]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x17C,Deque[3][3],SetTo,"X","X",0x0,0,2);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x19C,Deque[3][3],SetTo,EPD(Dest[1]));
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1BC,Deque[3][3],SetTo,EPD(Dest[2]));
				},
				flag = {Preserved}
			}
		elseif Dest[4] == "W" or (Dest[4] == "SV" and Dest[5] == 2) then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1B8,Deque[3][3],Add,604);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x19C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x1B8,Deque[5][3],Add,604);

					SetCtrigX("X","X",0x4,1,SetTo,Deque[3][1],Deque[3][2],0x0,0,Deque[3][3]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x17C,Deque[3][3],SetTo,"X","X",0x0,0,2);
					SetCtrigX(Deque[3][1],Deque[3][2],0x19C,Deque[3][3],SetTo,Dest[1],Dest[2],0x15C,1,Dest[3]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x1BC,Deque[3][3],SetTo,Dest[1],Dest[2],0x19C,1,Dest[3]);
				},
				flag = {Preserved}
			}
		else -- LMem
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,604);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1B8,Deque[3][3],Add,604);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,1); -- Rrear
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x19C,Deque[5][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x1B8,Deque[5][3],Add,604);

					SetCtrigX("X","X",0x4,1,SetTo,Deque[3][1],Deque[3][2],0x0,0,Deque[3][3]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x17C,Deque[3][3],SetTo,"X","X",0x0,0,2);
					SetCtrigX(Deque[3][1],Deque[3][2],0x19C,Deque[3][3],SetTo,Dest[1][1],Dest[1][2],Dest[1][3],1,Dest[1][4]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x1BC,Deque[3][3],SetTo,Dest[2][1],Dest[2][2],Dest[2][3],1,Dest[2][4]);
				},
				flag = {Preserved}
			}
		end
		Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[3][1],Deque[3][2],0x30,Deque[3][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x198,Deque[3][3],Add,-604*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x1B8,Deque[3][3],Add,-604*Size);

					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x15C,Deque[5][3],Add,-604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x178,Deque[5][3],Add,-604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x19C,Deque[5][3],Add,-604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x1B8,Deque[5][3],Add,-604*Size);
				},
				flag = {Preserved}
			}
		if PDest ~= nil then
			MovW(PlayerID,PDest,{"X",WRet[8],0,"W"})
		end
	else -- SVA3~32
		local PDest
		if Dest[4] == "SVA" then
			PDest = Dest
			Dest = {"X",SRet[Dest[5][5]][4],0,"SV",Dest[5][5],Dest[5][7]}
		end

		if Dest[4] == "SV" and Dest[5] == Number then
			local Box0 = {}
			local Box1 = {}
			local Box2 = {}
			for i = 1, Number do
				table.insert(Box0,SetCtrig1X(Deque[3][1],Deque[3][2],0x198+0x20*(i-1),Deque[3][3],Add,-604*Size))
				table.insert(Box1,SetCtrig1X(Deque[3][1],Deque[3][2],0x198+0x20*(i-1),Deque[3][3],Add,604))
				table.insert(Box1,SetCtrigX(Deque[3][1],Deque[3][2],0x19C+0x20*(i-1),Deque[3][3],SetTo,Dest[1],Dest[2],0x15C+0x40*(i-1),1,Dest[3]))
				table.insert(Box1,SetCtrig1X(Deque[5][1],Deque[5][2],0x15C+0x40*(i-1),Deque[5][3],Add,604))
				table.insert(Box1,SetCtrig1X(Deque[5][1],Deque[5][2],0x178+0x40*(i-1),Deque[5][3],Add,604))
				table.insert(Box2,SetCtrig1X(Deque[5][1],Deque[5][2],0x15C+0x40*(i-1),Deque[5][3],Add,-604*Size))
				table.insert(Box2,SetCtrig1X(Deque[5][1],Deque[5][2],0x178+0x40*(i-1),Deque[5][3],Add,-604*Size))
			end

			DoActions2X(PlayerID,Box1)
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,1); -- front
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,0x970);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,604);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,1); -- Rrear
					
					SetCtrigX("X","X",0x4,2,SetTo,Deque[3][1],Deque[3][2],0x0,0,Deque[3][3]);
					SetCtrigX(Deque[3][1],Deque[3][2],0x17C,Deque[3][3],SetTo,"X","X",0x0,0,3);
				},
				flag = {Preserved}
			}
		
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[3][1],Deque[3][2],0x30,Deque[3][3],AtLeast,Size);
				},
				actions = {
					Box2;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[3][1],Deque[3][2],0x30,Deque[3][3],AtLeast,Size);
				},
				actions = {
					SetCtrig1X(Deque[3][1],Deque[3][2],0x30,Deque[3][3],Add,-Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x15C,Deque[3][3],Add,-0x970*Size);
					SetCtrig1X(Deque[3][1],Deque[3][2],0x178,Deque[3][3],Add,-604*Size);
					SetCtrig1X(Deque[5][1],Deque[5][2],0x30,Deque[5][3],Add,-Size);
					Box0;
				},
				flag = {Preserved}
			}
		else
			NPop_front_InputData_Error()
		end
		if PDest ~= nil then
			MovS(PlayerID,PDest,Dest,SetTo)
		end
	end
end

function NPop_back(PlayerID,Deque,Dest)
	STPopTrigArr(PlayerID)
	local Number = Deque[1][5]
	local Size = Deque[1][6]
	if Number == 1 then -- V/Mem/SVA1
		local PDest
		if type(Dest) == "table" and Dest[4] == "VA" then
			PDest = Dest
			Dest = {"X",CRet[8],0,"V"}
		elseif type(Dest) == "table" and Dest[4] == "A" then
			PDest = Dest
			Dest = {"X",CRet[8],0,"V"}
		elseif type(Dest) == "table" and Dest[4] == "SVA" then
			PDestS = Dest
			Dest = {"X",SRet[Dest[5][5]][4],0,"SV",Dest[5][5],Dest[5][7]}
		end

		if type(Dest) == "number" then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX("X","X",0x4,0,SetTo,Deque[6][1],Deque[6][2],0x0,0,Deque[6][3]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x17C,Deque[6][3],SetTo,"X","X",0x0,0,1);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x19C,Deque[6][3],SetTo,EPD(Dest));
				},
				flag = {Preserved}
			}
		elseif Dest[4] == "V" or (Dest[4] == "SV" and Dest[5] == 1) then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX("X","X",0x4,0,SetTo,Deque[6][1],Deque[6][2],0x0,0,Deque[6][3]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x17C,Deque[6][3],SetTo,"X","X",0x0,0,1);
					SetCtrigX(Deque[6][1],Deque[6][2],0x19C,Deque[6][3],SetTo,Dest[1],Dest[2],0x15C,1,Dest[3]);
				},
				flag = {Preserved}
			}
		else -- Mem
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX("X","X",0x4,0,SetTo,Deque[6][1],Deque[6][2],0x0,0,Deque[6][3]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x17C,Deque[6][3],SetTo,"X","X",0x0,0,1);
					SetCtrigX(Deque[6][1],Deque[6][2],0x19C,Deque[6][3],SetTo,Dest[1],Dest[2],Dest[3],1,Dest[4]);
				},
				flag = {Preserved}
			}
		end
		Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-1); -- Rfront
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,-604);

					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-1); -- rear
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,-604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,-604);
				},
				flag = {Preserved}
			}
		Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[6][1],Deque[6][2],0x30,Deque[6][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,604*Size);

					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,604*Size);
				},
				flag = {Preserved}
			}
		if PDest ~= nil then
			MovX(PlayerID,PDest,Dest)
		end
	elseif Number == 2 then -- W/LMem/SVA2
		local PDest
		if type(Dest) == "table" and Dest[4] == "WA" then
			PDest = Dest
			Dest = {"X",WRet[8],0,"W"}
		elseif type(Dest) == "table" and Dest[4] == "LA_V" then
			PDest = Dest
			Dest = {"X",WRet[8],0,"W"}
		elseif type(Dest) == "table" and Dest[4] == "LA_W" then
			PDest = Dest
			Dest = {"X",WRet[8],0,"W"}
		elseif type(Dest) == "table" and Dest[4] == "SVA" then
			PDestS = Dest
			Dest = {"X",SRet[Dest[5][5]][4],0,"SV",Dest[5][5],Dest[5][7]}
		end

		if type(Dest) == "number" or (type(Dest) == "table" and type(Dest[1]) == "number" and (type(Dest[2]) == "number" or (type(Dest[2]) == "table" and type(Dest[2][1]) == "number")) and #Dest == 2) then
			if type(Dest) == "number" then
				Dest = {Dest,Dest+4}
			elseif type(Dest) == "table" and type(Dest[2]) == "table" then
				Dest = {Dest[1],Dest[1]+Dest[2][1]}
			end

			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX("X","X",0x4,0,SetTo,Deque[6][1],Deque[6][2],0x0,0,Deque[6][3]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x17C,Deque[6][3],SetTo,"X","X",0x0,0,1);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x19C,Deque[6][3],SetTo,EPD(Dest[1]));
					SetCtrig1X(Deque[6][1],Deque[6][2],0x1BC,Deque[6][3],SetTo,EPD(Dest[2]));
				},
				flag = {Preserved}
			}
		elseif Dest[4] == "W" or (Dest[4] == "SV" and Dest[5] == 2) then
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX("X","X",0x4,0,SetTo,Deque[6][1],Deque[6][2],0x0,0,Deque[6][3]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x17C,Deque[6][3],SetTo,"X","X",0x0,0,1);
					SetCtrigX(Deque[6][1],Deque[6][2],0x19C,Deque[6][3],SetTo,Dest[1],Dest[2],0x15C,1,Dest[3]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x1BC,Deque[6][3],SetTo,Dest[1],Dest[2],0x19C,1,Dest[3]);
				},
				flag = {Preserved}
			}
		else -- LMem
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX("X","X",0x4,0,SetTo,Deque[6][1],Deque[6][2],0x0,0,Deque[6][3]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x17C,Deque[6][3],SetTo,"X","X",0x0,0,1);
					SetCtrigX(Deque[6][1],Deque[6][2],0x19C,Deque[6][3],SetTo,Dest[1][1],Dest[1][2],Dest[1][3],1,Dest[1][4]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x1BC,Deque[6][3],SetTo,Dest[2][1],Dest[2][2],Dest[2][3],1,Dest[2][4]);
				},
				flag = {Preserved}
			}
		end
		Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-1); -- Rfront
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,-604);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x1B8,Deque[6][3],Add,-604);

					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-1); -- rear
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,-604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,-604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x19C,Deque[2][3],Add,-604);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x1B8,Deque[2][3],Add,-604);
				},
				flag = {Preserved}
			}
		Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[6][1],Deque[6][2],0x30,Deque[6][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x198,Deque[6][3],Add,604*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x1B8,Deque[6][3],Add,604*Size);

					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x15C,Deque[2][3],Add,604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x178,Deque[2][3],Add,604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x19C,Deque[2][3],Add,604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x1B8,Deque[2][3],Add,604*Size);
				},
				flag = {Preserved}
			}
		if PDest ~= nil then
			MovW(PlayerID,PDest,{"X",WRet[8],0,"W"})
		end
	else -- SVA3~32
		local PDest
		if Dest[4] == "SVA" then
			PDest = Dest
			Dest = {"X",SRet[Dest[5][5]][4],0,"SV",Dest[5][5],Dest[5][7]}
		end

		if Dest[4] == "SV" and Dest[5] == Number then
			local Box0 = {}
			local Box1 = {}
			local Box2 = {}
			local Box3 = {}
			for i = 1, Number do
				table.insert(Box0,SetCtrig1X(Deque[6][1],Deque[6][2],0x198+0x20*(i-1),Deque[6][3],Add,604*Size))
				table.insert(Box1,SetCtrig1X(Deque[6][1],Deque[6][2],0x198+0x20*(i-1),Deque[6][3],Add,-604))
				table.insert(Box3,SetCtrigX(Deque[6][1],Deque[6][2],0x19C+0x20*(i-1),Deque[6][3],SetTo,Dest[1],Dest[2],0x15C+0x40*(i-1),1,Dest[3]))
				table.insert(Box1,SetCtrig1X(Deque[2][1],Deque[2][2],0x15C+0x40*(i-1),Deque[2][3],Add,-604))
				table.insert(Box1,SetCtrig1X(Deque[2][1],Deque[2][2],0x178+0x40*(i-1),Deque[2][3],Add,-604))
				table.insert(Box2,SetCtrig1X(Deque[2][1],Deque[2][2],0x15C+0x40*(i-1),Deque[2][3],Add,604*Size))
				table.insert(Box2,SetCtrig1X(Deque[2][1],Deque[2][2],0x178+0x40*(i-1),Deque[2][3],Add,604*Size))
			end

			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
				},
				actions = {
					SetCtrigX("X","X",0x4,0,SetTo,Deque[6][1],Deque[6][2],0x0,0,Deque[6][3]);
					SetCtrigX(Deque[6][1],Deque[6][2],0x17C,Deque[6][3],SetTo,"X","X",0x0,0,1);
					Box3;
				},
				flag = {Preserved}
			}
			DoActions2X(PlayerID,{
				SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,-1); -- Rfront
				SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,-0x970);
				SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,-604);
				SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,-1); -- rear
				Box1;
			})
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[6][1],Deque[6][2],0x30,Deque[6][3],AtLeast,0x80000000);
				},
				actions = {
					Box2;
				},
				flag = {Preserved}
			}
			Trigger {
				players = {PlayerID},
				conditions = {
					Label(0);
					CtrigX(Deque[6][1],Deque[6][2],0x30,Deque[6][3],AtLeast,0x80000000);
				},
				actions = {
					SetCtrig1X(Deque[6][1],Deque[6][2],0x30,Deque[6][3],Add,Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x15C,Deque[6][3],Add,0x970*Size);
					SetCtrig1X(Deque[6][1],Deque[6][2],0x178,Deque[6][3],Add,604*Size);
					SetCtrig1X(Deque[2][1],Deque[2][2],0x30,Deque[2][3],Add,Size);
					Box0;
				},
				flag = {Preserved}
			}
		else
			NPop_back_InputData_Error()
		end
		if PDest ~= nil then
			MovS(PlayerID,PDest,Dest,SetTo)
		end
	end
end

function InitWarpQueue(PlayerID,Size,Delay,TempX,TempY,XSize,YSize,Xpx,Ypx)
	if Delay <= 0 or Delay > 19 then
		InitWarpQueue_InputData_Error()
	end
	local FP = PlayerID
	local WarpQSize, WarpDelay = Size, Delay
	local SX, SY, NX, NY, dX, dY = TempX, TempY, XSize, YSize, Xpx, Ypx
	
	local WarpQ = NDeque(FP,10,WarpQSize+1) -- EPD, OrderX, OrderY, X, Y, WX, WY, PID, UID, OrderID
	local NextEPD, QSize, QIdx, TX, TY, TPID, TUID, MX, MY = CreateVars(9,FP)
	local SV10 = CreateSVar(10,FP)

	local WarpFunc = InitCFunc(FP,1)
	local Para = CFunc(WarpFunc)
		local WarpX, WarpY, WarpR = CreateVars(3,FP)
		CDiv(FP,Para[1],NY)
		CMov(FP,WarpR,V(CRet[2]))
		CAdd(FP,WarpX,_Mul(WarpR,dX),SX)
		CAdd(FP,WarpY,_Mul(Para[1],dY),SY)
	CFuncEnd()
	
	return {WarpQ, {WarpQSize, WarpDelay, SX, SY, NX, NY, dX, dY}, {NextEPD, QSize, QIdx, TX, TY, TPID, TUID, MX, MY, WarpX, WarpY, WarpR}, "WarpQ", SV10, WarpFunc}
end

function WarpEnqueue(PlayerID,WarpQ,X,Y,OrderX,OrderY,OrderID,PlotSize,Owner,UnitId,Location,Properties)
	if type(OrderID) == "number" then
		OrderID = OrderID * 256
	end
	if WarpQ[4] ~= "WarpQ" then
		WarpEnqueue_InputData_Error()
	end
	local FP = PlayerID
	local WarpQSize, WarpDelay, SX, SY, NX, NY, dX, dY = WarpQ[2][1], WarpQ[2][2], WarpQ[2][3], WarpQ[2][4], WarpQ[2][5], WarpQ[2][6], WarpQ[2][7], WarpQ[2][8] 
	local NextEPD, QSize, QIdx, WarpX, WarpY, WarpR = WarpQ[3][1], WarpQ[3][2], WarpQ[3][3], WarpQ[3][10], WarpQ[3][11], WarpQ[3][12]
	local WQ, SV10, WarpFunc = WarpQ[1], WarpQ[5], WarpQ[6]
	
	NIf(FP,{Memory(0x628438,AtLeast,1),NVar(QSize,AtMost,WarpQSize-1)})
		f_CunitRead(FP,0x628438,nil,NextEPD)
		CallCFuncX(FP,WarpFunc,{QIdx})
		CMov(FP,WarpR,OrderID)

		SMov(FP,SV10[1],{NextEPD,OrderX,OrderY,X,Y,WarpX,WarpY,Owner,UnitId,WarpR})
		NPush_back(FP,WQ,SV10[1])
	
		if Properties == nil then
			CDoActions(FP,{
					TSetLoc(Location,"L",SetTo,Vi(WarpX[2],-PlotSize));
					TSetLoc(Location,"R",SetTo,Vi(WarpX[2],PlotSize));
					TSetLoc(Location,"U",SetTo,Vi(WarpY[2],-PlotSize));
					TSetLoc(Location,"D",SetTo,Vi(WarpY[2],PlotSize));
					TCreateUnit(1,UnitId,Location,Owner),
					TSetDeathsX(Vi(NextEPD[2],0x4C/4),SetTo,48*0x0100+0x01010000,0,0xFFFFFF00),
					TSetDeathsX(Vi(NextEPD[2],0x110/4),SetTo,65535,0,0xFFFF),
					TSetDeathsX(Vi(NextEPD[2],0xDC/4),SetTo,0x04000000,0,0x04000000),
					SetNVar(QIdx,Add,1),SetNVar(QSize,Add,1),
			})
		else
			CDoActions(FP,{
					TSetLoc(Location,"L",SetTo,Vi(WarpX[2],-PlotSize));
					TSetLoc(Location,"R",SetTo,Vi(WarpX[2],PlotSize));
					TSetLoc(Location,"U",SetTo,Vi(WarpY[2],-PlotSize));
					TSetLoc(Location,"D",SetTo,Vi(WarpY[2],PlotSize));
					TCreateUnitWithProperties(1,UnitId,Location,Owner,Properties),
					TSetDeathsX(Vi(NextEPD[2],0x4C/4),SetTo,48*0x0100+0x01010000,0,0xFFFFFF00),
					TSetDeathsX(Vi(NextEPD[2],0x110/4),SetTo,65535,0,0xFFFF),
					TSetDeathsX(Vi(NextEPD[2],0xDC/4),SetTo,0x04000000,0,0x04000000),
					SetNVar(QIdx,Add,1),SetNVar(QSize,Add,1),
			})
		end
		TriggerX(FP,{NVar(QIdx,AtLeast,WarpQSize)},{SetNVar(QIdx,SetTo,0)},{Preserved})
	NIfEnd()
end

function WarpEnqueueX(PlayerID,WarpQ,X,Y,OrderX,OrderY,OrderID,PlotSize,Owner,UnitId,Location,Properties)
	if type(OrderID) == "number" then
		OrderID = OrderID * 256
	end
	if WarpQ[4] ~= "WarpQ" then
		WarpEnqueueX_InputData_Error()
	end
	local FP = PlayerID
	local WarpQSize, WarpDelay, SX, SY, NX, NY, dX, dY = WarpQ[2][1], WarpQ[2][2], WarpQ[2][3], WarpQ[2][4], WarpQ[2][5], WarpQ[2][6], WarpQ[2][7], WarpQ[2][8] 
	local NextEPD, QSize, QIdx, WarpX, WarpY, WarpR = WarpQ[3][1], WarpQ[3][2], WarpQ[3][3], WarpQ[3][10], WarpQ[3][11], WarpQ[3][12]
	local WQ, SV10, WarpFunc = WarpQ[1], WarpQ[5], WarpQ[6]
	
	NIf(FP,{Memory(0x628438,AtLeast,1),NVar(QSize,AtMost,WarpQSize-1)},{SetNVar(WarpX,SetTo,0x80000000),SetNVar(WarpY,SetTo,0x80000000)})
		f_CunitRead(FP,0x628438,nil,NextEPD)
		CMov(FP,WarpR,OrderID)
		
		SMov(FP,SV10[1],{NextEPD,OrderX,OrderY,X,Y,WarpX,WarpY,Owner,UnitId,WarpR})
		NPush_back(FP,WQ,SV10[1])
	
		if Properties == nil then
			CDoActions(FP,{
					TSetLoc(Location,"L",SetTo,Vi(X[2],-PlotSize));
					TSetLoc(Location,"R",SetTo,Vi(X[2],PlotSize));
					TSetLoc(Location,"U",SetTo,Vi(Y[2],-PlotSize));
					TSetLoc(Location,"D",SetTo,Vi(Y[2],PlotSize));
					TCreateUnit(1,UnitId,Location,Owner),
					TSetDeathsX(Vi(NextEPD[2],0x4C/4),SetTo,48*0x0100+0x01010000,0,0xFFFFFF00),
					TSetDeathsX(Vi(NextEPD[2],0x110/4),SetTo,65535,0,0xFFFF),
					TSetDeathsX(Vi(NextEPD[2],0xDC/4),SetTo,0x04000000,0,0x04000000),
					SetNVar(QIdx,Add,1),SetNVar(QSize,Add,1),
			})
		else
			CDoActions(FP,{
					TSetLoc(Location,"L",SetTo,Vi(X[2],-PlotSize));
					TSetLoc(Location,"R",SetTo,Vi(X[2],PlotSize));
					TSetLoc(Location,"U",SetTo,Vi(Y[2],-PlotSize));
					TSetLoc(Location,"D",SetTo,Vi(Y[2],PlotSize));
					TCreateUnitWithProperties(1,UnitId,Location,Owner,Properties),
					TSetDeathsX(Vi(NextEPD[2],0x4C/4),SetTo,48*0x0100+0x01010000,0,0xFFFFFF00),
					TSetDeathsX(Vi(NextEPD[2],0x110/4),SetTo,65535,0,0xFFFF),
					TSetDeathsX(Vi(NextEPD[2],0xDC/4),SetTo,0x04000000,0,0x04000000),
					SetNVar(QIdx,Add,1),SetNVar(QSize,Add,1),
			})
		end
		TriggerX(FP,{NVar(QIdx,AtLeast,WarpQSize)},{SetNVar(QIdx,SetTo,0)},{Preserved})
	NIfEnd()
end

function WarpDequeue(PlayerID,WarpQ,PlotSize,Location1,Location2)
	if WarpQ[4] ~= "WarpQ" then
		WarpDequeue_InputData_Error()
	end
	local FP = PlayerID
	local WarpQSize, WarpDelay, SX, SY, NX, NY, dX, dY = WarpQ[2][1], WarpQ[2][2], WarpQ[2][3], WarpQ[2][4], WarpQ[2][5], WarpQ[2][6], WarpQ[2][7], WarpQ[2][8] 
	local NextEPD, QSize, QIdx, WarpX, WarpY, WarpR = WarpQ[3][1], WarpQ[3][2], WarpQ[3][3], WarpQ[3][10], WarpQ[3][11], WarpQ[3][12]
	local TX, TY, TPID, TUID, MX, MY = WarpQ[3][4], WarpQ[3][5], WarpQ[3][6], WarpQ[3][7], WarpQ[3][8], WarpQ[3][9]
	local WQ, SV10 = WarpQ[1], WarpQ[5]
	
	NWhileX(FP,{NVar(QSize,AtLeast,1)})
		NPop_front(FP,WQ,SV10[1])
		SMov(FP,{NextEPD,MX,MY,TX,TY,WarpX,WarpY,TPID,TUID,WarpR},SV10[1])
		
		NIfX(FP,{
			TDeathsX(Vi(NextEPD[2],0x4C/4),Exactly,48*0x0100,0,0xFF00),
			TDeathsX(Vi(NextEPD[2],0x110/4),AtMost,65535-WarpDelay,0,0xFFFF),
		})
			NIfX(FP,{NVar(WarpX,Exactly,0x80000000),NVar(WarpY,Exactly,0x80000000)}) -- Direct Spawn Mode
				CAdd(FP,WarpX,_lShift2(MY,16),MX)
				CDoActions(FP,{
					TSetDeathsX(Vi(NextEPD[2],0xDC/4),SetTo,0x00000000,0,0x04000000),
					TSetDeathsX(Vi(NextEPD[2],0x4C/4),SetTo,WarpR,0,0xFFFFFF00),
					TSetDeathsX(Vi(NextEPD[2],0x110/4),SetTo,0,0,0xFFFF),
					TSetDeaths(Vi(NextEPD[2],0x10/4),SetTo,WarpX,0),
					TSetDeaths(Vi(NextEPD[2],0x18/4),SetTo,WarpX,0),
					TSetDeaths(Vi(NextEPD[2],0x58/4),SetTo,WarpX,0),
				})
			NElseX() -- Delayed Spawn Mode
				CDoActions(FP,{
					TSetLoc(Location1,"L",SetTo,Vi(WarpX[2],-dX/2));
					TSetLoc(Location1,"R",SetTo,Vi(WarpX[2],dX/2));
					TSetLoc(Location1,"U",SetTo,Vi(WarpY[2],-dY/2));
					TSetLoc(Location1,"D",SetTo,Vi(WarpY[2],dY/2));
					TSetLoc(Location2,"L",SetTo,Vi(TX[2],-PlotSize));
					TSetLoc(Location2,"R",SetTo,Vi(TX[2],PlotSize));
					TSetLoc(Location2,"U",SetTo,Vi(TY[2],-PlotSize));
					TSetLoc(Location2,"D",SetTo,Vi(TY[2],PlotSize));
					TMoveUnit(1,TUID,TPID,Location1,Location2);
					TSetDeathsX(Vi(NextEPD[2],0xDC/4),SetTo,0x00000000,0,0x04000000),
					TSetDeathsX(Vi(NextEPD[2],0x4C/4),SetTo,WarpR,0,0xFF00),
					TSetDeathsX(Vi(NextEPD[2],0x110/4),SetTo,0,0,0xFFFF),
					TSetDeaths(Vi(NextEPD[2],0x58/4),SetTo,_Add(_lShift2(MY,16),MX),0),
				})
				f_ReadX(FP,_Add(NextEPD,0x28/4),WarpR,"-2",0xFFFF0000,1)
				NIfNotX(FP,{
					TTNVar(WarpR,iAtLeast,Vi(TY[2],-PlotSize)),
					TTNVar(WarpR,iAtMost,Vi(TY[2],PlotSize)),
					TTDeathsX(Vi(NextEPD[2],0x28/4),iAtLeast,Vi(TX[2],-PlotSize),0,0xFFFF),
					TTDeathsX(Vi(NextEPD[2],0x28/4),iAtMost,Vi(TX[2],PlotSize),0,0xFFFF),
				})
					CDoActions(FP,{TSetDeathsX(Vi(NextEPD[2],0x4C/4),SetTo,0,0,0xFF00)})
				NIfXEnd()
			NIfXEnd()
		NElseIfX({
			TDeathsX(Vi(NextEPD[2],0x4C/4),Exactly,48*0x0100,0,0xFF00),
			TDeathsX(Vi(NextEPD[2],0x110/4),AtLeast,65536-WarpDelay,0,0xFFFF)
		})
			NPush_front(FP,WQ,SV10[1])
			CJump(FP,CAPlotJumpAlloc)
		NElseX()
			CDoActions(FP,{TSetDeathsX(Vi(NextEPD[2],0x4C/4),SetTo,0,0,0xFF00)})
		NIfXEnd()	
	NWhileXEnd({SetNVar(QSize,Subtract,1)})
	CJumpEnd(FP,CAPlotJumpAlloc)
	CAPlotJumpAlloc = CAPlotJumpAlloc + 1
end