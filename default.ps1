# The tools version of msbuild
$framework = '4.0'

properties {
	$configuration = 'Debug'
	
	# Current working directory
	$cwd = [System.IO.Directory]::GetCurrentDirectory() + '\'
	
	# Platforms
	$x86 = "x86"
	$x64 = "x64"
	
	# Frameworks
	$net20 = "net20"
	$net40 = "net40"
	
	# Tools
	$exe_msbuild_x86 = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
	$exe_msbuild_x64 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe"
	$exe_ilmerge = $cwd + 'source\packages\ilmerge.2.10.526.4\ilmerge.exe'
	$exe_zip = 'source\packages\7z\7z.exe'
	$exe_nuget = 'source\packages\NuGet 2.0\NuGet.exe'
	
	# Paths
	$sys_net4 = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319'
	$sys_net30 = 'C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\v3.0'
	$sys_net35 = 'C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\v3.5'
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
	#$dir_package_x86_v2 = $dir_package_x86 + 'Alive-0.1-net20\'
	#$dir_package_x86_v2_bin = $dir_package_x86_v2 + 'bin\'
	#$dir_package_x86_v2_zip = $dir_package_x86 + 'Alive-0.1-x86-net20.zip'
	#$dir_package_x86_v4 = $dir_package_x86 + 'Alive-0.1-net4\'
	#$dir_package_x86_v4_bin = $dir_package_x86_v4 + 'bin\'
	#$dir_package_x86_v4_zip = $dir_package_x86 + 'Alive-0.1-x86-net4.zip'
	
	# x64
	$dir_compile_x64 = $dir_compile + 'x64\'
	$dir_compile_x64_v2 = $dir_compile_x64 + 'net20\'
	$dir_compile_x64_v4 = $dir_compile_x64 + 'net4\'	
	$dir_package_x64 = $dir_package + 'x64\'
	#$dir_package_x64_v2 = $dir_package_x64 + 'Alive-0.1-net20\'
	#$dir_package_x64_v2_bin = $dir_package_x64_v2 + 'bin\'
	#$dir_package_x64_v2_zip = $dir_package_x64 + 'Alive-0.1-x64-net20.zip'
	#$dir_package_x64_v4 = $dir_package_x64 + 'Alive-0.1-net4\'
	#$dir_package_x64_v4_bin = $dir_package_x64_v4 + 'bin\'
	#$dir_package_x64_v4_zip = $dir_package_x64 + 'Alive-0.1-x64-net4.zip'
	
	# nuget
	$dir_nuget = $dir_build + 'nuget\'
	$dir_nuget_lib = $dir_nuget + 'lib\'
	$dir_nuget_lib_v2 = $dir_nuget_lib + 'net20\'
	$dir_nuget_lib_v4 = $dir_nuget_lib + 'net40\'
	
	# Source directories
	$dir_source = $cwd + 'Source\'
	$dir_config = $dir_source + 'configuration\'
	$dir_lib = $dir_source + 'main\LiteMedia.Alive\'
	
	# Project files
	$lib_fsproj_v2 = $dir_lib + 'LiteMedia.Alive (v2.0).fsproj'
	$lib_fsproj_v4 = $dir_lib + 'LiteMedia.Alive (v4.0).fsproj'
}

task default -depends Compile

