Claim.destroy_all
PaymentSystem.destroy_all
Currency.destroy_all
PathWay.destroy_all

PaymentSystem.create([ { 
                         :controller => "webmoney",
                         :name => "Webmoney", 
                         :parameters =>
                         {
                           :secret=>"[bnhjevysqblfkmuj",
                           :payee_purse=>"R324054665688",
                           :wmid => 329080303191,
                           :url => "https://merchant.webmoney.ru/lmi/payment.asp"
                         },
                         :description => "Платежная система webmoney"
                      }, { 
                         :controller => "paypal",
                         :name => "PayPal",
                         :description => "PayPal",
                         :parameters => {
                           :cert_id => "MJFKHQF4DFXKS",
                           :cmd => "_xclick",
                           :business => "parall_1258002853_biz@gmail.com", # аккаунт сервиса - куда переводить денег
                           :url => (ENV['RAILS_ENV'] == "production" ?
                                    "https://www.paypal.com/uk/cgi-bin/webscr" : "https://www.sandbox.paypal.com/uk/cgi-bin/webscr"),
                           :return_url => "http://94.24.178.149:3000/gateway/paypal/done",
                           :login => "parall_1258002853_biz_api1.gmail.com", # логин для paypal api
                           :password => 1258002859,# пароль для paypal api
                           :signature => 'AY6W4PuOSkptV7OpZZhqb44OC6yfAQfc1RhO6xXQsrSoKsD3wvAFetbK'# сигнатура для paypal api
                         }
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
                          } ])


wmz = webmoney.currencies.find_by_code "WMZ"
wmr = webmoney.currencies.find_by_code "WMR"

pl_usd = paypal.currencies.find_by_code "USD"
pl_eur = paypal.currencies.find_by_code "EUR"

PathWay.create([
                { 
                  :currency_source => wmz,
                  :currency_receiver => pl_usd,
                  :rate => 1,
                  :fee => 0.95,
                  :fee_payment_system => 0.8,
                  :description => "Меняем WMZ на PayPal USD"
                }, { 
                  :currency_source => wmr,
                  :currency_receiver => pl_usd,
                  :rate => 0.0357,
                  :fee => 0.95,
                  :fee_payment_system => 0.8,
                  :description => "Меняем WMR на PayPal USD"
                } ,
                { 
                  :currency_source => wmz,
                  :currency_receiver => pl_eur,
                  :rate => 1.535,
                  :fee => 0.95,              
                  :fee_payment_system => 0.8,                  
                  :description => "Меняем WMZ на PayPal EUR"
                }, { 
                  :currency_source => wmr,
                  :currency_receiver => pl_eur,
                  :rate => 0.232,
                  :fee => 0.95,   
                  :fee_payment_system => 0.8,                  
                  :description => "Меняем WMR на PayPal EUR"
                } ,
                
                
                { 
                  :currency_source => pl_usd,
                  :currency_receiver => wmz,
                  :rate => 1,
                  :fee => 0.95,
                  :fee_payment_system => 0.8,                  
                  :description => "Меняем PayPal USD на WMZ"
                }, { 
                  :currency_source => pl_usd,
                  :currency_receiver => wmr, 
                  :rate => 28.0,
                  :fee => 0.95,
                  :fee_payment_system => 0.8,                  
                  :description => "Меняем PayPal USD на WMR"
                }, { 
                  :currency_source => pl_eur,
                  :currency_receiver => wmz,
                  :rate => 0.651,
                  :fee => 0.95,
                  :fee_payment_system => 0.8,                  
                  :description => "Меняем PayPal EUR на WMZ"
                }, { 
                  :currency_source => pl_eur,
                  :currency_receiver => wmr,
                  :rate => 43.0,
                  :fee => 0.95,
                  :fee_payment_system => 0.8,                  
                  :description => "Меняем PayPal EUR на WMR"
                }] )
