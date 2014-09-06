#!/bin/bash

# ---------------------------------------------------------------------------
# - check BOOTSTRAP_DIR
# ---------------------------------------------------------------------------
if [ "$BOOTSTRAP_DIR" = "" ]; then
  echo [toolstrap] ERROR: environment variable BOOTSTRAP_DIR is not set.
  exit -1
fi


# ---------------------------------------------------------------------------
# - check BOOTSTRAP_NAME
# ---------------------------------------------------------------------------
if [ "$BOOTSTRAP_NAME" = "" ]; then
  echo [bootstrap.sh] ERROR: environment variable BOOTSTRAP_NAME is not set.
  exit -1
fi


# ---------------------------------------------------------------------------
# - checking cmd args
# ---------------------------------------------------------------------------
echo [bootstrap.sh] CMD ARGS=$*
BOOTSTRAP_PROPERTIES=$1
CALLER_LOCATION=$2
SETENV_OFFLINE_MODE=$3



# ---------------------------------------------------------------------------
# - check BOOTSTRAP_PROPERTIES
# ---------------------------------------------------------------------------
if [ "$BOOTSTRAP_PROPERTIES" = "" ]; then
  echo [bootstrap.sh] ERROR: cmd argument 1 for BOOTSTRAP_PROPERTIES is not set.
  exit -1
fi



# ---------------------------------------------------------------------------
# - check CALLER_LOCATION
# ---------------------------------------------------------------------------
if [ "$CALLER_LOCATION" = "" ]; then
  echo [bootstrap.sh] ERROR: cmd argument 2 for CALLER_LOCATION is not set.
  exit -1
fi



# ---------------------------------------------------------------------------
# - determine LOCAL_ENV_DIR
# ---------------------------------------------------------------------------
if [ "$LOCAL_ENV_DIR" = "" ]; then
	export LOCAL_ENV_DIR=$CALLER_LOCATION/.env
