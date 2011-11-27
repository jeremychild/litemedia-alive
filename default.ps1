# The tools version of msbuild
$framework = '4.0'

properties {
	$configuration = 'Debug'
	
	# Current working directory
	$cwd = [System.IO.Directory]::GetCurrentDirectory() + '\'
	
	# Tools
	$exe_ilmerge = $cwd + 'source\packages\ilmerge.2.10.526.4\ilmerge.exe'
	$exe_zip = 'source\packages\7z\7z.exe'
	
	# Paths
	$sys_net4 = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319'
	$sys_publicAsm = 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\PublicAssemblies'
	
	# Directories we use for the build
	$dir_build = $cwd + 'Build\'
	$dir_compile = $dir_build + 'Compile\'
	$dir_test = $dir_build + 'Test\'
	$dir_package = $dir_build + 'Package\'
	
	# x86
	$dir_compile_x86 = $dir_compile + 'x86\'
	$dir_compile_x86_v2 = $dir_compile_x86 + 'net20\'
	$dir_compile_x86_v4 = $dir_compile_x86 + 'v4\'
	$dir_package_x86 = $dir_package + 'x86\'
	$dir_package_x86_v2 = $dir_package_x86 + 'Alive-0.1-net20\'
	$dir_package_x86_v2_bin = $dir_package_x86_v2 + 'bin\'
	$dir_package_x86_v2_zip = $dir_package_x86 + 'Alive-0.1-x86-net20.zip'
	$dir_package_x86_v4 = $dir_package_x86 + 'Alive-0.1-net4\'
	$dir_package_x86_v4_bin = $dir_package_x86_v4 + 'bin\'
	$dir_package_x86_v4_zip = $dir_package_x86 + 'Alive-0.1-x86-net4.zip'
	
	# x64
	
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
	md $dir_compile_x86
	md $dir_compile_x86_v2
	md $dir_compile_x86_v4
	md $dir_package
	md $dir_package_x86
	md $dir_package_x86_v2
	md $dir_package_x86_v2_bin
	md $dir_package_x86_v4
	md $dir_package_x86_v4_bin
	
	md $dir_test
}

# Compile the project
task Compile -depends Clean {

	# x86
	# Compile .NET version 2.0
	exec { msbuild $lib_fsproj_v2 /p:OutputPath="$dir_compile_x86_v2" /p:SolutionDir="$dir_source" }	

	# Compile .NET version 4.0
	exec { msbuild $lib_fsproj_v4 /verbosity:minimal /p:Configuration="$configuration" /p:Platform="Any CPU" /p:OutDir="$dir_compile_x86_v4" /p:OutputPath="$dir_compile_x86_v4" /p:SolutionDir="$dir_source" }	
}

task Package -depends Compile {

	# x86
	# Package version 2.0
	exec { &$exe_ilmerge /t:dll /out:"$dir_package_x86_v2\bin\Alive.dll" "$dir_compile_x86_v2\Alive.dll" "$dir_compile_x86_v2\FSharp.Core.dll" }
	Copy-Item "Documentation\*" "$dir_package_x86_v2" -recurse
	exec { &$exe_zip a -tzip "$dir_package_x86_v2_zip" "$dir_package_x86_v2"  }
	
	# Package version 4
	exec { &$exe_ilmerge /lib:"$sys_net4" /lib:"$sys_publicAsm" /t:dll /targetplatform:"v4,$sys_net4" /out:"$dir_package_x86_v4\bin\Alive.dll" "$dir_compile_x86_v4\Alive.dll" "$dir_compile_x86_v4\FSharp.Core.dll" }
	Copy-Item "Documentation\*" "$dir_package_x86_v4" -recurse
	exec { &$exe_zip a -tzip "$dir_package_x86_v4_zip" "$dir_package_x86_v4"  }
}