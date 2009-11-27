
Допустим /^Я на странице заполнения заявки через "([^\"]*)"$/ do |page|
  Claim.destroy_all  
  @source_currency =  Factory(:webmoney_wmr)
  @receive_currency =  Factory(:paypal_usd)
  @path = Factory(:path_way_wmr_to_paypal_usd, 
          :currency_source => @source_currency,
          :currency_receiver => @receive_currency, :rate => 0.023 )
  
  @claim = Factory(:claim_wmr_to_paypal_usd,
                   :currency_source => @source_currency,
                   :currency_receiver => @receive_currency )
  visit path_to("root_path")
  fill_in("claim_currency_source_id", :with => @source_currency.id)
  fill_in("claim_currency_receiver_id", :with => @receive_currency.id)
  fill_in("claim_summa", :with => 2000)
  click_button("Продолжить")
  visit path_to page
end

Если /^Я заполнил поле "([^\"]*)" значением "([^\"]*)"$/ do |field, value|
  fill_in(field, :with => value)
end

Если /^нажал кнопку "([^\"]*)"$/ do |value|
  click_button(value)
end
То /^должен обновить данные заявки$/ do
  @claim = Claim.last
  @claim.summa.should == 3000
  @claim.email.should == "test@gmail.com"
  @claim.option_purse[:purse_dest].should == "R219807347291"
  
end

То /^заявка должна имееть статус "([^\"]*)"$/ do |state|
  Claim.last.send(state.to_sym).should be_true
end
То /^должен увидеть данные заявки$/ do
  response.should have_tag("div.data_claim")  
end

То /^должен увидеть блок пользовательского соглашения$/ do
  response.should have_tag("div.terms")    
end

То /^должен увидеть флажок согласия с правилами сервиса$/ do
 response.should have_tag("input#claim_agree[type='checkbox']")
end

То /^должен увидеть кнопку "([^\"]*)"$/ do |text|
  response.should have_tag("input#claim_submit") 
end

Если /^Я не заполнил поле "([^\"]*)"$/ do |field|
  fill_in(field, :with => nil)
end

То /^должен не обновлять данные заявки$/ do
  @claim = Claim.last
  @claim.summa.should_not == 3000
  @claim.email.should_not == "test@gmail.com"
  @claim.option_purse.should be_nil
end
То /^заявка не должна имееть статус "([^\"]*)"$/ do |state|
  Claim.last.send(state.to_sym).should be_false
end
То /^должен увидеть сообщение об ошибке$/ do
  response.should have_tag("div#flash[class='flash_error']")  
end

То /^должен увидеть ссылку "([^\"]*)"$/ do |link|
  response.should have_tag("a[href='#{link}']")  
end

Допустим /^Я создал заявку обмена с "([^\"]*)" на "([^\"]*)" и перешел на страницу подтверждения данных$/ do |source, receiver|
  Claim.destroy_all  
  @source_currency =  Factory(source.to_sym) 
  @receive_currency =  Factory(receiver.to_sym)
  @path = Factory(:path_way_paypal_usd_to_wmr, 
          :currency_source => @source_currency,
          :currency_receiver => @receive_currency, :rate => 0.023 )
  
  visit path_to("root_path")
  fill_in("claim_currency_source_id", :with => @source_currency.id)
  fill_in("claim_currency_receiver_id", :with => @receive_currency.id)
  fill_in("claim_summa", :with => 2000)

  click_button("Продолжить")
  fill_in("claim_summa", :with => 2000)  
  fill_in("claim_email", :with => "test@gmail.com")
  fill_in("claim_option_purse_purse_dest", :with => "R121212121212")  
  click_button("Продолжить")
end

Если /^Я согласился с условиями сервиса включил флажок "([^\"]*)"$/ do |field|
  check(field_with_id(field))
end

То /^должен установить состояние заявки "([^\"]*)"$/ do |state|
  Claim.last.send(state.to_sym).should be_true
end

То /^должен увидеть форму оплаты$/ do
  url =   Claim.last.payment_system_source.parameters[:url]
  response.should have_tag("form[action=#{url}]")  
  response.should have_tag("input[name=encrypted]")  
  response.should have_tag("input[name=commit]", :value => "Оплатить")  
end

