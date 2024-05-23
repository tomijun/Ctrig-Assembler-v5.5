-- EXTLua Loader for Tep v2.0 Made by Ninfia

-- Curdir="scmdraft 설치경로(\를\\로 바꿔야함)"
--dofile(Curdir.."/Loader.lua")<- Tep v2.0 맨위에 입력후 사용

function __LoadLuaFiles(Path)
	for dir in io.popen("dir \""..Path.."\" /b"):lines() do
	    if dir:match "%.[Ll][Uu][Aa]$" and (dir ~= "Loader2X.lua" and dir ~= "LoaderX.lua" and dir ~= "Loader2.lua" and dir ~= "Loader.lua") then
			InitEXTLua = assert(loadfile(Path..dir))
			InitEXTLua()
		elseif (dir ~= "Loader2X.lua" and dir ~= "LoaderX.lua" and dir ~= "Loader2.lua" and dir ~= "Loader.lua") then
			__LoadLuaFiles(Path..dir.."\\")
	    end
	end
end

EXTLUA = Curdir.."\\lua\\"
__LoadLuaFiles(EXTLUA)

function __LoadLuaFilesX(Path)
	for dir in io.popen("dir \""..Path.."\" /b"):lines() do
	    if dir:match "%.[Ll][Uu][Aa]$" and not(dir:match "[Mm][Aa][Ii][Nn].[Ll][Uu][Aa]") then
			InitSUBLua = assert(loadfile(Path..dir))
			InitSUBLua()
		elseif not(dir:match "[Mm][Aa][Ii][Nn].[Ll][Uu][Aa]") then
			__LoadLuaFilesX(Path..dir.."\\")
	    end
	end
end

SUBLUA = Subdir.."\\"
__LoadLuaFilesX(SUBLUA)

--↑ 외부루아 불러오기----------------------------------------------------------------------------------------------------------------------