# language: ru
Функционал: Начало работы пользователя с сервисом
  Для того чтоб воспользоваться сервисом
  Как пользователь
  Я должен перейти на главную страницу

  Сценарий: Главная страница сервиса
    Если Я перешел на главную страницу "root_path"
      То Я должен увидеть "Описание сервиса"
       И должен увидеть поле ввода валюты для платежной системы "источник"
       И должен увидеть поле ввода валюты для платежной системы "приемник"
       И должен увидеть поле для ввода "суммы для обмена"
       И кнопку "Продолжить"
