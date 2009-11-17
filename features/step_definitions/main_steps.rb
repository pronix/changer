# encoding: utf-8

Если /^Я перешел на главную страницу "([^\"]*)"$/ do |page|
  visit path_to(page)
end

То /^Я должен увидеть "([^\"]*)"$/ do |text|
  response.should contain(text)
end

То /^должен увидеть поле ввода валюты для платежной системы "([^\"]*)"$/ do |currency|
  case currency
  when /источник/
    response.should have_tag("select#claim_currency_source_id")  
  when /приемник/
    response.should have_tag("select#claim_currency_receiver_id")
  end
  
end

То /^должен увидеть поле для ввода "([^\"]*)"$/ do |arg1|
    response.should have_tag("input#claim_summa")
end

То /^кнопку "([^\"]*)"$/ do |arg1|
  arg1["Продолжить"] && response.should(have_tag("input[type='submit']"))
end