task Clean {
	# Clean msbuild directories within projects
	exec { msbuild "$dir_source\LiteMedia.Alive.sln" /t:Clean "/p:SolutionDir=$dir_source;Configuration=Release;Platform=$x86" }
	exec { msbuild "$dir_source\LiteMedia.Alive.sln" /t:Clean "/p:SolutionDir=$dir_source;Configuration=Release;Platform=$x64" }

	# If build dir exists, delete it
	if (Test-Path $dir_build) {
		rd $dir_build -Recurse -Force
	}
	
	# Recreate build target directories
	@($dir_build, $dir_package, $dir_nuget, $dir_test) | ForEach-Object { New-Item $_ -Type d }
	
	# Recreate x86 directories
	@($dir_compile_x86, $dir_compile_x86_v2, $dir_compile_x86_v4)  | ForEach-Object { New-Item $_ -Type d }
	
	# Recreate x64 directories
	@($dir_compile_x64, $dir_compile_x64_v2, $dir_compile_x64_v4) | foreach-object -process { New-Item $_ -Type d }
	
	# Recreate nuget directory structure
	@($dir_nuget_lib, $dir_nuget_lib_v2, $dir_nuget_lib_v4) | ForEach-Object { New-Item $_ -Type d }
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

Function ILMerge_([string]$dir_package_x86_v2, [string]$dir_package_x86_v4, [string]$dir_package_x64_v2, [string]$dir_package_x64_v4) {
	Write-Host ([string]::Join($dir_package_x86_v2, "\bin\Alive.dll"))
	#Write-Host $exe_ilmerge /targetplatform:"v2,C:\Windows\Microsoft.NET\Framework\v2.0.50727" /t:dll /out:"$dir_package_x86_v2\bin\Alive.dll" "$dir_compile_x86_v2\Alive.dll" "$dir_compile_x86_v2\FSharp.Core.dll"
	
	# ilmerge
	# x86
	Write-Host "ILMerge x86 v2.0"
	exec { &$exe_ilmerge /targetplatform:"v2,C:\Windows\Microsoft.NET\Framework\v2.0.50727" /t:dll /out:"$dir_package_x86_v2\bin\Alive.dll" "$dir_compile_x86_v2\Alive.dll" "$dir_compile_x86_v2\FSharp.Core.dll" }
	Write-Host "ILMerge x86 v4"
	exec { &$exe_ilmerge /lib:"$sys_net4" /lib:"$sys_publicAsm" /t:dll /targetplatform:"v4,$sys_net4" /out:"$dir_package_x86_v4\bin\Alive.dll" "$dir_compile_x86_v4\Alive.dll" "$dir_compile_x86_v4\FSharp.Core.dll" }
	# x64
	Write-Host "ILMerge x64 v2.0"
	exec { &$exe_ilmerge /t:dll /out:"$dir_package_x64_v2\bin\Alive.dll" "$dir_compile_x64_v2\Alive.dll" "$dir_compile_x64_v2\FSharp.Core.dll" }
	Write-Host "ILMerge x64 v4"
	exec { &$exe_ilmerge /lib:"$sys_net4" /lib:"$sys_publicAsm" /t:dll /targetplatform:"v4,$sys_net4" /out:"$dir_package_x64_v4\bin\Alive.dll" "$dir_compile_x64_v4\Alive.dll" "$dir_compile_x64_v4\FSharp.Core.dll" }
}

Function ILMerge ([string]$path, [string]$platform, [string]$framework) {
	Write-Host ILMerge $path $platform $framework
	
	if ($platform -eq $x86 -and $framework -eq $net20) {
		exec { &$exe_ilmerge /targetplatform:"v2,C:\Windows\Microsoft.NET\Framework\v2.0.50727" /t:dll /out:"$path\bin\Alive.dll" "$dir_compile_x86_v2\Alive.dll" "$dir_compile_x86_v2\FSharp.Core.dll" }
	}
	
	if ($platform -eq $x86 -and $framework -eq $net40) {
		exec { &$exe_ilmerge /lib:"$sys_net4" /lib:"$sys_publicAsm" /t:dll /targetplatform:"v4,$sys_net4" /out:"$path\bin\Alive.dll" "$dir_compile_x86_v4\Alive.dll" "$dir_compile_x86_v4\FSharp.Core.dll" }		
	}
	
	if ($platform -eq $x64 -and $framework -eq $net20) {
		exec { &$exe_ilmerge /t:dll /out:"$path\bin\Alive.dll" "$dir_compile_x64_v2\Alive.dll" "$dir_compile_x64_v2\FSharp.Core.dll" }
	}
	
	if ($platform -eq $x64 -and $framework -eq $net40) {
		exec { &$exe_ilmerge /lib:"$sys_net4" /lib:"$sys_publicAsm" /t:dll /targetplatform:"v4,$sys_net4" /out:"$path\bin\Alive.dll" "$dir_compile_x64_v4\Alive.dll" "$dir_compile_x64_v4\FSharp.Core.dll" }
	}	
}

Function CreatePackageDir ([string]$version, [string]$platform, [string]$framework) {
	# Build path
	$packagePath = [System.String]::Format("{0}{1}-{2}-{3}", $dir_package, $version, $platform, $framework)
	
	# Create directory paths
	@($packagePath, "$packagePath\bin") | ForEach-Object { New-Item $_ -Type d } | out-null

	return $packagePath
}

Function GetAssemblyVersionName ([string]$dllPath) {
	$assembly = [System.Reflection.Assembly]::LoadFile($dllPath)
	$name = $assembly.GetName()
	return [System.String]::Format("Alive-{0}.{1}", $name.version.Major, $name.version.Minor)
}

task Package -depends Compile {
	$versionName = GetAssemblyVersionName ([System.IO.Path]::Combine($dir_compile_x64_v2, "Alive.dll"))
	
	# Create package dir
	$dir_package_x86_v2 = (CreatePackageDir $versionName $x86 $net20)
	$dir_package_x86_v4 = (CreatePackageDir $versionName $x86 $net40)
	$dir_package_x64_v2 = (CreatePackageDir $versionName $x64 $net20)
	$dir_package_x64_v4 = (CreatePackageDir $versionName $x64 $net40)
	
	# Merge Alive binary with Fsharp core
	ILMerge $dir_package_x86_v2 $x86 $net20;
	ILMerge $dir_package_x86_v4 $x86 $net40;
	ILMerge $dir_package_x64_v2 $x64 $net20;
	ILMerge $dir_package_x64_v4 $x64 $net40;
	
	# Create nuget package
	Write-Host "Create NuGet Package"
	Copy-Item "$dir_package_x86_v2\bin\Alive.dll" $dir_nuget_lib_v2
	Copy-Item "$dir_package_x86_v4\bin\Alive.dll" $dir_nuget_lib_v4
	Copy-Item "$dir_config\nuget\*" $dir_nuget -recurse
	exec { & $exe_nuget pack "$dir_nuget\litemedia-alive.nuspec" -OutputDirectory "$dir_build" }
	
	# create zip package
	# x86
	Copy-Item "Documentation\*" "$dir_package_x86_v2" -recurse
	exec { &$exe_zip a -tzip "$dir_package_x86_v2.zip" "$dir_package_x86_v2"  }	
	Copy-Item "Documentation\*" "$dir_package_x86_v4" -recurse
	exec { &$exe_zip a -tzip "$dir_package_x86_v4.zip" "$dir_package_x86_v4"  }
	
	# x64
	Copy-Item "Documentation\*" "$dir_package_x64_v2" -recurse
	exec { &$exe_zip a -tzip "$dir_package_x64_v2.zip" "$dir_package_x64_v2"  }
	Copy-Item "Documentation\*" "$dir_package_x64_v4" -recurse
	exec { &$exe_zip a -tzip "$dir_package_x64_v4.zip" "$dir_package_x64_v4"  }
}