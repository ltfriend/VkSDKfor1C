﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 Pavel V. Tolkachev
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьСписокПравДоступа();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если Не Модифицированность Тогда
		Возврат;
	КонецЕсли; 
	
	Если ЗавершениеРаботы Тогда
		ТекстПредупреждения = НСтр("ru='Выбранные права доступа не сохранены.'");
	Иначе
		Отказ = Истина;
		
		Оповещение = Новый ОписаниеОповещения("ВопросСохранитьПараметрыЗавершение", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, НСтр("ru='Сохранить выбранные права доступа'"), РежимДиалогаВопрос.ДаНетОтмена);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВопросСохранитьПараметрыЗавершение(Значение, ДополнительныеПараметры) Экспорт
	
	Если Значение = КодВозвратаДиалога.Да Тогда
		СохранитьПраваДоступаИЗакрыть();
	ИначеЕсли Значение = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры
	
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СохранитьПраваДоступа(Команда)
	
	СохранитьПраваДоступаИЗакрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ОтменаНастройкиПравДоступа(Команда)
	
	Модифицированность = Ложь;
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьСписокПравДоступа()
	
	ПраваДоступа.Добавить("nofity", "Отправка уведомлений", Ложь);
	ПраваДоступа.Добавить("friends", "Доступ к друзьям", Ложь);
	ПраваДоступа.Добавить("photos", "Доступ к фотографиям", Ложь);
	ПраваДоступа.Добавить("audio", "Доступ к аудиозаписям", Ложь);
	ПраваДоступа.Добавить("video", "Доступ к видеозаписям", Ложь);
	ПраваДоступа.Добавить("stories", "Доступ к истории", Ложь);
	ПраваДоступа.Добавить("pages", "Доступ к wiki-страницам", Ложь);
	ПраваДоступа.Добавить("status", "Доступ к статусу пользователя", Ложь);
	ПраваДоступа.Добавить("notes", "Доступ к заметкам пользователя", Ложь);
	ПраваДоступа.Добавить("messages", "Доступ к расширенным методам работы с сообщениями", Ложь);
	ПраваДоступа.Добавить("wall", "Доступ к стене пользователя", Ложь);
	ПраваДоступа.Добавить("ads", "Доступ к расширенным методам работы с рекламным API", Ложь);
	ПраваДоступа.Добавить("offline", "Доступ к API в любое время", Ложь);
	ПраваДоступа.Добавить("docs", "Доступ к документам", Ложь);
	ПраваДоступа.Добавить("groups", "Доступ к группам пользователя", Ложь);
	ПраваДоступа.Добавить("notifications", "Доступ к оповещениям об ответах пользователю", Ложь);
	ПраваДоступа.Добавить("stats", "Доступ к статистике групп и приложений пользователя", Ложь);
	ПраваДоступа.Добавить("email", "Доступ к email пользователя", Ложь);
	ПраваДоступа.Добавить("market", "Доступ к товарам", Ложь);
	
	Если Параметры.Свойство("СтрокаДоступа") Тогда
		
		СписокПрав = СтрРазделить(Параметры.СтрокаДоступа, ",");
		Для каждого ПравоДоступа Из СписокПрав Цикл
			НайденныйЭлемент = ПраваДоступа.НайтиПоЗначению(ПравоДоступа);
			Если НайденныйЭлемент <> Неопределено Тогда
				НайденныйЭлемент.Пометка = Истина;
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьПраваДоступаИЗакрыть()

	СтрокаПрав = "";
	
	Для каждого ЭлементСписка Из ПраваДоступа Цикл
		Если ЭлементСписка.Пометка Тогда
			СтрокаПрав = СтрокаПрав + ЭлементСписка.Значение + ",";
		КонецЕсли;
	КонецЦикла;
	
	Если Не ПустаяСтрока(СтрокаПрав) Тогда
		СтрокаПрав = Лев(СтрокаПрав, СтрДлина(СтрокаПрав) - 1);
	КонецЕсли;

	Модифицированность = Ложь;	
	Закрыть(СтрокаПрав);
	
КонецПроцедуры

#КонецОбласти
