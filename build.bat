@Echo Off

:: --- 1. CONFIGURATION ---
set _buildexe="C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
set _solution=logrotate.sln

:: Default action and configuration if no arguments are provided
set _action=Build
set _config=Release

:: --- 2. ARGUMENT PARSING ---

:: Check if an argument was provided (e.g., build.bat Debug)
if "%~1"=="" goto Usage  :: JUMP HERE if no arguments are provided

:: Convert the first argument to lowercase for flexible matching
set _arg1=%1
for %%i in ("!_arg1!") do (
    set "_arg1=%%~i"
)

:: ACTION SWITCH (Cleans or Rebuilds take precedence)
if /i "%~1"=="clean"   set _action=Clean & goto CheckBuildExe
if /i "%~1"=="rebuild" set _action=Rebuild & goto CheckBuildExe

:: CONFIGURATION SWITCH (If only config is provided, the action is Build)
if /i "%~1"=="debug"   set _config=Debug & set _action=Build & goto CheckBuildExe
if /i "%~1"=="release" set _config=Release & set _action=Build & goto CheckBuildExe

:: Check for action/config combination (e.g., build.bat Rebuild Debug)
if not "%~2"=="" (
    if /i "%~2"=="debug"   set _config=Debug
    if /i "%~2"=="release" set _config=Release
)

:: --- 3. EXECUTION ---
:CheckBuildExe

if exist %_buildexe% (
    Echo.
    Echo Starting MSBuild...
    Echo Solution: %_solution%
    Echo Action:   %_action%
    Echo Config:   %_config%
    Echo.
    
    :: Execute the MSBuild command with the determined action and configuration
    %_buildexe% %_solution% /t:%_action% /p:Configuration=%_config%
) else (
    Echo.
    Echo Error :: Local MSBuild.exe doesn't exist at %_buildexe%
    Echo Hint :: You must have the .NET Framework installed. If the path is wrong, update the _buildexe variable.
    Echo.
    exit /b 1
)

Echo.
Echo Batch file execution complete.
goto :EOF


:: --- 4. USAGE MESSAGE ---
:Usage
Echo =======================================================
Echo           logrotatewin Build Script Usage
Echo =======================================================
Echo SYNOPSIS:
Echo   build.bat [action] [configuration]
Echo . 
Echo ACTIONS: (Targeted using /t:<action>)
Echo   <empty>   (default) - Compiles the project.
Echo   Clean               - Removes all built files.
Echo   Rebuild             - Performs Clean, then Build.
Echo .  
Echo CONFIGURATIONS: (Targeted using /p:Configuration=<config>)
Echo   Release             - Optimized, final output.
Echo   Debug               - Output with debugging symbols.
Echo .  
Echo EXAMPLES:
Echo   build.bat Release         :: Builds the solution in Release mode (Build Release)
Echo   build.bat Debug           :: Builds the solution in Debug mode (Build Debug)
Echo   build.bat Clean           :: Cleans the Release output (Clean Release)
Echo   build.bat Rebuild Debug   :: Rebuilds the solution in Debug mode
Echo . 
Echo =======================================================
exit /b 0