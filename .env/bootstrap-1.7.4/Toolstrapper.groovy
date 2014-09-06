import java.util.Date;
import java.text.SimpleDateFormat;


class Toolstrapper {
	// helper to ease x-platform handling
	private ant = new AntBuilder();
	
	// local environment to checkout tools not meant for sharing across specific project/build
	private localEnvDir  = System.getenv("LOCAL_ENV_DIR");
	
	// global environment to checkout tools to that should be shared across project/build specific tools
	private globalEnvDir = localEnvDir;
	
	private String accurevServer;
	private String accurevPort;
	
	private Binding binding;

	// scm stream to pull tools from
	private stream = "BootstrapRepository";
	
	// root checkout folder to temporarily host scm checkouts at
	private checkoutDir = System.properties["java.io.tmpdir"] + System.properties["file.separator"];
	
	// date format
	private dateFormat = new SimpleDateFormat("yyyyMMdd HHmmss");

	// resync by default off
        private boolean isResync = false;
	
	
	// main entry point for Toolstrapper
	public static void main(String[] args ) {
		// log env
		assert System.getenv("LOCAL_ENV_DIR") != null;

		// new toolstrapper
		def toolstrapper = new Toolstrapper();

		// print usage if too little arguments used
		if(args.length < 1) {
			toolstrapper.usage();
			return;
		}

		if(args.length >= 3) {
			if("resync".equalsIgnoreCase(args[2])) {
				toolstrapper.setResync(true);
                        }
                }
		
		// start bootstrapping of tools, assuming first argument is the bootstrap.properties file
		toolstrapper.toolstrapFile(new File(args[0]));		
	}	
	
	
	// prints usage
	public static void usage() {
		println "[usage] groovy Toolstrapper <path-to-bootstrap-properties-file>";
	}
	
	
	public Toolstrapper() {
		def globalEnvDir = System.getenv("GLOBAL_ENV_DIR");
		
		if(globalEnvDir != null) {
			ant.mkdir(dir:new File(globalEnvDir).getAbsolutePath());
			
			if(new File(globalEnvDir).exists()) {
			  this.globalEnvDir = globalEnvDir;
			}
		}
		
		println "localEnvDir=${localEnvDir}";
		println "globalEnvDir=${globalEnvDir}";
		
		
		def accurevServer = System.getenv("ACCUREV_SERVER_HOST");
		def accurevPort = System.getenv("ACCUREV_SERVER_PORT");
		
		if(!accurevPort) {
			accurevPort = "5050";
		}
		
		//assert System.getenv("ACCUREV_SERVER_HOST") != null;
		//assert System.getenv("ACCUREV_SERVER_PORT") != null;
		
		this.accurevServer = accurevServer;
		this.accurevPort = accurevPort;
		
		binding = new Binding();
		binding.setVariable("env", System.getProperties());
		binding.setVariable("SystemUtils", new org.apache.commons.lang.SystemUtils());
	}
	
	
	// bootstrap the tools listed in the given bootstrap properties file
	public void toolstrapFile(File toolstrapFile) {
		// precondition: file is not null and has to exist
		assert toolstrapFile != null
		assert toolstrapFile.isFile()
		
		// clean up some genenv script(s) from previous build/toolstrap (genenv.bat, genenv.sh, etc.)
		log("toolstrap", "clean up: genenv.bat");
		ant.delete(file:new File(localEnvDir, "genenv.bat").getAbsolutePath());
		log("toolstrap", "clean up: genenv.sh");
		ant.delete(file:new File(localEnvDir, "genenv.sh").getAbsolutePath());
		
		// process each line of the bootstrap properties file
		def lines = toolstrapFile.readLines();
		def condition = null;
		def allowConditionStart = true;
		def expectScopeStart = false;
		def expectScopeEnd = false;
		
		for( line in lines ) {
			line = line.trim();

			if(line == null || line.length() == 0) {
				continue;
			}
			
			if(line.startsWith("//")){
				log("comment", line);
				continue;
			}
			
			log("line", line);
			
			if(allowConditionStart) {
				log("allowConditionStart", "");
			
				if(line.startsWith("[")){
					log("allowConditionStart", "[");
					condition = parseCondition(line);
					allowConditionStart = false;
					expectScopeStart = true;
					line = line.substring(line.indexOf("]")+1).trim();
					log("allowConditionStart", "line:=${line}");
				}
			}
			
			if(expectScopeStart) {
				log("expectScopeStart", "");
				
				if(line.startsWith("{")) {
					log("expectScopeStart", "{");
					
					expectScopeEnd = true;
					expectScopeStart = false;
					line = line.substring(line.indexOf("{")+1).trim();
					log("expectScopeStart", "line:=${line}");
				} else {
					//continue;
				}
			}
			
			if(line.length() == 0){
				continue;
			}
			
			if(expectScopeEnd) {
				log("expectScopeEnd", "");
				if(line.endsWith("}")) {
					log("expectScopeEnd", "}");
					line = line.substring(0, line.lastIndexOf("}")).trim();
					log("expectScopeEnd", "line:=${line}");

					if(line != null && line.length() > 0) {
						if(isConditionTrue(condition)){
							toolstrap(line);
						}
					}
					
					expectScopeEnd = false;
					allowConditionStart = true;
					condition = null;
					continue;
				}
			}
			
			if(isConditionTrue(condition)){
				toolstrap(line);
			}
			
			if(expectScopeStart) {
				expectScopeStart = false;
				allowConditionStart = true;
				condition = null;
			}
		}
	}
	
	
	private boolean isConditionTrue(String condition) {
		if(condition == null || condition.length() == 0){
			return true;
		}
		
		log("isConditionTrue", condition);
		
		GroovyShell shell = new GroovyShell(binding);
		
		Object value = shell.evaluate("" + condition);
		
		if(value == null) {
			log("isConditionTrue", "value is null");
			return false;
		}
		
		log("isConditionTrue", "value is ${value}");

		return value == true;
	}
	
