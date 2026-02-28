cmake_minimum_required(VERSION 3.10)
project(sl_win_build C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# MSVC のデフォルトデバッグフラグをクリア（/RTC1 と /O2 の競合を避けるため）
if(MSVC)
    set(CMAKE_C_FLAGS_DEBUG "")
    set(CMAKE_C_FLAGS_RELEASE "")
endif()

# SL バリアントオプション（erutaso / pyonpyon / sl）
set(SL_VARIANT "sl" CACHE STRING "SL variant to build (sl, erutaso, pyonpyon)")
set_property(CACHE SL_VARIANT PROPERTY STRINGS sl erutaso pyonpyon)

# 出力ファイル名を決定
if(SL_VARIANT STREQUAL "erutaso")
    set(SL_OUTPUT_NAME "erutaso")
elseif(SL_VARIANT STREQUAL "pyonpyon")
    set(SL_OUTPUT_NAME "pyonpyon")
else()
    set(SL_OUTPUT_NAME "sl")
endif()

message(STATUS "Building SL variant: ${SL_VARIANT}")
message(STATUS "Output executable: ${SL_OUTPUT_NAME}.exe")

# PDCurses ソースディレクトリ
set(PDCURSES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/PDCurses)
set(PDCURSES_SRCDIR ${PDCURSES_DIR})
set(PDCURSES_WINCON_DIR ${PDCURSES_DIR}/wincon)

# PDCurses コアソースファイル
set(PDCURSES_CORE_SOURCES
    ${PDCURSES_DIR}/pdcurses/addch.c
    ${PDCURSES_DIR}/pdcurses/addchstr.c
    ${PDCURSES_DIR}/pdcurses/addstr.c
    ${PDCURSES_DIR}/pdcurses/attr.c
    ${PDCURSES_DIR}/pdcurses/beep.c
    ${PDCURSES_DIR}/pdcurses/bkgd.c
    ${PDCURSES_DIR}/pdcurses/border.c
    ${PDCURSES_DIR}/pdcurses/clear.c
    ${PDCURSES_DIR}/pdcurses/color.c
    ${PDCURSES_DIR}/pdcurses/debug.c
    ${PDCURSES_DIR}/pdcurses/delch.c
    ${PDCURSES_DIR}/pdcurses/deleteln.c
    ${PDCURSES_DIR}/pdcurses/getch.c
    ${PDCURSES_DIR}/pdcurses/getstr.c
    ${PDCURSES_DIR}/pdcurses/getyx.c
    ${PDCURSES_DIR}/pdcurses/inch.c
    ${PDCURSES_DIR}/pdcurses/inchstr.c
    ${PDCURSES_DIR}/pdcurses/initscr.c
    ${PDCURSES_DIR}/pdcurses/inopts.c
    ${PDCURSES_DIR}/pdcurses/insch.c
    ${PDCURSES_DIR}/pdcurses/insstr.c
    ${PDCURSES_DIR}/pdcurses/instr.c
    ${PDCURSES_DIR}/pdcurses/kernel.c
    ${PDCURSES_DIR}/pdcurses/keyname.c
    ${PDCURSES_DIR}/pdcurses/mouse.c
    ${PDCURSES_DIR}/pdcurses/move.c
    ${PDCURSES_DIR}/pdcurses/outopts.c
    ${PDCURSES_DIR}/pdcurses/overlay.c
    ${PDCURSES_DIR}/pdcurses/pad.c
    ${PDCURSES_DIR}/pdcurses/panel.c
    ${PDCURSES_DIR}/pdcurses/printw.c
    ${PDCURSES_DIR}/pdcurses/refresh.c
    ${PDCURSES_DIR}/pdcurses/scanw.c
    ${PDCURSES_DIR}/pdcurses/scr_dump.c
    ${PDCURSES_DIR}/pdcurses/scroll.c
    ${PDCURSES_DIR}/pdcurses/slk.c
    ${PDCURSES_DIR}/pdcurses/termattr.c
    ${PDCURSES_DIR}/pdcurses/touch.c
    ${PDCURSES_DIR}/pdcurses/util.c
    ${PDCURSES_DIR}/pdcurses/window.c
)

# PDCurses Windowsコンソール固有のソースファイル
set(PDCURSES_WINCON_SOURCES
    ${PDCURSES_WINCON_DIR}/pdcclip.c
    ${PDCURSES_WINCON_DIR}/pdcdisp.c
    ${PDCURSES_WINCON_DIR}/pdcgetsc.c
    ${PDCURSES_WINCON_DIR}/pdckbd.c
    ${PDCURSES_WINCON_DIR}/pdcscrn.c
    ${PDCURSES_WINCON_DIR}/pdcsetsc.c
    ${PDCURSES_WINCON_DIR}/pdcutil.c
)

# PDCurses 静的ライブラリの作成
add_library(pdcurses STATIC
    ${PDCURSES_CORE_SOURCES}
    ${PDCURSES_WINCON_SOURCES}
)

# PDCurses のインクルードディレクトリ
target_include_directories(pdcurses PUBLIC
    ${PDCURSES_DIR}
)

# PDCurses のコンパイルフラグ
if(MSVC)
    target_compile_options(pdcurses PRIVATE
        /O2
        /W4
    )
else()
    target_compile_options(pdcurses PRIVATE
        -O2
        -Wall
    )
endif()

# SL 実行ファイルの作成
add_executable(sl
    ${CMAKE_CURRENT_SOURCE_DIR}/sl/sl.c
)

# 出力ファイル名を設定
set_target_properties(sl PROPERTIES
    OUTPUT_NAME ${SL_OUTPUT_NAME}
)

# SL のインクルードディレクトリ
target_include_directories(sl PRIVATE
    ${PDCURSES_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/sl
)

# Windows 用の互換定義
if(MSVC)
    # unistd.h の代わりに windows.h を使用し、usleep を Sleep に置き換え
    target_compile_definitions(sl PRIVATE 
        _CRT_SECURE_NO_WARNINGS
        "usleep(x)=Sleep((x)/1000)"
    )
    # windows.h をインクルードするための定義
    set_property(TARGET sl APPEND PROPERTY COMPILE_DEFINITIONS "SL_SKIP_UNISTD")
endif()

# SL のコンパイルフラグ
if(MSVC)
    target_compile_options(sl PRIVATE
        /O2
        /W4
    )
else()
    target_compile_options(sl PRIVATE
        -O
        -Wall
    )
endif()

# SL に PDCurses をリンク
target_link_libraries(sl PRIVATE
    pdcurses
)

# Windows 固有のライブラリリンク
target_link_libraries(sl PRIVATE
    winmm
)

# インストールターゲット
install(TARGETS sl
    RUNTIME DESTINATION bin
)
