@ECHO OFF


REM ---------------------------------------------------------------------------
REM - check BOOTSTRAP_DIR
REM ---------------------------------------------------------------------------
ECHO [%~n0] BOOTSTRAP_DIR=%BOOTSTRAP_DIR%
IF "_%BOOTSTRAP_DIR%_" == "__" (
  ECHO [%~n0] ERROR: environment variable BOOTSTRAP_DIR is not set.
  EXIT /B -1
)


REM ---------------------------------------------------------------------------
REM - check BOOTSTRAP_NAME
REM ---------------------------------------------------------------------------
ECHO [%~n0] BOOTSTRAP_NAME=%BOOTSTRAP_NAME%
IF "_%BOOTSTRAP_NAME%_" == "__" (
  ECHO [%~n0] ERROR: environment variable BOOTSTRAP_NAME is not set.
  EXIT /B -1
)


REM ---------------------------------------------------------------------------
REM - checking cmd args
REM ---------------------------------------------------------------------------
ECHO [%~n0] CMD ARGS=%*
SET BOOTSTRAP_PROPERTIES=%1
SET CALLER_LOCATION=%2
SET SETENV_OFFLINE_MODE=%3


REM ---------------------------------------------------------------------------
REM - check BOOTSTRAP_PROPERTIES
REM ---------------------------------------------------------------------------
ECHO [%~n0] BOOTSTRAP_PROPERTIES=%BOOTSTRAP_PROPERTIES%
IF "_%BOOTSTRAP_PROPERTIES%_" == "__" (
  ECHO [%~n0] ERROR: cmd argument 1 BOOTSTRAP_PROPERTIES is not set.
  EXIT /B -1
)


REM ---------------------------------------------------------------------------
REM - check CALLER_LOCATION
REM ---------------------------------------------------------------------------
ECHO [%~n0] CALLER_LOCATION=%CALLER_LOCATION%
IF "_%CALLER_LOCATION%_" == "__" (
  ECHO [%~n0] ERROR: cmd argument 2 CALLER_LOCATION is not set.
  EXIT /B -1
)


REM ---------------------------------------------------------------------------
REM - determine LOCAL_ENV_DIR
REM ---------------------------------------------------------------------------
IF "_%LOCAL_ENV_DIR%_" == "__" (
	SET LOCAL_ENV_DIR=%CALLER_LOCATION%.env
)	
ECHO [%~n0] LOCAL_ENV_DIR=%LOCAL_ENV_DIR%


