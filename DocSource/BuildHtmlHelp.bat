@echo off
set FORMAT=HtmlHelp
set HHC="%ProgramFiles(x86)%\HTML Help Workshop\hhc"
set SEARCH=
call Build.bat
%HHC% ..\Doc\HtmlHelp\Ooogles.hhp
copy ..\Doc\HtmlHelp\Ooogles.chm ..\Doc\ /y
..\Doc\Ooogles.chm
pause