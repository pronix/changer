# encoding: utf-8

Если /^Я перешел на главную страницу "([^\"]*)"$/ do |page|
  visit path_to(page)
end

То /^Я должен увидеть "([^\"]*)"$/ do |text|
  response.should contain(text)
end

То /^должен увидеть поле ввода валюты для "([^\"]*)"$/ do |arg1|
  pending
end

То /^должен увидеть поле для ввода суммы для обмена$/ do
  pending
end

То /^ссылку "([^\"]*)"$/ do |arg1|
  response.should contain(text)
end
