set PASCOC=..\..\PasDocEx\bin\pasdoc
set SOURCE=sources.txt
set OPTIONS=--name "Ooogles" --title "Ooogles" --auto-abstract --auto-link --visible-members public,published,automated --include "..\Source\"
del ..\Doc\%FORMAT%\*.* /q
del ..\Doc\%FORMAT%\tipuesearch\*.* /q
%PASCOC% --format %FORMAT% --output ..\Doc\%FORMAT% --css %FORMAT%.css --introduction=introduction.txt --conclusion=conclusion.txt --source %SOURCE% %OPTIONS% %SEARCH%