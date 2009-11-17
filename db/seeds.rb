
PaymentSystem.destroy_all
Currency.destroy_all
PathWay.destroy_all

PaymentSystem.create([ { 
                         :controller => "webmoney",
                         :name => "Webmoney", 
                         :description => "Платежная система webmoney"
                      }, { 
                         :controller => "paypal",
                         :name => "PayPal",
                         :description => "PayPal"
                      } ] )

webmoney = PaymentSystem.find_by_name "Webmoney"
paypal = PaymentSystem.find_by_name "PayPal"

webmoney.currencies.create([ {
                               :name => "WMZ", :code => "WMZ",
                               :description => "$"
                             }, { 
                               :name => "WMR", :code => "WMR",
                               :description => "Руб."
                             } ])
paypal.currencies.create([
                          {     
                            :name => "PayPal USD", :code => "USD",
                            :description => "PayPal"
                          }, {     
                            :name => "PayPal EUR", :code => "EUR",
                            :description => "PayPal"
                          }
                               ])


wmz = webmoney.currencies.find_by_code "WMZ"
wmr = webmoney.currencies.find_by_code "WMR"

pl_usd = paypal.currencies.find_by_code "USD"
pl_eur = paypal.currencies.find_by_code "EUR"

PathWay.create([
                { 
                  :currency_source => wmz,
                  :currency_receiver => pl_usd,
                  :percent => 1,
                  :description => "Меняем WMZ на PayPal USD"
                }, { 
                  :currency_source => wmr,
                  :currency_receiver => pl_usd,
                  :percent => 1,
                  :description => "Меняем WMR на PayPal USD"
                } ,
                { 
                  :currency_source => wmz,
                  :currency_receiver => pl_eur,
                  :percent => 1,
                  :description => "Меняем WMZ на PayPal EUR"
                }, { 
                  :currency_source => wmr,
                  :currency_receiver => pl_eur,
                  :percent => 1,
                  :description => "Меняем WMR на PayPal EUR"
                } ,
                
                
                { 
                  :currency_source => pl_usd,
                  :currency_receiver => wmz,
                  :percent => 1,
                  :description => "Меняем PayPal USD на WMZ"
                }, { 
                  :currency_source => pl_usd,
                  :currency_receiver => wmr,
                  :percent => 1,
                  :description => "Меняем PayPal USD на WMR"
                }, { 
                  :currency_source => pl_eur,
                  :currency_receiver => wmz,
                  :percent => 1,
                  :description => "Меняем PayPal EUR на WMZ"
                }, { 
                  :currency_source => pl_eur,
                  :currency_receiver => wmr,
                  :percent => 1,
                  :description => "Меняем PayPal EUR на WMR"
                }
               
               ] )
