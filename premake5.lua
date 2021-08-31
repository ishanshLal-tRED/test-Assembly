-- Assembly Tests

boostDir = require("#Script.boostDir")
	
assembler = "masm"
externalrule "asm-prop"
	location (require("#Script.assemblerPropAndTarget")) -- optional; if the file lives somewhere other than the script folder
	filename (assembler)  -- optional; if the file has a name different than the rule
	fileextension ".asm" -- required; which files should be associated with the rule?
       
workspace "Assembly-Testing"
    startproject "testMain"

    configurations
    {
        "Debug",
        "Release"
    }
    
    platforms 
    {
        "32-bit",
        "64-bit"
    }

    flags
    {
        "MultiProcessorCompile"
    }
    
    filter "platforms:32-bit"
        architecture "x32" -- or x86
    
    filter "platforms:64-bit"
        architecture "x64"

outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

-- Include directories relative to solution
IncludeDir = {}
--IncludeDir["Glad"]      = "~vendor/glad-OpenGL_4.4/include"

-- Projects
group "Dependencies"
    -- include [prj.path]
    --include "~vendor/glad-OpenGL_4.4" -- includeexternal for upcoming workspace/solutions so that it dosen't needs to recompile
group ""

include "testMain" -- includeexternal for upcoming workspace/solutions
include "testAsmFunc"