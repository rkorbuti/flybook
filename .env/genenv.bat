
		REM bootstrap apache-maven-2.2.1
		ECHO [genenv] tool apache-maven-2.2.1
			IF EXIST C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.bat (
				echo [genenv] found C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.bat
				call C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.bat
				
				REM error check
				IF NOT %ERRORLEVEL% == 0 (
				  echo [genenv] ERROR: failed to execute bootstrap script for tool bootstrap\apache-maven\apache-maven-2.2.1
                  exit /b -1
				)
			)
		
		REM bootstrap OpenJDK-jdk-1.7u40_win_x64
		ECHO [genenv] tool OpenJDK-jdk-1.7u40_win_x64
			IF EXIST C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.bat (
				echo [genenv] found C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.bat
				call C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.bat
				
				REM error check
				IF NOT %ERRORLEVEL% == 0 (
				  echo [genenv] ERROR: failed to execute bootstrap script for tool bootstrap\OpenJDK\jdk\1.7u40\OpenJDK-jdk-1.7u40_win_x64
                  exit /b -1
				)
			)
		
		REM bootstrap nodist-0.4.8
		ECHO [genenv] tool nodist-0.4.8
			IF EXIST C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.bat (
				echo [genenv] found C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.bat
				call C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.bat
				
				REM error check
				IF NOT %ERRORLEVEL% == 0 (
				  echo [genenv] ERROR: failed to execute bootstrap script for tool bootstrap\nodist\nodist-0.4.8
                  exit /b -1
				)
			)
		