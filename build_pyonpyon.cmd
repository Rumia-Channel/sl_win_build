@echo off

cd /d %~dp0

cd sl
git checkout pyonpyon
cd ..

rd /s /q build
md build
cd build

cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DSL_VARIANT=pyonpyon ..
nmake
