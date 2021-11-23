### Nuget packages for Microsoft WebView2 Fixed Runtime Distribution

#### Nuget packages:
| Platform | Architecture | Package Name | Version
| --- | --- | --- | --- |
| Windows | X86 | WebView2.Runtime.X86 | [![NuGet](https://img.shields.io/nuget/v/WebView2.Runtime.X86.svg?style=flat-square&label=nuget)](https://www.nuget.org/packages/WebView2.Runtime.X86/) |
| Windows | X64 | WebView2.Runtime.X64 | [![NuGet](https://img.shields.io/nuget/v/WebView2.Runtime.X64.svg?style=flat-square&label=nuget)](https://www.nuget.org/packages/WebView2.Runtime.X64/) |
| Windows | ARM64 | WebView2.Runtime.ARM64 | [![NuGet](https://img.shields.io/nuget/v/WebView2.Runtime.ARM64.svg?style=flat-square&label=nuget)](https://www.nuget.org/packages/WebView2.Runtime.ARM64/) |

#### Usage example:
1) Install via nuget selected architecture package.
```
Install-Package WebView2.Runtime.X64
```
2) Make sure what in you project appears folder WebView2 and all files marked as "Copy To Output".
3) Initialize webview2 before usage, path must be to WebView2 directory. In most cases it must be in application directory.
``` C#
var webView = new WebView2() { Dock = DockStyle.Fill };
await webView.EnsureCoreWebView2Async(await CoreWebView2Environment.CreateAsync(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "WebView2")));
Controls.Add(webView);
webView.CoreWebView2.Navigate("https://nuget.org/");
```

#### Build nupkg:
1) Clone repository.
2) Download latest .cab files from fixed version section and put in build directory (as in picture) - https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section.
![alt text](Pictures/1.png)
3) Run build.ps1 and wait.

#### Used tools:
1) [nuget.exe](https://www.nuget.org/downloads) - nuget package builder.
2) expand.exe - tool for unpack .cab files (taked from windows 10 system32 directory).
