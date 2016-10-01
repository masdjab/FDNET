@ECHO OFF

REM FreeDOS 1.2+ Basic Networking Support Package.
REM Based on Rugxulo's MetaDOS CONNECT.BAT
REM Released Under GPL v2.0 License.
REM Copyright 2016 Jerome Shidel.

cd \

REM Set configuration environment variables.
if "%MTCPCFG%" == "" SET MTCPCFG=%dosdir%\MTCP.CFG
if "%WATTCP.CFG%" == "" SET WATTCP.CFG=%dosdir%
if "%EMAIL%" == "" SET EMAIL=anonymous@freedos.org

REM Install default configuration files.
if exist %MTCPCFG% goto HasMTCP
copy %DOSDIR%\NETWORK\MTCP.CFG %MTCPCFG%>NUL
:HasMTCP
if exist %WATTCP.CFG%\WATTCP.CFG goto HasWATTCP
copy %DOSDIR%\NETWORK\WATTCP.CFG %WATTCP.CFG%\WATTCP.CFG>NUL
:HasWATTCP

cd %DOSDIR%\NETWORK

REM Detect Virtual Machine Platform
vinfo /m
if errorlevel 200 goto vmGeneric
if errorlevel 104 goto vmVMware
if errorlevel 103 goto vmVirtualBox
if errorlevel 102 goto vmQEMU
if errorlevel 101 goto vmDOSBox

REM Detect Supported Hardware CPU Level
if errorlevel 6 goto hw686
if errorlevel 5 goto hw586
if errorlevel 4 goto hw486
if errorlevel 3 goto hw386
if errorlevel 2 goto hw286
if errorlevel 1 goto hw186
goto hw086

:hw086
:hw186
:hw286
:hw386
:hw486
:hw586
:hw686
vecho /fLightRed Physical hardware networking is not supported at this time. /fGrey /p
goto End

:vmDOSBox
vecho /fLightRed DOSBox networking is not supported at this time. /fGrey /p
goto End

:vmQEMU
vecho /fLightGreen QEMU network detected. /fGrey /p
goto vmGeneric

:vmVirtualBox
vecho /fLightGreen VirtualBOX ntwork detected. /fGrey /p
goto vmGeneric

:vmVMware
vecho /fLightGreen VMware network detected. /fGrey /p
SET NOTES=Please ensure VMware networking is configured for /fYellow Bridged /fLightCyan mode.
goto vmGeneric

:vmGeneric
REM ---------------------------------------------------------------------------
REM Cut and Paste from CONNECT.BAT
REM ---------------------------------------------------------------------------

berndpci 10222000
if errorlevel 1 goto pcntpk
berndpci 10ec8139
if errorlevel 1 goto rtspkt

goto qemu13

REM ... tested under Windows 7 64-bit Home Premium (no VT-X) ...
REM ... tested successfully with VirtualBox 4.3.6 ...
REM ... (also) qemu -net nic,model=pcnet -net user ...
:amdpd
:pcnet
:pcntpk
pcntpk.com int=0x60
goto finish

REM ... tested natively on Pentium 4 (Dell Dimension) ...
REM ... (sigh) no sources found, so not included here ...
:realtek
:rtl8139
:rtspkt
rtspkt.com 0x60
goto finish

REM ... tested successfully with QEMU 0.9.0 ...
REM qemu -L . -fda /rugxulo/tmp/metados.img -boot a \
REM   -net nic,model=ne2k_isa -net user
REM
:qemu090
:qemu09
:qemu90
:qemu9
ne2000.com -u
ne2000.com 0x60
goto finish

REM ... tested successfully with QEMU 0.13.0 ...
REM qemu -L bios -fda /rugxulo/tmp/metados.img -boot a \
REM   -netdev user,id=usernet -device ne2k_isa,irq=5,netdev=usernet
REM
:qemu0130
:qemu013
:qemu130
:qemu13
ne2000.com -u
ne2000.com 0x60 0x5 0x300
goto finish

:finish
REM ---------------------------------------------------------------------------
REM End of Cut and Paste
REM ---------------------------------------------------------------------------

:DHCP
DHCP.EXE

if "%NOTES%" == "" goto End
vecho /p /fCyan %NOTES% /fGrey /p
SET NOTES=

:End
cd \