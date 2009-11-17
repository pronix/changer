# encoding: utf-8

Допустим /^Я на гланой странице сервиса "([^\"]*)"$/ do |page|
  Claim.destroy_all
  visit path_to(page)
  
end

Допустим /^прописан обмен с "([^\"]*)" на "([^\"]*)"$/ do |curr1, curr2|
  @source_currency =  Factory(curr1.to_sym)
  @receive_currency =  Factory(curr2.to_sym) 
  Factory(:path_way_paypal_usd_to_wmz, 
          :currency_source => @source_currency,
          :currency_receiver => @receive_currency )
  
end

Если /^Я заполнил поле валюты "([^\"]*)" значением "([^\"]*)"$/ do |field, value|
  payment_sys = value.split("_").first.upcase
  code = value.split("_").last.upcase
  @currency = (@source_currency.code.upcase == code &&
               @source_currency.payment_system.name.upcase == payment_sys ) ? @source_currency : @receive_currency 

  fill_in(field, :with => @currency.id)
end

Если /^Я заполнил поле суммы "([^\"]*)" значением "([^\"]*)"$/  do |field, value|
  fill_in(field, :with => value)
end

Если /^нажал на кнопку "([^\"]*)"$/ do |button|
  click_button(button)
end

То /^должен создать новую заявку$/ do
  Claim.all.should have(1).record
end

То /^должен сохранить номер заявки в сессии$/ do
  session[:claim_id].should == Claim.last.id
end

То /^заявка должна иметь статус "([^\"]*)"$/ do |state|
  Claim.last.send(state.to_sym).should be_true
end

То /^должен отобразить "([^\"]*)"$/ do |text|
  response.should contain(text)
end
То /^перенапрвить меня на форму заполнения заявки для "([^\"]*)"$/ do |page|
  visit path_to(page)
end


То /^должен увидеть сообщение "([^\"]*)"$/ do |text|
  response.should contain(text)
end

Если /^Я нажал на кнопку "([^\"]*)"$/ do |button|
  click_button(button)
end

То /^не должен создать новую заявку$/ do
  Claim.all.should have(0).record
end

То /^не должен сохранить номер заявки в сессии$/ do
  session[:claim_id].should be_nil
end

То /^должен увидеть сообщение об ошибках$/ do
  
  response.should have_tag("div#flash[class='flash_error']")
end

То /^перенапрвить меня на "([^\"]*)"$/ do |page|
  visit path_to(page)
end
