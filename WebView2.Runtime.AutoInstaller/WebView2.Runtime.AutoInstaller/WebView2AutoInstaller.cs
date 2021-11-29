using System;
using System.Diagnostics;
using System.IO;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Web.WebView2.Core;

namespace WebView2.Runtime.AutoInstaller
{
    public class WebView2AutoInstaller
    {
        /// <summary>
        /// From https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section
        /// </summary>
        private const string DownloadLink = "https://go.microsoft.com/fwlink/p/?LinkId=2124703";
        public static readonly HttpClient HttpClient = new();

        /// <summary>
        /// Check WebView2 runtime is installed and download then install it.
        /// </summary>
        /// <param name="onlyCheck">Only return runtime installed or not.</param>
        /// <param name="silentInstall">Show WebView2 runtime installer window.</param>
        /// <param name="installerPath">If you distribute installer with app.</param>
        /// <param name="cancellationToken"></param>
        /// <returns>If onlyCheck = true, current installization state, otherwise true if installed or successful installed.</returns>
        /// <exception cref="Exception"></exception>
        public static async Task<bool> CheckAndInstallAsync(bool onlyCheck = false, bool silentInstall = true,
            string installerPath = null, CancellationToken cancellationToken = default)
        {
            // Check webview2 exists
            try
            {
                var version = CoreWebView2Environment.GetAvailableBrowserVersionString();

                if (!string.IsNullOrEmpty(version))
                    return true;
            }
            catch (WebView2RuntimeNotFoundException)
            {
                // Skip because it's normal if runtime is not installed
            }

            if (onlyCheck)
                return false;

            if (string.IsNullOrEmpty(installerPath) && !File.Exists(installerPath))
            {
                installerPath = Path.Combine(Path.GetTempPath(), $"{Path.GetRandomFileName()}-WebView2Installer.exe");
                var installerStream = new FileStream(installerPath, FileMode.Create, FileAccess.Write);

                try
                {
                    var downloadReponse = await HttpClient.GetAsync(DownloadLink, cancellationToken);
#if NETFRAMEWORK
                    await downloadReponse.Content.CopyToAsync(installerStream);
#else
                    await downloadReponse.Content.CopyToAsync(installerStream, cancellationToken);
#endif
                    installerStream.Close();
                }
                catch (Exception e)
                {
                    throw new Exception("Failed to download WebView2 Installer", e);
                }
            }

            try
            {
                var process = Process.Start(new ProcessStartInfo()
                {
                    FileName = installerPath,
                    Arguments = $"{(silentInstall ? "/silent " : "")}/install",
                    Verb = "runas",
                    UseShellExecute = true
                });

#if NETFRAMEWORK
                process.WaitForExit();
#else
                await process.WaitForExitAsync(cancellationToken);
#endif
            }
            catch (Exception e)
            {
                throw new Exception("Cannot run installer", e);
            }

            return true;
        }
    }
}
