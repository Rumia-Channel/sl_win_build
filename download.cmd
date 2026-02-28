@echo off

cd /d %~dp0

rd /s /q sl
rd /s /q PDCurses

git clone https://github.com/Rumia-Channel/sl.git
git clone https://github.com/Rumia-Channel/PDCurses.git