fi
echo [bootstrap.sh] LOCAL_ENV_DIR=$LOCAL_ENV_DIR
test -d $LOCAL_ENV_DIR || mkdir $LOCAL_ENV_DIR


	# ---------------------------------------------------------------------------
	# - checkout dependencies
	# ---------------------------------------------------------------------------

	if [ ! -d $BOOTSTRAP_DIR/groovy-2.0.0 ]; then
	
		test -d $CHECKOUT_DIR || mkdir $CHECKOUT_DIR
                echo [-]
		echo [bootstrap] --------------------------------------------------------------------------------
		echo [bootstrap] checking out from accurev to $CHECKOUT_DIR ...
		echo
		accurev pop -v $BOOTSTRAP_STREAM -L $CHECKOUT_DIR -R -O /./bootstrap/groovy/groovy-2.0.0

		if [ ! "$?" = "0" ]; then
		  echo ERROR [bootstrap] ERROR: Failed to accurev pop -v $BOOTSTRAP_STREAM -L $CHECKOUT_DIR -R -O /./bootstrap/groovy/groovy-2.0.0
		  exit -1
		fi
		
	
		echo
		echo [bootstrap] --------------------------------------------------------------------------------
		echo [bootstrap] moving checkout to $BOOTSTRAP_DIR/$BOOTSTRAP_NAME
		echo
		echo [bootstrap] cp -R $CHECKOUT_DIR/bootstrap/groovy/groovy-2.0.0 $BOOTSTRAP_DIR
		test -d $BOOTSTRAP_DIR/$BOOTSTRAP_NAME || mkdir $BOOTSTRAP_DIR/$BOOTSTRAP_NAME
		cp -R $CHECKOUT_DIR/bootstrap/groovy/groovy-2.0.0 $BOOTSTRAP_DIR

		if [ ! "$?" = "0" ]; then
		  echo ERROR: moving bootstrap code from checkout folder failed.
		  exit -1
		fi
		
		# ---------------------------------------------------------------------------
		# - extract 7z / zip packs if applicable found in bootstrap
		# ---------------------------------------------------------------------------
		FILESET=`ls $BOOTSTRAP_DIR/groovy-2.0.0/*.zip 2>/dev/null`
		echo [bootstrap.sh] FILESET=$FILESET

		for f in $FILESET; do
			echo f=$f
			echo ${f##*.}

			if [ "${f##*.}" = "zip" ]; then
				echo [bootstrap.sh] extracting from $f to $BOOTSTRAP_DIR ...
				unzip -o -d $BOOTSTRAP_DIR $f

				# errorcheck
				if [ ! "$?" = "0" ]; then
				  echo [bootstrap] ERROR: failed to extract zip package $f!
				  exit -1
				fi

				# remove extracted package from disk (don't fail if cannot delete!)
				echo [bootstrap] removing zip pack $f
				rm $f
			fi
		done
		echo done loop over FILESET
		
	
	# ---------------------------------------------------------------------------
	# - remove temp checkout folder
	# ---------------------------------------------------------------------------
	rm -f -R $CHECKOUT_DIR
	fi


	if [ "$JAVA_HOME" = "" ]; then
        if [ ! -d $BOOTSTRAP_DIR/OpenJDK-jdk-1.7u25_mac_x64 ]; then
        
            test -d $CHECKOUT_DIR || mkdir $CHECKOUT_DIR
            echo [-]
            echo [bootstrap] --------------------------------------------------------------------------------
            echo [bootstrap] checking out from accurev to $CHECKOUT_DIR ...
            echo
            accurev pop -v $BOOTSTRAP_STREAM -L $CHECKOUT_DIR -R -O /./bootstrap/OpenJDK/jdk/1.7u25/OpenJDK-jdk-1.7u25_mac_x64

            if [ ! "$?" = "0" ]; then
              echo ERROR [bootstrap] ERROR: Failed to accurev pop -v $BOOTSTRAP_STREAM -L $CHECKOUT_DIR -R -O /./bootstrap/OpenJDK/jdk/1.7u25/OpenJDK-jdk-1.7u25_mac_x64
              exit -1
            fi
            
        
            echo
            echo [bootstrap] --------------------------------------------------------------------------------
            echo [bootstrap] moving checkout to $BOOTSTRAP_DIR/$BOOTSTRAP_NAME
            echo
            echo [bootstrap] cp -R $CHECKOUT_DIR/bootstrap/OpenJDK/jdk/1.7u25/OpenJDK-jdk-1.7u25_mac_x64 $BOOTSTRAP_DIR
            test -d $BOOTSTRAP_DIR/$BOOTSTRAP_NAME || mkdir $BOOTSTRAP_DIR/$BOOTSTRAP_NAME
            cp -R $CHECKOUT_DIR/bootstrap/OpenJDK/jdk/1.7u25/OpenJDK-jdk-1.7u25_mac_x64 $BOOTSTRAP_DIR

            if [ ! "$?" = "0" ]; then
              echo ERROR: moving bootstrap code from checkout folder failed.
              exit -1
            fi
            
            # ---------------------------------------------------------------------------
            # - extract 7z / zip packs if applicable found in bootstrap
            # ---------------------------------------------------------------------------
            FILESET=`ls $BOOTSTRAP_DIR/OpenJDK-jdk-1.7u25_mac_x64/*.zip 2>/dev/null`
            echo [bootstrap.sh] FILESET=$FILESET

            for f in $FILESET; do
                echo f=$f
                echo ${f##*.}

                if [ "${f##*.}" = "zip" ]; then
                    echo [bootstrap.sh] extracting from $f to $BOOTSTRAP_DIR ...
                    unzip -o -d $BOOTSTRAP_DIR/OpenJDK-jdk-1.7u25_mac_x64 $f

                    # errorcheck
                    if [ ! "$?" = "0" ]; then
                      echo [bootstrap] ERROR: failed to extract zip package $f!
                      exit -1
                    fi

                    # remove extracted package from disk (don't fail if cannot delete!)
                    echo [bootstrap] removing zip pack $f
                    rm $f
                fi
            done
            echo done loop over FILESET
            
        
        # ---------------------------------------------------------------------------
        # - remove temp checkout folder
        # ---------------------------------------------------------------------------
        rm -f -R $CHECKOUT_DIR
        fi
     fi
	
# ---------------------------------------------------------------------------
# - extract 7z / zip packs if applicable found in bootstrap
# ---------------------------------------------------------------------------
FILESET=`ls $BOOTSTRAP_DIR/$BOOTSTRAP_NAME/*.zip 2>/dev/null`
echo [bootstrap.sh] FILESET=$FILESET

for f in $FILESET; do
    echo f=$f
    echo ${f##*.}

    if [ "${f##*.}" = "zip" ]; then
        echo [bootstrap.sh] extracting from $f to $BOOTSTRAP_DIR/$BOOTSTRAP_NAME ...
        unzip -o -d $BOOTSTRAP_DIR/$BOOTSTRAP_NAME $f

        # errorcheck
        if [ ! "$?" = "0" ]; then
          echo [bootstrap] ERROR: failed to extract zip package $f!
          exit -1
        fi

        # remove extracted package from disk (don't fail if cannot delete!)
        echo [bootstrap] removing zip pack $f
        rm $f
    fi
done
echo done loop over FILESET


# ---------------------------------------------------------------------------
# - set location of GENENV script 
# - (the script to generate the calls to the tool's bootstrap scripts in)
# ---------------------------------------------------------------------------
GENENV_SCRIPT=$LOCAL_ENV_DIR/genenv.sh
echo [bootstrap.sh] GENENV_SCRIPT=$GENENV_SCRIPT


# ---------------------------------------------------------------------------
# - if running in offline mode, skip the accurev part
# ---------------------------------------------------------------------------

echo [bootstrap.sh] SETENV_OFFLINE_MODE=$SETENV_OFFLINE_MODE
if [ ! "__$SETENV_OFFLINE_MODE__" = "__--offline__" ]; then


	# ---------------------------------------------------------------------------
	# - remove GENENV script 
	# - (the script to generate the calls to the tool's bootstrap scripts in)
	# ---------------------------------------------------------------------------
	# delete previously generated genenv script (if applicable)
	test -e $GENENV_SCRIPT && rm $GENENV_SCRIPT


	# ---------------------------------------------------------------------------
	# - prepare environment to call actual bootstrap code in xplatform language
	# ---------------------------------------------------------------------------
	GROOVY_HOME=`ls -d $BOOTSTRAP_DIR/groovy-2.0.0 | head -1`
	PATH=$GROOVY_HOME/bin:$PATH
	echo GROOVY_HOME=$GROOVY_HOME
	echo PATH=$PATH
    
	if [ "$JAVA_HOME" = "" ]; then
        JAVA_HOME=`ls -d $BOOTSTRAP_DIR/OpenJDK-jdk-1.7u25_mac_x64/jdk | head -1`
        PATH=$JAVA_HOME/bin:$PATH
        echo JAVA_HOME=$JAVA_HOME
        echo PATh=$PATH
    fi



    # ---------------------------------------------------------------------------
    # - chmod groovy scripts
    # ---------------------------------------------------------------------------
    FILESET=`ls $GROOVY_HOME/bin/*.*`
    echo [bootstrap.sh] FILESET=$FILESET

    for f in $FILESET; do
        echo f=$f
        echo ${f##*.}

        if [ "${f##*.}" = "" ]; then
            echo [bootstrap.sh] chmod +x for $f
            chmod +x $f

            # errorcheck
            if [ ! "$?" = "0" ]; then
              echo [bootstrap] ERROR: failed to chmod +x for $f
              exit -1
            fi
        fi
    done
    echo done loop over FILESET


	
	
	
	#chmod +x $GROOVY_HOME/bin/groovysh $GROOVY_HOME/bin/groovy $GROOVY_HOME/bin/grape $GROOVY_HOME/bin/java2groovy $GROOVY_HOME/bin/groovydoc $GROOVY_HOME/bin/startGroovy
	
	COMMONS_LANG_JAR=`ls $BOOTSTRAP_DIR/$BOOTSTRAP_NAME/commons-lang-*.jar | head -1`
	echo COMMONS_LANG_JAR=$COMMONS_LANG_JAR
	
	GROOVY_CLASSPATH=$COMMONS_LANG_JAR



	# ---------------------------------------------------------------------------
	# - delegate to groovy based toolstrapper
	# ---------------------------------------------------------------------------
	echo $GROOVY_HOME/bin/groovy -classpath $GROOVY_CLASSPATH $BOOTSTRAP_DIR/$BOOTSTRAP_NAME/Toolstrapper.groovy $*
	$GROOVY_HOME/bin/groovy -classpath $GROOVY_CLASSPATH $BOOTSTRAP_DIR/$BOOTSTRAP_NAME/Toolstrapper.groovy $*

	echo groovy call done

fi


# ---------------------------------------------------------------------------
# - delegate to genenv script
# ---------------------------------------------------------------------------
chmod 755 $GENENV_SCRIPT
if [ -f $GENENV_SCRIPT ]; then
	. $GENENV_SCRIPT
else
	echo no GENENV script to execute at $GENENV_SCRIPT
fi
