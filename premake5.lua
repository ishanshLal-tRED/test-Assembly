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
include "ch02__03_4"
include "ch02__05_7"
include "ch03__01_4"
-- SKIPPED STRINGS
include "ch03__08_9"
-- Chapter 4 is theory based
include "ch05__01_4"
include "ch05__05_6"
include "ch05__09_12"
include "ch06__01_03"
include "ch06__04_06"
include "ch06__07_08"
include "ch07__01_03"
include "ch07__04_06"
include "ch07__07_08"
include "ch09__01_04"
include "ch09__05_06"
include "ch09__07_08"
include "ch10__01_03"
include "ch10__04_06"
include "ch11__01_02"