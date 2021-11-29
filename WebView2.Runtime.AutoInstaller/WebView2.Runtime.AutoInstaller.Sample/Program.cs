// See https://aka.ms/new-console-template for more information
using WebView2.Runtime.AutoInstaller;

Console.WriteLine("Hello, World!");
await WebView2AutoInstaller.CheckAndInstallAsync();
Console.ReadLine();