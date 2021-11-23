using System;
using System.IO;
using System.Windows.Forms;

using Microsoft.Web.WebView2.Core;

namespace WebView2.FinFormsAndWpfSample
{
    public partial class WinFormsWindow : Form
    {
        public WinFormsWindow()
        {
            InitializeComponent();
        }

        protected override async void OnShown(EventArgs e)
        {
            await webView.EnsureCoreWebView2Async(
                await CoreWebView2Environment.CreateAsync(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "WebView2")));

            base.OnShown(e);
        }

        private void Navigate_Click(object sender, EventArgs e)
        {
            webView.CoreWebView2.Navigate(UrlText.Text);
        }
    }
}
