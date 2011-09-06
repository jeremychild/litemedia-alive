# The tools version of msbuild
$framework = '4.0'

properties {
	$configuration = 'Debug'
	
	# Current working directory
	$cwd = [System.IO.Directory]::GetCurrentDirectory() + '\'
	
	# Tools
	$exe_ilmerge = $cwd + 'source\packages\ilmerge.2.10.526.4\ilmerge.exe'
	
	# Paths
	$sys_net4 = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319'
	$sys_publicAsm = 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\PublicAssemblies'
	
	# Directories we use for the build
	$dir_build = $cwd + 'Build\'
	$dir_compile = $dir_build + 'Compile\'
	$dir_compile_v2 = $dir_compile + 'v2.0\'
	$dir_compile_v4 = $dir_compile + 'v4\'
	$dir_package = $dir_build + 'Package\'
	$dir_package_v2 = $dir_package + 'v2.0\'
	$dir_package_v4 = $dir_package + 'v4\'
	$dir_test = $dir_build + 'Test\'
	
	# Source directories
	$dir_source = $cwd + 'Source\'
	$dir_lib = $dir_source + 'main\LiteMedia.Alive\'
	
	# Project files
	$lib_fsproj_v2 = $dir_lib + 'LiteMedia.Alive (v2.0).fsproj'
	$lib_fsproj_v4 = $dir_lib + 'LiteMedia.Alive (v4.0).fsproj'
}

task default -depends Compile

task Clean {
	# If build dir exists, delete it
	if (Test-Path $dir_build) {
		rd $dir_build -Recurse -Force
	}
	
	# Recreate build target directories
	md $dir_build 
	md $dir_compile
	md $dir_compile_v2
	md $dir_compile_v4
	md $dir_package
	md $dir_package_v2
	md $dir_package_v4
	
	md $dir_test
}

# Compile the project
task Compile -depends Clean {
	exec { msbuild $lib_fsproj_v2 /p:OutputPath="$dir_compile_v2" /p:SolutionDir="$dir_source" }	

	exec { msbuild $lib_fsproj_v4 /verbosity:minimal /p:Configuration="$configuration" /p:Platform="Any CPU" /p:OutDir="$dir_compile_v4" /p:OutputPath="$dir_compile_v4" /p:SolutionDir="$dir_source" }	
}

task Package -depends Compile {
	#exec { &$exe_ilmerge /lib:"$sys_net4" /lib:"$sys_publicAsm" /t:dll /targetplatform:"v4,$sys_net4" /out:"$dir_package_v4\LiteMedia.Alive.dll" "$dir_compile_v4\LiteMedia.Alive.dll" "$dir_compile_v4\FSharp.Core.dll" }
}