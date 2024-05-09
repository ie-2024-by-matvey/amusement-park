// @strict-types


#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Сгенерировать данные.
// Заполняет базу данных случайными данными о посещениях
//
Процедура СгенерироватьДанные() Экспорт
	
	ТекстМакета = ПолучитьМакет("СлучайныеФИО").ПолучитьТекст();
	
	СписокПосетителей = СтрРазделить(ТекстМакета, Символы.ПС);	
	КоличествоПосетителей = СписокПосетителей.Количество();
	СписокАттракционов = СписокАттракционов();
	
	ГСЧ = Новый ГенераторСлучайныхЧисел();
	
	Курсор = Период.ДатаНачала;
	
	// Рассчитываем каждый день периода
	// В понедельник парк не работает
	// Определяем сколько посетителей придет в парк
	//	Коэффициент в выходные дни - 1,5
	// Выбираем случайных посетитетей из списка	
	Пока Курсор < Период.ДатаОкончания Цикл
		
		Если ДеньНедели(Курсор) = 1 Тогда
			Курсор = Курсор + 86400;
			Продолжить;
		КонецЕсли;
		
		КоэффициентПосетителей = 1;
		
		Если ДеньНедели(Курсор) >= 6 Тогда
			КоэффициентПосетителей = 1.5;
		КонецЕсли;
		
		КоличествоПосетителей = ГСЧ.СлучайноеЧисло(10, 30) * КоэффициентПосетителей;
		
		Для НомерПосетителя = 1 По КоличествоПосетителей Цикл
			
			ИндексСлучайногоПосетителя = ГСЧ.СлучайноеЧисло(0, 99);
			
			ФИОПосетителя = СписокПосетителей[ИндексСлучайногоПосетителя];
			
			Посетитель = ПолучитьПосетителя(ФИОПосетителя, ГСЧ);
			
			//@skip-check query-in-loop
			СформироватьПосещенияПосетителя(Посетитель, Курсор, СписокАттракционов, ГСЧ);
			
		КонецЦикла;	
		
		Курсор = Курсор + 86400;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция СписокАттракционов()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Аттракционы.Ссылка
		|ИЗ
		|	Справочник.Аттракционы КАК Аттракционы";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции

Функция ПолучитьПосетителя(ФИОПосетителя, ГСЧ)
	
	Результат = Справочники.Клиенты.НайтиПоНаименованию(ФИОПосетителя, Истина);
	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		СпрОбъект = Справочники.Клиенты.СоздатьЭлемент();
		СпрОбъект.Заполнить(Неопределено);
		СпрОбъект.Наименование = ФИОПосетителя;
		СпрОбъект.Телефон = СлучайныйТелефон(ГСЧ);
		Если Не СпрОбъект.ПроверитьЗаполнение() Тогда
			ВызватьИсключение "Ошибка создания клиента";
		КонецЕсли;
		СпрОбъект.Записать();
		Результат = СпрОбъект.Ссылка;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция СлучайныйТелефон(ГСЧ)
	
	Результат = "+79";
	
	Для Сч = 1 По 9 Цикл
		
		Результат = Результат + ГСЧ.СлучайноеЧисло(0, 9);
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Сформировать посещения посетителя.
// 
// Параметры:
//  Посетитель - СправочникСсылка.Клиенты - Посетитель
//  ДатаПосещения - Дата - Дата посещения
//  СписокАттракционов - Массив из СправочникСсылка.Аттракционы - Список аттракционов
//  ГСЧ - ГенераторСлучайныхЧисел, Неопределено -  ГСЧ
Процедура СформироватьПосещенияПосетителя(Посетитель, ДатаПосещения, СписокАттракционов, ГСЧ = Неопределено)
	
	Если ГСЧ = Неопределено Тогда
		ГСЧ = Новый ГенераторСлучайныхЧисел();
	КонецЕсли;
	
	// Для каждого посетителя выбираем на сколько аттракционов он пойдет
	// Проверяем для каждого посещения есть ли билет, если билета нет - покупаем доступный для нужного аттракциона
	// Регистрируем посещение

	КоличествоАттракционов = ГСЧ.СлучайноеЧисло(1, 7);
	
	Для Сч = 1 По КоличествоАттракционов Цикл
		
		ИндексАттракциона = ГСЧ.СлучайноеЧисло(0, СписокАттракционов.ВГраница());
		Аттракцион = СписокАттракционов[ИндексАттракциона];
		
		//@skip-check query-in-loop
		ОснованиеПосещения = ТекущееОснование(Посетитель, Аттракцион);
		
		Если Не ЗначениеЗаполнено(ОснованиеПосещения) Тогда
			//@skip-check query-in-loop
			ОснованиеПосещения = КупитьБилет(Посетитель, Аттракцион, ДатаПосещения, ГСЧ);
		КонецЕсли;
		
		ЗарегистрироватьПосещение(ОснованиеПосещения, Аттракцион, ДатаПосещения);
		
	КонецЦикла;

