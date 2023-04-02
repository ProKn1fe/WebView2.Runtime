$files = Get-ChildItem $PSScriptRoot -Filter '*.cab';
$nugetTemplate = "$PSScriptRoot\Template.nuspec";
$webClient = New-Object System.Net.WebClient;
$cabRegex = [Regex] '"http[^"]*(?<version>Runtime.[0-9.]*)\.[^"]*\.cab"';
$webViewVersion = [Version] ('1.0');
$downloadManually = 0
$checkNugetVersion = 0
$publish = 0

if ($args -match "-FetchVersionFromNuget")
{
	$checkNugetVersion = 1
}

# Download .cab files manually if no one in build directory
if ($files.Count -eq 0)
{
	Write-Output "WebView2 .cab files not found, trying to download it automatically"
	$downloadPage = $webClient.DownloadString("https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section");
	$cabFiles = $cabRegex.Matches($downloadPage);
	# First we need get all versions from page and find latest
	foreach ($version in $cabFiles)
	{
		$v = $version.Groups[1].Value.Replace('Runtime.', '');
		$vv = [Version] ($v);
		if ($vv -gt $webViewVersion)
		{
			$webViewVersion = $vv;
		}
	}
	Write-Output "Select version: $webViewVersion"	
	foreach ($file in $cabFiles)
	{
		$url = $file.Value.Replace('"', '');
		if (!$url.Contains($webViewVersion))
		{
			continue;
		}
		$fileName = [System.IO.Path]::GetFileName($url);
		Write-Output "Package: $fileName"
		if ($checkNugetVersion -eq 1)
		{
			Write-Output "Checking nuget version"
			$name_split = $fileName.Split('.');
			$arch = $name_split[$name_split.Length - 2].ToUpper();
			$packageName = "WebView2.Runtime.$arch";
			$nugetOutput = & "$PSScriptRoot\Utils\nuget.exe" "list" "$packageName";
			$nugetPackagesInfo = $nugetOutput | Select-String -Pattern $packageName | Select-Object -Last 1;
			$nugetVersion = $nugetPackagesInfo.ToString().Split(' ')[1];
			Write-Output "Nuget version: $nugetVersion";
			if ([Version] $nugetVersion -ge [Version] $webViewVersion)
			{
				Write-Output "Nuget version >= microsoft website version, skipping";
				continue;
			}
		}
		Write-Output "Downloading: $fileName"
		$webClient.DownloadFile($url, "$PSScriptRoot\$fileName");
	}
	$downloadManually = 1
}
$files = Get-ChildItem $PSScriptRoot -Filter '*.cab';

foreach ($file in $files)
{
	$name_split = $file.Name.Split('.');
	$arch = $name_split[$name_split.Length - 2].ToUpper();
	
	$output_path = "$PSScriptRoot\WebView2.Runtime.$arch";
	$output_folder = "WebView2.Runtime.$arch";
	
	# Remove exists directory
	if (Test-Path $output_path) { Remove-Item $output_path -Recurse -Force; }
	New-Item -ItemType Directory -Force -Path "$output_path\contentFiles\any\any\";
	
	# Unpack cab
	cmd.exe /c "$PSScriptRoot\Utils\expand.exe -F:* $($file.FullName) $output_path\contentFiles\any\any\";
	
	# Now we need rename folder in content directory
	Get-ChildItem "$output_path\contentFiles\any\any\" -Directory | Rename-Item -NewName "WebView2";
	
	#Parse version from manifest
	$version_file = Get-ChildItem "$output_path\contentFiles\" -Filter "*.manifest" -Recurse;
	$webViewVersion = $version_file[0].Name.Replace(".manifest", "");
	
	# Copy nuspec and replace vars
	(Get-Content $nugetTemplate).Replace('%NAME%', $output_folder).Replace('%VERSION%', $webViewVersion) | Set-Content "$output_path\$output_folder.nuspec";
	# Copy license file
	Copy-Item "$PSScriptRoot\LICENSE.txt" -Destination "$output_path\LICENSE.txt";
	
	# Compile nupkg
	cmd.exe /c "$PSScriptRoot\Utils\nuget.exe pack $output_path\$output_folder.nuspec";
	
	Remove-Item $output_path -Recurse -Force;
}

# Remove downloaded files
if ($downloadManually -eq 1)
{
	foreach ($file in $files)
	{
		Remove-Item $file -Force;
	}
}

$files = Get-ChildItem $PSScriptRoot -Filter "*$webViewVersion.nupkg";

if ($args -match "-Publish")
{
	powershell.exe -File "$PSScriptRoot\publish.ps1";
}