	private String parseCondition(String str) {
		def start = str.indexOf("[");
		def end = str.lastIndexOf("]");
		def condition = str.substring(start+1, end);
		
		log("parseCondition", condition);
		
		return condition;
	}
	
	
	// customized logger method to log out as [prefix] msg
	private void log(String prefix, String msg) {
		println "[${prefix}] ${msg}";
	}
	
	private String normalize(String path) {
		return path.replaceAll("\\\\", "/");
	}
	
	
	// bootstrap the given tool
	private void toolstrap(String tool) {
		// precondition: tool must not be null
		assert tool != null
		
		// log out each tool to bootstrap
		log("toolstrap", tool);
		

		// determine the envdir - local or global
		def envDir;
		
		if(isLocalTool(tool)){
			envDir = localEnvDir;
		} else {
			envDir = globalEnvDir;
		}
		
		// log out env dir for the given tool
		log("toolstrap", "envDir=${envDir}");

        
		// normalize separtors in the tool
		def baseName = new File(tool.replace("\\", "/")).getName();
		
		// log out
		log("toolstrap", "baseName=${baseName}");


		// checkout tool if required
		if( needsCheckout(tool, baseName, envDir)) {
			// log out
			log("toolstrap", "checkout for ${baseName} required ...");
			
			// check out tool
			checkout(tool, baseName, envDir);
		} else {
			// path to tool on disk
			def tooldir = new File(envDir, new File(baseName).getName());

   			// timestamp normalized to date format
			def now = dateFormat.format(new Date());
			
			// mark tool on disk to be checked for changes that require a re-checkout at now 
			ant.echo(file:new File(tooldir,"timestamp.log").getAbsolutePath(), message:now);
        }		
		
		
		// add a bootstrap entry to the genenv script
		addBootstrap(tool, baseName, new File(localEnvDir).getAbsolutePath(), envDir);
	}


