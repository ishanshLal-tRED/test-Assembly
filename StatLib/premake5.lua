-- StatLib
project "StatLib"
	kind "StaticLib"
	language "C++"
	cppdialect "C++20"
	staticruntime "on"

	targetdir ("../builds/bin/" .. outputdir .. "/%{prj.name}")
	objdir ("../builds/bin-int/" .. outputdir .. "/%{prj.name}")
	
	rules {"asm-prop"}

	files
	{
		"src/**.asm",
		"src/**.h",
		"src/**.cpp"
	}
    
	includedirs
	{
        "./src",
        "../~vendor"
	}
	
	filter "system:windows"
		systemversion "latest"
		
	filter "configurations:Debug"
		defines {
            "_MODE_DEBUG",
            "_ENABLE_STACK_TRACING",
            "_ENABLE_ASSERTS"
        }
		runtime "Debug"
		symbols "on"

	filter "configurations:Release"
		defines {
            "_MODE_RELEASE",
            "_ENABLE_ASSERTS",
			"_SAVE_LOGS"
        }
		runtime "Release"
		optimize "on"

	filter {"configurations:Release", "system:windows"}
		linkoptions ' /SUBSYSTEM:WINDOWS'
	filter {"architecture:x32"}
		defines "_MODE_X86"
	filter {"architecture:x64"}
		defines "_MODE_X64"