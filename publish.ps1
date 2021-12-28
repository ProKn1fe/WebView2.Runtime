$files = Get-ChildItem $PSScriptRoot -Filter '*.nupkg';

if ($args.Count -eq 1)
{
	$files = @($args[0])
}

foreach ($file in $files)
{
	cmd.exe /c "$PSScriptRoot\Utils\nuget.exe push $file -Source https://api.nuget.org/v3/index.json";
}