using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DI {
  public class ProductDBFactory {
    public static ProductDB GetProductDBObj() {
      return new ProductDB();
    }
  }

  public class ProductDBFactory2 {
    public static iProductDB2 GetProductDBObj2() {
      return new ProductDB2();
    }
  }

}
