CHANGE HISTORY
==============
Changes introduced by 1.7.4-snapshot:
* change to use openjdk internally for the bootstrapping

Changes introduced by 1.7.3:
* support tool zips that do not have tool's name as root folder inside

Changes introduced by 1.7.2:
* bootstrap.sh will allow comments in bootstrap.properties files when line starts with //

Changes introduced by 1.7.1:
* bootstrap.sh will suppress a few "No such file" outputs so the TREX build output checker does not bark.

Changes introduced by 1.7.0:
* Toolstrapper.groovy uses the new stream "BootstrapRepository"

Changes introduced by 1.4.2:
* bootstrap.bat/.sh understands third option to be "--offline" to skip all accurev stuff

Changes introduced by 1.4.1:
* LOCAL_ENV_DIR is not re-defined explicitly, if it is set

Changes introduced by 1.4.0:
* groovy based toolstrapping

Changes Since 1.2.0:
* added error handling
* now also supporting zip for tools (in addition to 7z)

Changes Since 1.1.0:
* not documented

Changes Since 1.0.0:
* moved global env dir to C:\shared-env
* moved local env to components\env
