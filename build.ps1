$files = Get-ChildItem $PSScriptRoot -Filter '*.cab';
$nugetTemplate = "$PSScriptRoot\Template.nuspec"

foreach ($file in $files)
{
	$name_split = $file.Name.Split('.');
	$arch = $name_split[$name_split.Length - 2].ToUpper();
	
	$output_path = "$PSScriptRoot\WebView2.Runtime.$arch";
	$output_folder = "WebView2.Runtime.$arch";
	
	# Remove exists directory
	if (Test-Path $output_path) { Remove-Item $output_path -Recurse -Force; }
	New-Item -ItemType Directory -Force -Path "$output_path\content\";
	
	# Unpack cab
	cmd.exe /c "$PSScriptRoot\Utils\expand.exe -F:* $($file.FullName) $output_path\content\";
	
	# Now we need rename folder in content directory
	Get-ChildItem "$output_path\content\" -Directory | Rename-Item -NewName "WebView2";
	
	#Parse version from manifest
	$version_file = Get-ChildItem "$output_path\content\" -Filter "*.manifest" -Recurse;
	$version = $version_file[0].Name.Replace(".manifest", "");
	
	# Copy nuspec and replace vars
	(Get-Content $nugetTemplate).Replace('%NAME%', $output_folder).Replace('%VERSION%', $version) | Set-Content "$output_path\$output_folder.nuspec";
	
	# Compile nupkg
	cmd.exe /c "$PSScriptRoot\Utils\nuget.exe pack $output_path\$output_folder.nuspec";
	
	Remove-Item $output_path -Recurse -Force;
}