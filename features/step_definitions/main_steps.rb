# encoding: utf-8

Если /^Я перешел (.+) "([^\"]*)"$/ do |text, page_name|
  visit path_to(page_name)
end

То /^Я должен увидеть "([^\"]*)"$/ do |text|
  response.should contain(text)
end

То /^ссылку "([^\"]*)"$/ do |text|
  response.should contain(text)
end