	// add tool to genenv script
	private void addBootstrap(String tool, String baseName, String script, String envDir) {
	  addBootstrapWin(tool, baseName, script + "/genenv.bat", envDir);
	  addBootstrapNonWin(tool, baseName, script + "/genenv.sh", envDir);
	}
	
	
	// add tool to genenv script for windows
	private void addBootstrapWin(String tool, String baseName, String script, String envDir) {
		def toolName = baseName;
		def scr = """${envDir}/${toolName}/bootstrap.bat""";

		def call = """
		REM bootstrap ${toolName}
		ECHO [genenv] tool ${toolName}
			IF EXIST ${scr} (
				echo [genenv] found ${scr}
				call ${scr}
				
				REM error check
				IF NOT %ERRORLEVEL% == 0 (
				  echo [genenv] ERROR: failed to execute bootstrap script for tool ${tool}
                  exit /b -1
				)
			)
		""";
		
		log("addBootstrap", tool);

		ant.echo(file:script, message:call, append:true);
	}
	
	
	// add tool to genenv script for non windows
	private void addBootstrapNonWin(String tool, String baseName, String script, String envDir) {
		def toolName = baseName;
		def scr = """${envDir}/${toolName}/bootstrap.sh""";

		def call = """
		#!/bin/bash
		# bootstrap ${toolName}
		echo [genenv] tool ${toolName}
              if [ -f ${scr} ]; then
				echo found ${scr}
                chmod 755 ${scr}
				echo sourcing ${scr}
                . ${scr} ${scr}		  
              
                # error check
				if [ ! "\$?" = "0" ]; then
                  echo [genenv] ERROR: failed to execute bootstrap script for tool ${tool}
                  exit -1
                fi
              fi
		""";
		
		log("addBootstrap", tool);

		ant.echo(file:script, message:call, append:true);
	}


        // check if resync is set
	public boolean isResync() {
                return this.isResync;
        }
	
        // check if resync is set
	public void setResync(boolean resync) {
                this.isResync = resync;
        }
	
