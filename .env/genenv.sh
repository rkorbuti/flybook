
		#!/bin/bash
		# bootstrap apache-maven-2.2.1
		echo [genenv] tool apache-maven-2.2.1
              if [ -f C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.sh ]; then
				echo found C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.sh
                chmod 755 C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.sh
				echo sourcing C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.sh
                . C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.sh C:\Users\roman.korbutiak\.env/apache-maven-2.2.1/bootstrap.sh		  
              
                # error check
				if [ ! "$?" = "0" ]; then
                  echo [genenv] ERROR: failed to execute bootstrap script for tool bootstrap\apache-maven\apache-maven-2.2.1
                  exit -1
                fi
              fi
		
		#!/bin/bash
		# bootstrap OpenJDK-jdk-1.7u40_win_x64
		echo [genenv] tool OpenJDK-jdk-1.7u40_win_x64
              if [ -f C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.sh ]; then
				echo found C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.sh
                chmod 755 C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.sh
				echo sourcing C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.sh
                . C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.sh C:\Users\roman.korbutiak\.env/OpenJDK-jdk-1.7u40_win_x64/bootstrap.sh		  
              
                # error check
				if [ ! "$?" = "0" ]; then
                  echo [genenv] ERROR: failed to execute bootstrap script for tool bootstrap\OpenJDK\jdk\1.7u40\OpenJDK-jdk-1.7u40_win_x64
                  exit -1
                fi
              fi
		
		#!/bin/bash
		# bootstrap nodist-0.4.8
		echo [genenv] tool nodist-0.4.8
              if [ -f C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.sh ]; then
				echo found C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.sh
                chmod 755 C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.sh
				echo sourcing C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.sh
                . C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.sh C:\Users\roman.korbutiak\.env/nodist-0.4.8/bootstrap.sh		  
              
                # error check
				if [ ! "$?" = "0" ]; then
                  echo [genenv] ERROR: failed to execute bootstrap script for tool bootstrap\nodist\nodist-0.4.8
                  exit -1
                fi
              fi
		