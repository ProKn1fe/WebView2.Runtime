using System.Windows;

namespace WebView2.FinFormsAndWpfSample
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            DataContext = this;
        }

        private void OpenWinFormsWin(object sender, RoutedEventArgs e)
        {
            var form = new WinFormsWindow();
            form.Show();
        }

        private void OpenWpfWin(object sender, RoutedEventArgs e)
        {
            var form = new WPFWindow();
            form.Show();
        }
    }
}
