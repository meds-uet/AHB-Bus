@echo off
echo Cleaning up simulation files...
rd /s /q work
del transcript
del vsim.wlf
del *.log
del *.vcd
del wlf*
echo Cleanup done.