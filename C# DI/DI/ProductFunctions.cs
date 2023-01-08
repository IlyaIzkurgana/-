using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DI {
  class ProductFunctions {

    ProductDB _ProductDB;
      public ProductFunctions() {
        _ProductDB = ProductDBFactory.GetProductDBObj();
      }
      public Product GetProduct(int id) {
        return _ProductDB.GetProduct(id);
      }
    }

  class ProductFunctions2 {

    iProductDB2 _ProductDB;
    public ProductFunctions2() {
      _ProductDB = ProductDBFactory2.GetProductDBObj2();
    }
    public Product2 GetProduct2(int id) {
      return _ProductDB.GetProduct2(id);
    }

  }


}