	// determine if given tool is local
	private boolean isLocalTool(String tool) {
		// tool is local if version number ends in "-snapshot" to indicate work-in-progress
		return tool.toLowerCase().endsWith("-snapshot");
	}
	
	
	private boolean checkout(String tool, String baseName, String envDir) {
		// log clearing
		log("checkout", "clear existing tool ${baseName} at ${envDir} ...");
		
		// cleanup old installation of tool at target location
		def tooldir = new File(envDir, new File(baseName).getName());
		ant.delete(dir:tooldir.getAbsolutePath());

		
		// random unique checkout folder
		def outdir = "${checkoutDir}${Math.random()}";
		
		// ensure target folder exists
		ant.mkdir(dir:outdir);
		

		// populate from accurev
		if(accurevServer) {
			Accurev.execute("accurev pop -H ${accurevServer}:${accurevPort} -v ${stream} -L ${outdir} -R -O \\.\\${tool}", null);
		} else {
			Accurev.execute("accurev pop -v ${stream} -L ${outdir} -R -O \\.\\${tool}", null);
		}
		

		// copy from checkout folder to target folder
		log("checkout", "copy from ${outdir} to ${tooldir}");
		
		ant.copy(todir:tooldir, verbose:true){
			fileset(dir:new File(outdir,tool).getAbsolutePath()){
				include(name:"**/*.*")
				include(name:"**/*")
			}
		}
		
		// generate timestamp file
		def now = dateFormat.format(new Date());
		ant.echo(file:new File(tooldir,"timestamp.log").getAbsolutePath(), message:now);
		
		
		// clean up checkout folder
		log("checkout", "remove intermediate checkout dir");
		
		ant.delete(dir:outdir);
		
		
		// unzip any zip containers available
		log("checkout", "unzip tools");
		
		// since bootstrap 1.7.3 - unzip in-place instead of to parent folder
        ant.unzip(dest:tooldir) {
			fileset(dir:tooldir){
				include(name:"*.zip")
                exclude(name:"*-sources.zip")
			}
		}
        
        
		// since bootstrap 1.7.3 - due to above (unzip in-place) move content of folder with same name as tool one level higher and remove empty folder
        if(new File(tooldir,baseName).exists()){
            ant.move(todir:tooldir, verbose:true){
                fileset(dir:new File(tooldir,baseName).getAbsolutePath()){
                    include(name:"**/*.*")
                    include(name:"**/*")
                }
            }

            // since bootstrap 1.7.3 - due to above, remove now empty subfolder with same name as tool
            ant.delete(dir:new File(tooldir,baseName).getAbsolutePath());
        }
        
		
		
		// clean up zip containers (no longer needed as they are unzipped by now)
		ant.delete() {
			fileset(dir:tooldir){
				include(name:"*.zip")
				include(name:"*.7z")
                exclude(name:"*-sources.zip")
			}
		}
	}
	
	
	// determines if tools needs checkout
	private boolean needsCheckout(String tool, String baseName, String envDir) {
		// precondition
		assert tool != null
		
		// if resync tools always require a checkout
		log("needsCheckout", "check if resnyc is enabled");
		
		if(isResync()){
			// log
			log("needsCheckout", "tool ${tool} needs a fresh checkout because resync is enabled");
			
			return true;
		}
		
		// local tool will always require a checkout
		log("needsCheckout", "check if tool is local");
		
		if(isLocalTool(baseName)){
			// log
			log("needsCheckout", "tool ${tool} is local and needs a fresh checkout");
			
			return true;
		}
		
		
		// non-local tools will be default envDir; compute tool dir from default env dir
		def tooldir = new File(envDir, new File(baseName).getName());
		
		// log out tool location
		log("needsCheckout", "tooldir=${tooldir.toString()}");

		// needs checkout if target dir does not yet exist
		if(!tooldir.exists()) {
			return true;
		}
		
		
		// precondition: target dir has to be a directory
		assert tooldir.isDirectory()
		
		
		// random unique checkout folder
		def outdir = "${checkoutDir}${Math.random()}";
		
		// ensure target folder exists
		ant.mkdir(dir:outdir);
		
		try{

			def checksumFileExists = true;
			
			def errhandler = { cmd, process, sout, serr ->
				if(process.exitValue() != 0) {
					log("needsCheckout", "WARNING: accurev call ${cmd} failed.");
					log("needsCheckout", "WARNING: ${sout.toString()}");
					log("needsCheckout", "WARNING: ${serr.toString()}");
					
					log("needsCheckout", "WARNING: tool ${tool} is missing the 'checksum' file. will treat as requiring a fresh checkout for ${tool}.");
					
					checksumFileExists = false;
				} else {
					log("needsCheckout", "INFO: found checksum for tool ${tool}.");

					checksumFileExists = true;
				}
			}
			
			// populate from accurev
			if(accurevServer) {
				Accurev.execute("accurev pop -H ${accurevServer}:${accurevPort} -v ${stream} -L ${outdir} -O \\.\\${tool}\\checksum.SHA-512", errhandler);
			} else {
				Accurev.execute("accurev pop -v ${stream} -L ${outdir} -O \\.\\${tool}\\checksum.SHA-512", errhandler);
			}
			
			
			
			// assumed checksum file of checkout
			def checkoutChecksumFile = new File( new File("${outdir}", normalize("${tool}")), "checksum.SHA-512");
			
			// log out checkoutChecksumFile checkout location
			log("needsCheckout", "checkoutChecksumFile=${checkoutChecksumFile}");
			
			// needs checkout if checkoutChecksumFile does not exist at checkout
			if(!checkoutChecksumFile.exists()) {
				return true;
			}
			
			// precondition: checkoutChecksumFile needs to be a file
			assert checkoutChecksumFile.isFile();


			// assumed checksum file of ttarget location
			def envChecksumFile = new File(normalize("${tooldir}"), "checksum.SHA-512");
			
			// log out checksum target location
			log("needsCheckout", "envChecksumFile=${envChecksumFile}");
			
			// needs checkout if checksum target does not exist at target location
			if(!envChecksumFile.exists()) {
				return true;
			}
			
			// precondition: checksum needs to be a file
			assert envChecksumFile.isFile();
			
			
			// checksum content
			def checkoutChecksum;
			
			checkoutChecksumFile.withReader{ reader ->
				checkoutChecksum = reader.readLine();
			}
			
			// log
			log("needsCheckout", "checkoutChecksum=${checkoutChecksum}");
			
			
			// checksum value
			def envChecksum;
			
			envChecksumFile.withReader{ reader ->
				envChecksum = reader.readLine();
			}

			// log
			log("needsCheckout", "envChecksum=${envChecksum}");
			
			
			// check checksums to be similar or not
			if(checkoutChecksum.compareTo(envChecksum) != 0 ) {
				// checkout needed
				return true;
			} else {
				return false;
			}

		} finally {
		
			// clean up checkout folder
			log("checkout", "remove intermediate checkout dir");
			
			ant.delete(dir:outdir);
		}

		// no checkout needed
		return false;		
	}
	
	
	private boolean hasChangesInHistory(String tool, String timestamp) {
		
		log("hasChangesInHistory", "checking for changes on ${tool} since ${timestamp}");
		
		def cmdline = ["accurev", "hist", "-H", "${accurevServer}:${accurevPort}", "-s", "${stream}", "-t", "${timestamp}-now"] as String[];
		
		log("hasChangesInHistory", "accurev call ${cmdline}");

              def env = [];

              System.getenv().each{ key, value ->
                env.add("${key}=${value}");
              }		

              log("hasChangesInHistory", "env=${env}");


		def sout = new StringBuffer()
		def serr = new StringBuffer()
              def dirFile = new File(".");
		def process = Runtime.exec(cmdline as String[], env as String[]);
		process.consumeProcessOutput(sout, serr)
		
		process.waitFor();
		
		if(process.exitValue()) {
			log("hasChangesInHistory", "ERROR: accurev call ${cmdline} failed.");
			log("hasChangesInHistory", "ERROR: ${sout.toString()}");
			log("hasChangesInHistory", "ERROR: ${serr.toString()}");
			//assert !process.exitValue()
		}
		
		def hit;
		def queryString = "/./" + tool.replaceAll("\\\\", "/");
		log("hasChangesInHistory", "queryString=${queryString}");
		sout.toString().eachLine{ line ->
		  if( line.contains(queryString)) {
		    hit = line;
			return;
		  }
		}
		
		println("hit=${hit}");
		
		if(hit != null) {
		  return true;
		}
		
		return false;
	}
	
