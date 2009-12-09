Claim.destroy_all
PaymentSystem.destroy_all
Currency.destroy_all
PathWay.destroy_all
SystemSetting.destroy_all
SystemSetting.create([
                      { :code => "meta", :name => "Meta keyword", 
                        :setting => {:words => ["paypal","webmoney","money_bookers"] } 
                      },
                      { :code => "css", :name => "Css", 
                        :setting => {:css => "style" } 
                      },
                      
                       ])
PaymentSystem.create([ { 
                         :controller => "webmoney",
                         :name => "WebmoneyWMR", 
                         :parameters =>
                         {
                           :secret=>"[bnhjevysqblfkmuj",
                           :payee_purse=>"R324054665688",
                           :wmid => 329080303191,
                           :url => "https://merchant.webmoney.ru/lmi/payment.asp"
                         },
                         :description => "Платежная система webmoney WMR"
                      }, { 
                         :controller => "webmoney",
                         :name => "WebmoneyWMZ", 
                         :parameters =>
                         {
                           :secret=>"[bnhjevysqblfkmuj",
                           :payee_purse=>"Z351277807459",
                           :wmid => 329080303191,
                           :url => "https://merchant.webmoney.ru/lmi/payment.asp"
                         },
                         :description => "Платежная система webmoney WMZ"
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

webmoney_wmr = PaymentSystem.find_by_name "WebmoneyWMR"
webmoney_wmz = PaymentSystem.find_by_name "WebmoneyWMZ"
paypal = PaymentSystem.find_by_name "PayPal"

webmoney_wmr.currencies.create([{ 
                                  :name => "WMR", :code => "WMR",
                                  :description => "Руб."
                                } ])
webmoney_wmz.currencies.create([ {
                                   :name => "WMZ", :code => "WMZ",
                                   :description => "$"
                                 } ])

paypal.currencies.create([
                          {     
                            :name => "PayPal USD", :code => "USD",
                            :description => "PayPal"
                          } ])


wmz = webmoney_wmz.currencies.find_by_code "WMZ"
wmr = webmoney_wmr.currencies.find_by_code "WMR"

pl_usd = paypal.currencies.find_by_code "USD"


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
                }] )
