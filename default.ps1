# The tools version of msbuild
$framework = '4.0'

properties {
	$configuration = 'Debug'
	
	# Current working directory
	$cwd = [System.IO.Directory]::GetCurrentDirectory() + '\'
	
	# Tools
	$exe_msbuild_x86 = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
	$exe_msbuild_x64 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe"
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
	$dir_compile_x86_v4 = $dir_compile_x86 + 'net4\'
	$dir_package_x86 = $dir_package + 'x86\'
	$dir_package_x86_v2 = $dir_package_x86 + 'Alive-0.1-net20\'
	$dir_package_x86_v2_bin = $dir_package_x86_v2 + 'bin\'
	$dir_package_x86_v2_zip = $dir_package_x86 + 'Alive-0.1-x86-net20.zip'
	$dir_package_x86_v4 = $dir_package_x86 + 'Alive-0.1-net4\'
	$dir_package_x86_v4_bin = $dir_package_x86_v4 + 'bin\'
	$dir_package_x86_v4_zip = $dir_package_x86 + 'Alive-0.1-x86-net4.zip'
	
	# x64
	$dir_compile_x64 = $dir_compile + 'x64\'
	$dir_compile_x64_v2 = $dir_compile_x64 + 'net20\'
	$dir_compile_x64_v4 = $dir_compile_x64 + 'net4\'	
	$dir_package_x64 = $dir_package + 'x64\'
	$dir_package_x64_v2 = $dir_package_x64 + 'Alive-0.1-net20\'
	$dir_package_x64_v2_bin = $dir_package_x64_v2 + 'bin\'
	$dir_package_x64_v2_zip = $dir_package_x64 + 'Alive-0.1-x64-net20.zip'
	$dir_package_x64_v4 = $dir_package_x64 + 'Alive-0.1-net4\'
	$dir_package_x64_v4_bin = $dir_package_x64_v4 + 'bin\'
	$dir_package_x64_v4_zip = $dir_package_x64 + 'Alive-0.1-x64-net4.zip'
	
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
	md $dir_package
	md $dir_test
	
	# x86
	md $dir_compile_x86
	md $dir_compile_x86_v2
	md $dir_compile_x86_v4
	md $dir_package_x86
	md $dir_package_x86_v2
	md $dir_package_x86_v2_bin
	md $dir_package_x86_v4
	md $dir_package_x86_v4_bin
	
	# x64
	md $dir_compile_x64
	md $dir_compile_x64_v2
	md $dir_compile_x64_v4
	md $dir_package_x64
	md $dir_package_x64_v2
	md $dir_package_x64_v2_bin
	md $dir_package_x64_v4
	md $dir_package_x64_v4_bin
}

# Compile the project
task Compile -depends Clean {
	# x86
	# Compile .NET version 2.0
	exec { & $exe_msbuild_x86 $lib_fsproj_v2 "/p:OutputPath=$dir_compile_x86_v2;SolutionDir=$dir_source;Configuration=Release;Platform=x86" }

	# Compile .NET version 4.0
	exec { & $exe_msbuild_x86 $lib_fsproj_v4 "/p:OutputPath=$dir_compile_x86_v4;SolutionDir=$dir_source;Configuration=Release;Platform=x86" }
	
	
	# x64
	# Compile .NET version 2.0
	exec { & $exe_msbuild_x86 $lib_fsproj_v2 "/p:OutputPath=$dir_compile_x64_v2;SolutionDir=$dir_source;Configuration=Release;Platform=x64" }

	# Compile .NET version 4.0
	exec { & $exe_msbuild_x86 $lib_fsproj_v4 "/p:OutputPath=$dir_compile_x64_v4;SolutionDir=$dir_source;Configuration=Release;Platform=x64" }	
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
	
	# x64
	# Package version 2.0
	exec { &$exe_ilmerge /t:dll /out:"$dir_package_x64_v2\bin\Alive.dll" "$dir_compile_x64_v2\Alive.dll" "$dir_compile_x64_v2\FSharp.Core.dll" }
	Copy-Item "Documentation\*" "$dir_package_x64_v2" -recurse
	exec { &$exe_zip a -tzip "$dir_package_x64_v2_zip" "$dir_package_x64_v2"  }
	
	# Package version 4
	exec { &$exe_ilmerge /lib:"$sys_net4" /lib:"$sys_publicAsm" /t:dll /targetplatform:"v4,$sys_net4" /out:"$dir_package_x64_v4\bin\Alive.dll" "$dir_compile_x64_v4\Alive.dll" "$dir_compile_x64_v4\FSharp.Core.dll" }
	Copy-Item "Documentation\*" "$dir_package_x64_v4" -recurse
	exec { &$exe_zip a -tzip "$dir_package_x64_v4_zip" "$dir_package_x64_v4"  }
}