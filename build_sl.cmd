@echo off

cd /d %~dp0

rd /s /q build
md build
cd build

cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release ..
nmake
