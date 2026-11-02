@echo off
setlocal EnableExtensions

rem ============================================================
rem  UnipusHelperPro launcher (Windows)
rem  ASCII-only + CRLF on purpose: upstream v1.0.3 shipped this
rem  file as UTF-8 with LF, which cmd.exe on a Chinese Windows
rem  mangles into "xxx is not recognized as a command".
rem  Requires Java 25+ (the build targets class file 69).
rem  Every failure path prints and waits, so a double-click on
rem  a broken install never closes the window silently.
rem ============================================================

set "SCRIPT_DIR=%~dp0"
set "JAR="

rem --- 1. locate the jar -------------------------------------
rem  release layout: run.bat next to the jar
for %%f in ("%SCRIPT_DIR%unipusHelperPro-*.jar" "%SCRIPT_DIR%UnipusHelperPro-*.jar") do (
  if exist "%%~f" if not defined JAR set "JAR=%%~f"
)
rem  maven layout: repo root, jar in target\
if not defined JAR (
  for %%f in ("%SCRIPT_DIR%target\unipusHelperPro-*.jar" "%SCRIPT_DIR%target\UnipusHelperPro-*.jar") do (
    if exist "%%~f" if not defined JAR set "JAR=%%~f"
  )
)
if not defined JAR (
  echo [ERROR] No UnipusHelperPro jar found.
  echo         Looked next to this script and in target\.
  echo         Build it first: mvn -B -DskipTests package
  echo.
  pause
  exit /b 1
)
for %%d in ("%JAR%") do set "JAR_DIR=%%~dpd"

rem --- 2. lib\ must sit next to the jar ----------------------
if not exist "%JAR_DIR%lib\" (
  echo [ERROR] Missing lib\ folder next to:
  echo         %JAR%
  echo         Extract the whole zip, not just the jar file.
  echo.
  pause
  exit /b 1
)

rem --- 3. pick a java 25+ ------------------------------------
rem  candidates: argument, JAVA_HOME, every java on PATH.
rem  JAVA_HOME is not trusted blindly: it is often an old JDK,
rem  so each candidate is version-checked and skipped when old.
set "JAVA_EXE="
set "JAVA_LAST="
set "JAVA_LAST_VER="
if not "%~1"=="" call :try_java "%~1"
if defined JAVA_HOME call :try_java "%JAVA_HOME%\bin\java.exe"
for /f "delims=" %%j in ('where java 2^>nul') do call :try_java "%%j"

if not defined JAVA_EXE (
  echo [ERROR] Java 25 or newer is required, none was found.
  if defined JAVA_LAST echo         Last candidate: %JAVA_LAST% ^(version %JAVA_LAST_VER%^)
  echo.
  echo   1^) Install Temurin JDK 25 from https://adoptium.net/temurin/releases/?version=25
  echo   2^) Point JAVA_HOME at that JDK, then run this script again
  echo   3^) Pass the path: run.bat "C:\path\to\jdk-25\bin\java.exe"
  echo.
  pause
  exit /b 1
)

rem --- 4. run, from the jar folder so logs\ lands next to it --
echo Java : %JAVA_EXE%
echo JAR  : %JAR%
echo.
pushd "%JAR_DIR%" >nul
"%JAVA_EXE%" -jar "%JAR%"
set "RC=%ERRORLEVEL%"
popd >nul
if not "%RC%"=="0" (
  echo.
  echo [ERROR] UnipusHelperPro exited with code %RC%.
  echo         Log file: %JAR_DIR%logs\latest.log
  echo.
  pause
)
exit /b %RC%

rem ------------------------------------------------------------
rem  :try_java <java.exe path>
rem  Sets JAVA_EXE when the candidate exists and is version 25+.
rem  The -version output is read from a temp file on purpose:
rem  a quoted path inside for /f loses its quotes and dies on
rem  "C:\Program Files\...".
rem ------------------------------------------------------------
:try_java
if defined JAVA_EXE exit /b 0
if not exist "%~1" exit /b 0
set "TMPV=%TEMP%\unipus_java_ver.txt"
"%~1" -version > "%TMPV%" 2>&1
set "VSTR="
for /f "tokens=3" %%a in ('findstr /i "version" "%TMPV%"') do set "VSTR=%%a"
del "%TMPV%" >nul 2>&1
set "VSTR=%VSTR:"=%"
set "MAJOR="
for /f "tokens=1 delims=._-" %%b in ("%VSTR%") do set "MAJOR=%%b"
if not defined MAJOR exit /b 0
set "JAVA_LAST=%~1"
set "JAVA_LAST_VER=%VSTR%"
if %MAJOR% LSS 25 exit /b 0
set "JAVA_EXE=%~1"
exit /b 0
