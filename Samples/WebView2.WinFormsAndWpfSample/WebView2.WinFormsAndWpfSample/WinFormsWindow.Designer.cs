namespace WebView2.FinFormsAndWpfSample
{
    partial class WinFormsWindow
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.webView = new Microsoft.Web.WebView2.WinForms.WebView2();
            this.label1 = new System.Windows.Forms.Label();
            this.UrlText = new System.Windows.Forms.TextBox();
            this.Navigate = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.webView)).BeginInit();
            this.SuspendLayout();
            // 
            // webView
            // 
            this.webView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.webView.CreationProperties = null;
            this.webView.DefaultBackgroundColor = System.Drawing.Color.White;
            this.webView.Location = new System.Drawing.Point(12, 48);
            this.webView.Name = "webView";
            this.webView.Size = new System.Drawing.Size(776, 390);
            this.webView.TabIndex = 0;
            this.webView.ZoomFactor = 1D;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(38, 20);
            this.label1.TabIndex = 1;
            this.label1.Text = "URL:";
            // 
            // UrlText
            // 
            this.UrlText.Location = new System.Drawing.Point(56, 6);
            this.UrlText.Name = "UrlText";
            this.UrlText.Size = new System.Drawing.Size(628, 27);
            this.UrlText.TabIndex = 2;
            this.UrlText.Text = "https://nuget.org";
            // 
            // Navigate
            // 
            this.Navigate.Location = new System.Drawing.Point(690, 5);
            this.Navigate.Name = "Navigate";
            this.Navigate.Size = new System.Drawing.Size(98, 29);
            this.Navigate.TabIndex = 3;
            this.Navigate.Text = "Navigate";
            this.Navigate.UseVisualStyleBackColor = true;
            this.Navigate.Click += new System.EventHandler(this.Navigate_Click);
            // 
            // WinFormsWindow
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.Navigate);
            this.Controls.Add(this.UrlText);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.webView);
            this.Name = "WinFormsWindow";
            this.Text = "WinFormsWindow";
            ((System.ComponentModel.ISupportInitialize)(this.webView)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Microsoft.Web.WebView2.WinForms.WebView2 webView;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox UrlText;
        private System.Windows.Forms.Button Navigate;
    }
}