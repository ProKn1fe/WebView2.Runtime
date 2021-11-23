using System;
using System.ComponentModel;
using System.IO;
using System.Windows;

using Microsoft.Web.WebView2.Core;

namespace WebView2.FinFormsAndWpfSample
{
    public partial class WPFWindow : Window, INotifyPropertyChanged
    {
        public string Url { get; set; } = "https://nuget.org";

        private bool Rendered { get; set; }

        public WPFWindow()
        {
            InitializeComponent();
            DataContext = this;
        }

        protected override async void OnContentRendered(EventArgs e)
        {
            if (Rendered)
                return;
            Rendered = true;

            await webView.EnsureCoreWebView2Async(
                await CoreWebView2Environment.CreateAsync(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "WebView2")));

            base.OnContentRendered(e);
        }

        private void GoClicked(object sender, RoutedEventArgs e)
        {
            webView.CoreWebView2.Navigate(Url);
        }

        public event PropertyChangedEventHandler PropertyChanged;
    }
}
