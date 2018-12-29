@echo off
@title Compile


if NOT exist "build" (
	mkdir "build"
)

spcomp_custom vsh.sp -ovsh.smx
cmd /c move "vsh.smx" "build\vsh.smx"

pause