
PaymentSystem.destroy_all
Currency.destroy_all
PathWay.destroy_all

PaymentSystem.create([ { 
                        :name => "Webmoney", 
                        :description => "Платежная система webmoney"
                      }, { 
                         :name => "Яндекс Деньги",
                         :description => "Яндекс Деньги"
                      } ] )

webmoney = PaymentSystem.find_by_name "Webmoney"
yandex_money = PaymentSystem.find_by_name "Яндекс Деньги"
webmoney.currencies.create([ {
                               :name => "WMZ", :code => "WMZ",
                               :description => "$"
                             }, { 
                               :name => "WMR", :code => "WMR",
                               :description => "Руб."
                             } ])
yandex_money.currencies.create([
                                {     
                                  :name => "Яндекс Деньги",
                                  :code => "YANDEX_MONEY",
                                  :description => "YA"
                                }
                               ])

wmz = Currency.find_by_code "WMZ"
wmr = Currency.find_by_code "WMR"
ya = Currency.find_by_code "YANDEX_MONEY"

PathWay.create([{ 
                  :currency_source => wmz,
                  :currency_receiver => ya,
                  :percent => 1,
                  :description => "Меняем WMZ на Яндекс Деньги"
                }, { 
                  :currency_source => wmr,
                  :currency_receiver => ya,
                  :percent => 1,
                  :description => "Меняем WMR на Яндекс Деньги"
                }, { 
                  :currency_source => ya,
                  :currency_receiver => wmz,
                  :percent => 1,
                  :description => "Меняем Яндекс Деньги на WMZ"
                }, { 
                  :currency_source => ya,
                  :currency_receiver => wmr,
                  :percent => 1,
                  :description => "Меняем Яндекс Деньги на WMR"
                } ] )