	private String formatTimestampToAccurev(String timestamp) {
		assert timestamp != null
		
		def matcher = timestamp =~ /(\d{4})(\d{2})(\d{2}) (\d{2})(\d{2})(\d{2})/
		
		if(! matcher) {
		  return null;
		}
		
		assert matcher != null
		assert matcher.size() > 0
		assert matcher[0] != null
		assert matcher[0].size() == 1 + 6
		
		def year = matcher[0][1];
		def month = matcher[0][2];
		def day = matcher[0][3];
		
		def hour = matcher[0][4];
		def min = matcher[0][5];
		def sec = matcher[0][6];
		
		def accurevTimestamp = "${year}/${month}/${day} ${hour}:${min}:${sec}";
		
		log("formatTimestampToAccurev", "accurev timestamp is ${accurevTimestamp}");
		
		return accurevTimestamp;
	}
}



class Accurev {

	// logger
	private static void log(String prefix, String msg) {
		println "[${prefix}] ${msg}";
	}


	// execute accurev command
	public static StringBuffer execute(String cmd, Closure closure) {

		// stdout and stderr buffers
		def sout = new StringBuffer();
		def serr = new StringBuffer();
		
		
		// execute cmd
		def process = cmd.execute();
		
		
		// eat all that is coming from the buffers
		process.consumeProcessOutput(sout, serr)
		
		
		// wait for process to finish
		process.waitFor();
		
		
		// process exited normally?
		if(closure == null) {
			if(process.exitValue()) {
				log("accurev", "ERROR: accurev call ${cmd} failed.");
				log("accurev", "ERROR: ${sout.toString()}");
				log("accurev", "ERROR: ${serr.toString()}");
				
				assert false;
			}
		} else {
			closure(cmd, process, sout, serr);
		}
		
		
		// deliver process output
		return sout;
	}
}