REM ---------------------------------------------------------------------------
REM - set location of GENENV script 
REM - (the script to generate the calls to the tool's bootstrap scripts in)
REM ---------------------------------------------------------------------------

REM this only works if loop is for exactly one iteration
REM this has to happen before setlocal
FOR /d %%f IN (%LOCAL_ENV_DIR%) DO (SET GENENV_SCRIPT=%%~ff\genenv.bat)
ECHO [%~n0] GENENV_SCRIPT=%GENENV_SCRIPT%


REM ---------------------------------------------------------------------------
REM - if running in offline mode, skip the accurev part
REM ---------------------------------------------------------------------------

ECHO [%~n0] SETENV_OFFLINE_MODE=%SETENV_OFFLINE_MODE%
IF "__%SETENV_OFFLINE_MODE%__" == "__--offline__" (

	IF NOT EXIST %GENENV_SCRIPT% (
		ECHO [%~n0] WARNING: SETENV DID NOT FIND AN EXISTING GENENV SCRIPT FROM THE PREVIOUS RUN
	)
	
	GOTO SETENV_OFFLINE_MODE
)


REM ---------------------------------------------------------------------------
REM - remove previous GENENV script 
REM ---------------------------------------------------------------------------

REM delete previously generated genenv script (if applicable)
IF EXIST %GENENV_SCRIPT% (
	DEL %GENENV_SCRIPT%
)


REM ---------------------------------------------------------------------------
REM - enable delayed expansions
REM ---------------------------------------------------------------------------
SETLOCAL ENABLEDELAYEDEXPANSION


REM ---------------------------------------------------------------------------
REM - define dependencies of this bootstrap
REM ---------------------------------------------------------------------------
REM  java and groovy
SET BOOTSTRAP_DEPS=java, groovy 
SET BOOTSTRAP_JAVA=OpenJDK-jdk-1.7u25_win_x86
SET BOOTSTRAP_JAVA_GROUP=OpenJDK\jdk\1.7u25
SET BOOTSTRAP_JAVA_HOME=jdk
SET BOOTSTRAP_GROOVY=groovy-2.0.0
SET BOOTSTRAP_GROOVY_GROUP=groovy
SET BOOTSTRAP_GROOVY_HOME=.


REM SET DEP_HOME=
	

ECHO [%~n0] BOOTSTRAP_DEPS=%BOOTSTRAP_DEPS%
FOR %%z IN (%BOOTSTRAP_DEPS%) DO (
	
	ECHO [%~n0] resolving dependency %%z ...
	
	REM ---------------------------------------------------------------------------
	REM - split dependency into base and group name
	REM ---------------------------------------------------------------------------
	SET DEP_BASE=!BOOTSTRAP_%%z!
	SET DEP_GROUP=!BOOTSTRAP_%%z_GROUP!
    SET DEP_PART_HOME=!BOOTSTRAP_%%z_HOME!
	ECHO [%~n0] basename is=!DEP_BASE!
	ECHO [%~n0] group name is=!DEP_GROUP!
    ECHO [%~n0] part home is=!DEP_PART_HOME!
	

	REM ---------------------------------------------------------------------------
	REM - try several locations to find the dependency before fetching from accurev
	REM ---------------------------------------------------------------------------
	ECHO [%~n0] checking "!LOCAL_ENV_DIR!\!DEP_BASE!"
	IF EXIST "!LOCAL_ENV_DIR!\!DEP_BASE!" (
		ECHO [%~n0] -- found location for dependency !DEP_BASE!: !LOCAL_ENV_DIR!
		SET PATH=!PATH!;!LOCAL_ENV_DIR!\!DEP_BASE!\!DEP_PART_HOME!\bin
		SET DEP_HOME=!LOCAL_ENV_DIR!\!DEP_BASE!\!DEP_PART_HOME!
		ECHO DEP_HOME=!DEP_HOME!
		ECHO PATH=!PATH!
	) ELSE (
		ECHO [%~n0] checking "!GLOBAL_ENV_DIR!\!DEP_BASE!"
		IF EXIST "!GLOBAL_ENV_DIR!\!DEP_BASE!" (
			ECHO [%~n0] -- found location for dependency !DEP_BASE!: !GLOBAL_ENV_DIR!
			SET PATH=!PATH!;!GLOBAL_ENV_DIR!\!DEP_BASE!\!DEP_PART_HOME!\bin
			SET DEP_HOME=!GLOBAL_ENV_DIR!\!DEP_BASE!\!DEP_PART_HOME!
			ECHO DEP_HOME=!DEP_HOME!
			ECHO PATH=!PATH!
		) ELSE (
			ECHO [%~n0] -- found no location for dependency %%z: requiring checkout
			
			REM ---------------------------------------------------------------------------
			REM - checkout dependency
			REM ---------------------------------------------------------------------------
			ECHO [%~n0] checking out from accurev to %CHECKOUT_DIR% ...
			mkdir %CHECKOUT_DIR%
			echo accurev pop -v %BOOTSTRAP_STREAM% -L %CHECKOUT_DIR% -R -O \.\bootstrap\!DEP_GROUP!\!DEP_BASE!
			call accurev pop -v %BOOTSTRAP_STREAM% -L %CHECKOUT_DIR% -R -O \.\bootstrap\!DEP_GROUP!\!DEP_BASE!

			IF NOT "_%ERRORLEVEL%_" == "_0_" (
			  ECHO.
			  ECHO [%~n0] ERROR: checkout dependency from scm failed.
			  ECHO [%~n0] NOTE: Check if you are logged into AccuRev server.
			  ECHO.
			  EXIT /B -1
			)


			REM ---------------------------------------------------------------------------
			REM - copy checkedout dependency to global env dir
			REM ---------------------------------------------------------------------------
			IF NOT "%GLOBAL_ENV_DIR%" == "" (
				ECHO [%~n0] moving checkout to %GLOBAL_ENV_DIR%\!DEP_BASE!
				echo xcopy /y /e /i %CHECKOUT_DIR%\bootstrap\!DEP_GROUP!\!DEP_BASE! %GLOBAL_ENV_DIR%\!DEP_BASE!
				xcopy /y /e /i %CHECKOUT_DIR%\bootstrap\!DEP_GROUP!\!DEP_BASE! %GLOBAL_ENV_DIR%\!DEP_BASE!

				IF NOT "_%ERRORLEVEL%_" == "_0_" (
				  ECHO.
				  ECHO [%~n0] ERROR: moving dependency rom checkout folder failed.
				  ECHO.
				  EXIT /B -1
				)

				
				REM ---------------------------------------------------------------------------
				REM - extract 7z / zip packs if applicable when found in bootstrap
				REM ---------------------------------------------------------------------------
				ECHO [%~n0] extracting dependency at %BOOTSTRAP_DIR%\!DEP_BASE! ...
				
				FOR %%x IN (%GLOBAL_ENV_DIR%\!DEP_BASE!\!DEP_BASE!.zip) DO (
					ECHO.
					ECHO [%~n0] --------------------------------------------------------------------------------
					ECHO [%~n0] extracting from %%x ...
					ECHO.
					echo CALL %BOOTSTRAP_DIR%\%BOOTSTRAP_NAME%\7za.exe x -o%GLOBAL_ENV_DIR%\!DEP_BASE! -y %%x
					CALL %BOOTSTRAP_DIR%\%BOOTSTRAP_NAME%\7za.exe x -o%GLOBAL_ENV_DIR%\!DEP_BASE! -y %%x
					
					ECHO ERRORLEVEL=!ERRORLEVEL!
					SET /A szErrorCode=!ERRORLEVEL!
					ECHO szErrorCode=!szErrorCode!

					REM errorcheck
					IF NOT "_!szErrorCode!_" == "_0_" (
					  ECHO.
					  ECHO [%~n0] ERROR: failed to extract 7z / zip package with error code !szErrorCode! for zip %%x!
					  EXIT /B -1
					) 
                    
                    REM move subfolder with same name as tool one level up
                    IF EXIST %GLOBAL_ENV_DIR%\!DEP_BASE!\!DEP_BASE! (
                        XCOPY /E /Y %GLOBAL_ENV_DIR%\!DEP_BASE!\!DEP_BASE!\*.* %GLOBAL_ENV_DIR%\!DEP_BASE!
                        RMDIR /S /Q %GLOBAL_ENV_DIR%\!DEP_BASE!\!DEP_BASE!
                    )

					REM remove extracted package from disk (don't fail if cannot delete!)
					ECHO.
					ECHO [%~n0] removing 7z / zip pack %%x
					IF EXIST "%%x" (
						DEL %%x
					)
				)				
				
				SET PATH=!PATH!;!GLOBAL_ENV_DIR!\!DEP_BASE!\!DEP_PART_HOME!\bin
				SET DEP_HOME=!GLOBAL_ENV_DIR!\!DEP_BASE!\!DEP_PART_HOME!
				ECHO DEP_HOME=!DEP_HOME!
				ECHO PATH=!PATH!
				
			) ELSE (
			
				REM ---------------------------------------------------------------------------
				REM - copy checkedout dependency to env dir
				REM ---------------------------------------------------------------------------
				ECHO [%~n0] moving checkout to %BOOTSTRAP_DIR%\!DEP_BASE!
				echo xcopy /y /e /i %CHECKOUT_DIR%\bootstrap\!DEP_GROUP!\!DEP_BASE! %BOOTSTRAP_DIR%\!DEP_BASE!
				xcopy /y /e /i %CHECKOUT_DIR%\bootstrap\!DEP_GROUP!\!DEP_BASE! %BOOTSTRAP_DIR%\!DEP_BASE!

				IF NOT "_%ERRORLEVEL%_" == "_0_" (
				  ECHO.
				  ECHO [%~n0] ERROR: moving dependency rom checkout folder failed.
				  ECHO.
				  EXIT /B -1
				)

				
				

				
				REM ---------------------------------------------------------------------------
				REM - extract 7z / zip packs if applicable when found in bootstrap
				REM ---------------------------------------------------------------------------
				ECHO [%~n0] extracting dependency at %BOOTSTRAP_DIR%\!DEP_BASE! ...
				
				FOR %%x IN (%BOOTSTRAP_DIR%\!DEP_BASE!\!DEP_BASE!.zip) DO (
					ECHO.
					ECHO [%~n0] --------------------------------------------------------------------------------
					ECHO [%~n0] extracting from %%x ...
					ECHO.
					echo CALL %BOOTSTRAP_DIR%\%BOOTSTRAP_NAME%\7za.exe x -o%BOOTSTRAP_DIR%\!DEP_BASE! -y %%x
					CALL %BOOTSTRAP_DIR%\%BOOTSTRAP_NAME%\7za.exe x -o%BOOTSTRAP_DIR%\!DEP_BASE! -y %%x
					
					ECHO ERRORLEVEL=!ERRORLEVEL!
					SET /A szErrorCode=!ERRORLEVEL!
					ECHO szErrorCode=!szErrorCode!

					REM errorcheck
					IF NOT "_!szErrorCode!_" == "_0_" (
					  ECHO.
					  ECHO [%~n0] ERROR: failed to extract 7z / zip package with error code !szErrorCode! for zip %%x!
					  EXIT /B -1
					) 
                    
                    
                    REM move subfolder with same name as tool one level up
                    IF EXIST %BOOTSTRAP_DIR%\!DEP_BASE!\!DEP_BASE! (
                        XCOPY /E /Y %BOOTSTRAP_DIR%\!DEP_BASE!\!DEP_BASE!\*.* %BOOTSTRAP_DIR%\!DEP_BASE!
                        RMDIR /S /Q %BOOTSTRAP_DIR%\!DEP_BASE!\!DEP_BASE!
                    )


					REM remove extracted package from disk (don't fail if cannot delete!)
					ECHO.
					ECHO [%~n0] removing 7z / zip pack %%x
					IF EXIST "%%x" (
						DEL %%x
					)
				)

			SET PATH=!PATH!;!LOCAL_ENV_DIR!\!DEP_BASE!\!DEP_PART_HOME!\bin
			SET DEP_HOME=!LOCAL_ENV_DIR!\!DEP_BASE!\!DEP_PART_HOME!
			ECHO DEP_HOME=!DEP_HOME!
			ECHO PATH=!PATH!

			)
		)
	)
	
	echo DEP_GROUP=!DEP_GROUP!
	echo TOOL is  %%z
	
	IF "%%z" == "java" (
		echo DEP_HOME=!DEP_HOME!
		SET JAVA_HOME=!DEP_HOME!
		echo JAVA_HOME=!JAVA_HOME!
	)
)


REM ---------------------------------------------------------------------------
REM - starting SETLOCAL section - all changes from here will be not visible to
REM - callee
REM ---------------------------------------------------------------------------
REM SETLOCAL


REM ---------------------------------------------------------------------------
REM - prepare environment to call actual bootstrap code in xplatform language
REM ---------------------------------------------------------------------------
REM FOR /d %%f IN (%~dp0jdk-*) DO (SET JAVA_HOME=%%~ff)
REM ECHO JAVA_HOME=%JAVA_HOME%
REM FOR /d %%f IN (%~dp0groovy-*) DO (SET GROOVY_HOME=%%~ff)
REM ECHO GROOVY_HOME=%GROOVY_HOME%
REM SET PATH=%JAVA_HOME%\bin;%GROOVY_HOME%\bin;%PATH%
REM ECHO PATH=%PATH%

FOR %%f IN (%~dp0commons-lang-*.jar) DO (SET GROOVY_CLASSPATH=%%~ff)
ECHO GROOVY_CLASSPATH=%GROOVY_CLASSPATH%


REM ---------------------------------------------------------------------------
REM - delegate to groovy based toolstrapper
REM ---------------------------------------------------------------------------
ECHO [%~n0] CALL groovy -classpath %GROOVY_CLASSPATH% %~dp0Toolstrapper.groovy %*
CALL groovy -classpath %GROOVY_CLASSPATH% %~dp0Toolstrapper.groovy %*


REM ---------------------------------------------------------------------------
REM - error check 
REM ---------------------------------------------------------------------------
IF NOT "_%ERRORLEVEL%_" == "_0_" (
  ECHO [%~n0] ERROR: groovy %~dp0Toolstrapper.groovy %* failed.
  EXIT /B -1
)


REM ---------------------------------------------------------------------------
REM - delegate to generated genenv script
REM ---------------------------------------------------------------------------
ENDLOCAL

:SETENV_OFFLINE_MODE
IF EXIST "%GENENV_SCRIPT%" (
	CALL "%GENENV_SCRIPT%"
) ELSE (
	ECHO [%~n0] WARNING: NO GENENV SCRIPT at %GENENV_SCRIPT%
)


REM ---------------------------------------------------------------------------
REM - error check 
REM ---------------------------------------------------------------------------
IF NOT "_%ERRORLEVEL%_" == "_0_" (
  ECHO [toolstrap] ERROR: calling %GENENV_SCRIPT% failed.
  EXIT /B -1
)

REM end of toolstrapping
GOTO EOF
:EOF
