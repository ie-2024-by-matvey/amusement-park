// @strict-types

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ,Режим)
	
	Движения.ПрочиеЗатраты.Записывать = Истина;
	Движения.ЗатратыНаФОТ.Записывать = Истина;
	Движения.ЗатратыНаСодержаниеАттракционов.Записывать = Истина;
	
	// регистр ПрочиеЗатраты
	Для Каждого ТекСтрокаСодержаниеАттракционов из СодержаниеАттракционов Цикл
		Движение = Движения.ПрочиеЗатраты.Добавить();
		Движение.Период = Дата;
		Движение.СтатьяЗатрат = ТекСтрокаСодержаниеАттракционов.СтатьяЗатрат;
		Движение.Сумма = ТекСтрокаСодержаниеАттракционов.Сумма;
	КонецЦикла;

	// регистр ЗатратыНаФОТ	
	Для Каждого ТекСтрокаЗатратыНаСотрудников из ЗатратыНаСотрудников Цикл		
		ДвижениеЗатратыНаФОТ = Движения.ЗатратыНаФОТ.Добавить();
		ДвижениеЗатратыНаФОТ.Период = Дата;
		ДвижениеЗатратыНаФОТ.Сотрудник = ТекСтрокаЗатратыНаСотрудников.Сотрудник;
		ДвижениеЗатратыНаФОТ.СтатьяЗатрат = ТекСтрокаЗатратыНаСотрудников.СтатьяЗатрат;
		ДвижениеЗатратыНаФОТ.Сумма = ТекСтрокаЗатратыНаСотрудников.Сумма;		
	КонецЦикла;

	// регистр ЗатратыНаСодержаниеАттракционов	
	Для Каждого ТекСтрокаСодержаниеАттракционов из СодержаниеАттракционов Цикл
		ДвижениеЗатратыНаАттракционы = Движения.ЗатратыНаСодержаниеАттракционов.Добавить();
		ДвижениеЗатратыНаАттракционы.Период = Дата;
		ДвижениеЗатратыНаАттракционы.Аттракцион = ТекСтрокаСодержаниеАттракционов.Аттракцион;
		ДвижениеЗатратыНаАттракционы.СтатьяЗатрат = ТекСтрокаСодержаниеАттракционов.СтатьяЗатрат;
		ДвижениеЗатратыНаАттракционы.Сумма = ТекСтрокаСодержаниеАттракционов.Сумма;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#КонецЕсли