КонецПроцедуры

// Текущее основание.
// 
// Параметры:
//  Посетитель - СправочникСсылка.Клиенты -  Посетитель
//  Аттракцион - СправочникСсылка.Аттракционы -  Аттракцион
// 
// Возвращаемое значение:
//  ДокументСсылка.ПродажаБилета, Неопределено -  Текущее основание
Функция ТекущееОснование(Посетитель, Аттракцион)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	АктивныеПосещенияОстатки.Основание КАК Основание
		|ИЗ
		|	РегистрНакопления.АктивныеПосещения.Остатки(, Основание.Клиент = &Посетитель
		|	И ВидАттракциона В
		|		(ВЫБРАТЬ
		|			Аттракционы.ВидАттракциона
		|		ИЗ
		|			Справочник.Аттракционы КАК Аттракционы
		|		ГДЕ
		|			Аттракционы.Ссылка = &Аттракцион)) КАК АктивныеПосещенияОстатки
		|ГДЕ
		|	АктивныеПосещенияОстатки.КоличествоПосещенийОстаток > 0";
		
	Запрос.УстановитьПараметр("Посетитель", Посетитель);
	Запрос.УстановитьПараметр("Аттракцион", Аттракцион);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		//@skip-check property-return-type
		Возврат Выборка.Основание;	
	КонецЕсли;
	
	Возврат Неопределено;	
	
КонецФункции

// Купить билет.
// 
// Параметры:
//  Посетитель - СправочникСсылка.Клиенты - Посетитель
//  Аттракцион - СправочникСсылка.Аттракционы - Аттракцион
//  ДатаПосещения - Дата - Дата посещения
//  ГСЧ - ГенераторСлучайныхЧисел, Неопределено -  ГСЧ
// 
// Возвращаемое значение:
//  ДокументСсылка.ПродажаБилета 
Функция КупитьБилет(Посетитель, Аттракцион, ДатаПосещения, ГСЧ)
	
	ДоступнаяНоменклатура = ДоступнаяНоменклатура(Аттракцион);
	
	ИндексНоменклатуры = ГСЧ.СлучайноеЧисло(0, ДоступнаяНоменклатура.ВГраница());
	
	Номенклатура = ДоступнаяНоменклатура[ИндексНоменклатуры];
	
	ДокОбъект = Документы.ПродажаБилета.СоздатьДокумент();
	ДокОбъект.Дата = ДатаПосещения;
	ДокОбъект.Заполнить(Неопределено);
	ДокОбъект.Клиент = Посетитель;
	
	СтрокаТЧ = ДокОбъект.ПозицииПродажи.Добавить();
	СтрокаТЧ.Номенклатура = Номенклатура;
	СтрокаТЧ.Количество = 1;
	СтрокаТЧ.Цена = РегистрыСведений.ЦеныНоменклатуры.ЦенаНоменклатуры(Номенклатура);
	СтрокаТЧ.Сумма = СтрокаТЧ.Цена;
	
	ДокОбъект.СуммаДокумента = ДокОбъект.ПозицииПродажи.Итог("Сумма");
	
	Если Не ДокОбъект.ПроверитьЗаполнение() Тогда
		ВызватьИсключение "Ошибка создания продажи";
	КонецЕсли;
	
	ДокОбъект.Записать(РежимЗаписиДокумента.Проведение);
	
	Возврат ДокОбъект.Ссылка;
	
КонецФункции

// Доступная номенклатура.
// 
// Параметры:
//  Аттракцион - СправочникСсылка.Аттракционы -  Аттракцион
// 
// Возвращаемое значение:
//  Массив из СправочникСсылка.Номенклатура -  Доступная номенклатура
Функция ДоступнаяНоменклатура(Аттракцион)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Номенклатура.Ссылка
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	Номенклатура.ВидАттракциона В
		|		(ВЫБРАТЬ
		|			Аттракционы.ВидАттракциона
		|		ИЗ
		|			Справочник.Аттракционы КАК Аттракционы
		|		ГДЕ
		|			Аттракционы.Ссылка = &Аттракцион)";
	Запрос.УстановитьПараметр("Аттракцион", Аттракцион);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции

Процедура ЗарегистрироватьПосещение(ОснованиеПосещения, Аттракцион, ДатаПосещения)
	
	ДокОбъект = Документы.ПосещениеАттракциона.СоздатьДокумент();
	ДокОбъект.Заполнить(Неопределено);
	ДокОбъект.Дата = ДатаПосещения;
	ДокОбъект.Основание = ОснованиеПосещения;
	ДокОбъект.Аттракцион = Аттракцион;
	
	Если Не ДокОбъект.ПроверитьЗаполнение() Тогда
		ВызватьИсключение "Не удалось записать посещение";
	КонецЕсли;
	
	ДокОбъект.Записать(РежимЗаписиДокумента.Проведение);	
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
