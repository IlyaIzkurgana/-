using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DI {
  public partial class Form1 : Form {
    public Form1() {
      InitializeComponent();
    }

    private void label1_Click(object sender, EventArgs e) {

    }

    private void label2_Click(object sender, EventArgs e) {

    }

    private void button1_Click(object sender, EventArgs e) {
      ProductDB productDB = new ProductDB();
      Product pr = new Product();
      pr = productDB.GetProduct(10);

      textBox1.Text = pr.Name;
      textBox1.Text += "\r\n" + pr.Ei;
      textBox1.Text += "\r\n\r\n class ProductFunctions зависит от  class ProductDB";

    }

/*    private void label3_Click(object sender, EventArgs e) {

    }*/

    private void button2_Click(object sender, EventArgs e) {
      ProductDB2 productDB2 = new ProductDB2();
      Product2 pr = new Product2();
      pr = productDB2.GetProduct2(10);

      textBox2.Text = pr.Name;
      textBox2.Text += "\r\n" + pr.Ei;
      textBox2.Text += "\r\n\r\n Теперь class ProductFunctions и class ProductDB являются слабо связанными классами";
      
    }

  }
}
