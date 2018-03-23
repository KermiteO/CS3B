set projectName=Masm2
ml /c /Zd /coff /Fl %projectName%.asm
Link /SUBSYSTEM:CONSOLE -entry:MAIN %projectName%.obj ../macros/convutil201604.obj ../macros/utility201609.obj
del %projectName%.obj
%projectName%.exe