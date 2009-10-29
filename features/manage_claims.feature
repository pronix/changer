# language: ru
Функционал: Управление заявками на обмен денег
  Для того чтоб совершить обмен денег
  Как пользователь
  Я должен создать заявку, выполнить оплату заявки и увидеть о завершение заявки

  Сценарий: Создание новой заявки
    Допустим Я на "гланой странице сервиса"
        Если Я нажал на ссылку "создать заявку"
          То Я должен перейти на страницу "новой заявки"
           И должен увидеть "форму новой заявки"

  Сценарий: Заполние данных новой заявки
    Допустим Я на форме заполнения "новой заявки"
        Если Я выбрал "платежную систему(источник)"
           И заполнил "данные платежной системы(источник)"
           И выбрал "платежную систему(премник)"
           И заполнил "данные платежной систему(приемник)"
           И нажал кнопку "потверждение данных"
          То Я должен перейти на страницу "подтверждение данных"
           И должен увидеть "заполненые поля"
           И должен увидеть флажок "согласен с условиями сервиса"
           И должен увидеть кнопку "обмен"

  Сценарий: Потверждение данных
    Допустим Я на странице потдверждения данных
        Если Я включил флажок "согласен с уаловиями сервиса"
           И нажал кнопку "обмен"
          То Я должен перейти на страницу перевода с "платежной системы(источник)"
          
  Сценарий: При перечисление денег с платежной системы(источник)
    Допустим Я перечислил денег с платежной системы(источник)
          То Я должен вернуться на страницу "просмотра заявки на обмен"
           И должен увидеть "состояние заявки"