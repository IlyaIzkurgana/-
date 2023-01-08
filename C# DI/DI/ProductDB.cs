using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DI {
  public class ProductDB {
    public Product GetProduct(int id) {
      // In real time get the employee details from db
      //but here we are hard coded the employee details
      Product pr = new Product() {
        ID = id,
        Name = "Сок Добрый яблоко 1л",
        Type = "Соки",
        Ei = "шт"
      };
      return pr;
    }
  }

    public class ProductDB2 : iProductDB2 {
      public Product2 GetProduct2(int id) {
        // In real time get the employee details from db
        //but here we are hard coded the employee details
        Product2 pr = new Product2() {
          ID = id,
          Name = "Сок Добрый яблоко инверсное 1л ",
          Type = "Соки инверсные",
          Ei = "штука инверсная"
        };
        return pr;
      }
  }



}
