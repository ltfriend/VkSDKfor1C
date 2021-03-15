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
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	// Параметры доступа хранятся в регистре сведений "БезопасноеХранилищеДанных" библиотеки стандартных подсистем (БСП).
	// Вы можете использовать этот механизм, если добавляете интеграцию с ВК в типовую конфигурацию или реализовать свой
	// механизм сохранения настроек подключения к сайту ВКонтакте.
	УстановитьПривилегированныйРежим(Истина);
	ПараметрыПодключения = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища("ИнтеграцияВК", "ПараметрыПодключения");
	ПараметрыДоступа = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища("ИнтеграцияВК", "ПараметрыДоступа");
	УстановитьПривилегированныйРежим(Ложь);
	
	Если ПараметрыПодключения = Неопределено Тогда
		ВызватьИсключение НСтр("ru='Не заданы параметры подключения ВКонтакте'");
	ИначеЕсли ПараметрыДоступа = Неопределено Тогда
		ВызватьИсключение НСтр("ru='Не выполнена авторизация ВКонтакте'");
	КонецЕсли; 
	
	ВариантРазмещенияИзображения = "Пользователь";

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Оповещение = Новый ОписаниеОповещения("ПроверкаДоступностиОбменаСВКЗавершение", ЭтотОбъект);
	vk_ИнтеграцияВККлиент.ПроверитьАвторизациюПользователя(
		Оповещение,
		ПараметрыПодключения.ИдентификаторПриложения,
		ПараметрыПодключения.ПраваДоступа,
		ПараметрыДоступа.СрокДействияКлюча);
		
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	ПроверяемыеРеквизиты.Очистить(); // Используем собственную проверку.
	
	Если ВариантРазмещенияИзображения <> "Пользователь"
			И Не ЗначениеЗаполнено(Сообщество)
	Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Поле = "Сообщество";
		Сообщение.Текст = НСтр("ru='Не указано сообщество'");
		Сообщение.Сообщить();
		
		Отказ = Истина;
	КонецЕсли; 
	
	Если ИдентификаторАльбома = 0 Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Поле = "ИдентификаторАльбома";
		Сообщение.Текст = НСтр("ru='Не указан альбом'");
		Сообщение.Сообщить();
		
		Отказ = Истина;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Изображение) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Поле = "Изображение";
		Сообщение.Текст = НСтр("ru='Не выбрано изображение для загрузки.'");
		Сообщение.Сообщить();
		
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти 

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ВариантРазмещенияИзображенияПриИзменении(Элемент)

	Элементы.Сообщество.Видимость = ВариантРазмещенияИзображения = "Сообщество";
	ЗаполнитьСписокАльбомов();

КонецПроцедуры

&НаКлиенте
Процедура ИдентификаторСообществаПриИзменении(Элемент)

	ЗаполнитьСписокАльбомов();

КонецПроцедуры

&НаКлиенте
Процедура ИзображениеНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДиалогВыбора = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбора.Заголовок = НСтр("ru='Выберите изображения для загрузки в альбом'");
	ДиалогВыбора.ПредварительныйПросмотр = Истина;
	ДиалогВыбора.ПроверятьСуществованиеФайла = Истина;
	ДиалогВыбора.Фильтр = НСтр("ru='Изображения JPEG|*.jpeg;*.jpg|Все файлы (*.*)|*.*'");

	Оповещение = Новый ОписаниеОповещения("ПомещениеИзображенияЗавершение", ЭтотОбъект);
	НачатьПомещениеФайла(Оповещение,, ДиалогВыбора,, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ПомещениеИзображенияЗавершение(Результат, АдресФайла, ПомещаемыйФайл, ДополнительныеПараметры) Экспорт
	
	Изображение = АдресФайла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗагрузитьФотографию(Команда)
	
	Если ПроверитьЗаполнение() Тогда
		Состояние(НСтр("ru='Загрузка фотографии в альбом...'"));
		НачатьЗагрузкуФотографииВАльбом();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПроверкаДоступностиОбменаСВКЗавершение(РезультатПроверки, ДополнительныеПараметры) Экспорт
	
	Если РезультатПроверки.Результат = "КлючНедействителен" Тогда
		Закрыть();
		Возврат;
	ИначеЕсли РезультатПроверки.Результат = "КлючОбновлен" Тогда
		СохранитьНовыеПараметрыДоступа(РезультатПроверки.ПараметрыДоступа);
	КонецЕсли;
	
	ЗаполнитьСообществаПользователя();
	ЗаполнитьСписокАльбомов();
	
КонецПроцедуры 

&НаКлиенте
Процедура ЗаполнитьСообществаПользователя()
	Перем ИнформацияОбОшибке;
	
	ПараметрыМетода = Новый Структура;
	ПараметрыМетода.Вставить("user_id", ПараметрыДоступа.ИдентификаторПользователя);
	ПараметрыМетода.Вставить("extended", 1);
	
	Результат = vk_ИнтеграцияВККлиентСервер.ВызватьМетодAPI(
		"groups.get",
		ПараметрыМетода,
		ПараметрыДоступа.КлючДоступа,
		ИнформацияОбОшибке);
	
	Если Результат = Неопределено Тогда
		ТекстСообщения = СтрШаблон(
			НСтр("ru='Произошла ошибка при получении списка сообществ пользователя ВКонтакте:
					 |%1'"),
			ИнформацияОбОшибке.Представление);
		ПоказатьПредупреждение(, ТекстСообщения);
		Возврат;
	КонецЕсли; 
	
	Для каждого СообществоВК Из Результат.items Цикл
		Элементы.Сообщество.СписокВыбора.Добавить(
			Формат(СообществоВК.id, "ЧГ="),
			СообществоВК.name);
	КонецЦикла;
		
	Если Элементы.Сообщество.СписокВыбора.Количество() > 0 Тогда
		Сообщество = Элементы.Сообщество.СписокВыбора[0].Значение;
	КонецЕсли; 	
	
КонецПроцедуры 

&НаКлиенте
Процедура ЗаполнитьСписокАльбомов()
	Перем ИнформацияОбОшибке;
	
	Элементы.ИдентификаторАльбома.СписокВыбора.Очистить();
	
	owner_id = ?(ВариантРазмещенияИзображения = "Пользователь",
		Число(ПараметрыДоступа.ИдентификаторПользователя),
		-Число(Сообщество));
	
	ПараметрыМетода = Новый Структура;
	ПараметрыМетода.Вставить("owner_id", owner_id);

	СписокАльбомов = vk_ИнтеграцияВККлиентСервер.ВызватьМетодAPI("photos.getAlbums", ПараметрыМетода,
		ПараметрыДоступа.КлючДоступа, ИнформацияОбОшибке);
	
	Если СписокАльбомов = Неопределено Тогда
		ТекстСообщения = СтрШаблон(НСтр("ru='Произошла ошибка при получении списка альбомов: %1'"),
			ИнформацияОбОшибке.Представление);
		Сообщить(ТекстСообщения);
		Возврат;
	КонецЕсли; 
	
	Для каждого Альбом Из СписокАльбомов.items Цикл
		Элементы.ИдентификаторАльбома.СписокВыбора.Добавить(Альбом.id, Альбом.title);		
	КонецЦикла;
	
	Если Элементы.ИдентификаторАльбома.СписокВыбора.Количество() > 0 Тогда
		ИдентификаторАльбома = Элементы.ИдентификаторАльбома.СписокВыбора[0].Значение;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СохранитьНовыеПараметрыДоступа(ПараметрыДоступа)
	
	// Параметры доступа хранятся в регистре сведений "БезопасноеХранилищеДанных" библиотеки стандартных подсистем (БСП).
	// Вы можете использовать этот механизм, если добавляете интеграцию с ВК в типовую конфигурацию или реализовать свой
	// механизм сохранения настроек подключения к сайту ВКонтакте.
	
	УстановитьПривилегированныйРежим(Истина);
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище("ИнтеграцияВК", ПараметрыДоступа, "ПараметрыДоступа");
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры 

&НаКлиенте
Процедура НачатьЗагрузкуФотографииВАльбом()
	Перем ИнформацияОбОшибке;

	ИдентификаторСообщества = ?(ВариантРазмещенияИзображения = "Пользователь",
		Неопределено, Число(Сообщество));

	Результат = vk_ИнтеграцияВККлиентСервер.ЗагрузитьФотографиюВАльбом(
		ПараметрыДоступа.КлючДоступа,
		ИдентификаторАльбома,
		ИдентификаторСообщества,
		ПолучитьИзВременногоХранилища(Изображение),
		Описание, , ,
		ИнформацияОбОшибке);
	
	Если ИнформацияОбОшибке <> Неопределено И ИнформацияОбОшибке.ТребуетсяCaptcha Тогда
		Оповещение = Новый ОписаниеОповещения("ЗагрузитьФотографиюВАльбомПослеВводаCaptcha", ЭтотОбъект);
		vk_ИнтеграцияВККлиент.ВвестиCaptchaИПовторитьВызовМетодаAPI(ИнформацияОбОшибке.ПараметрыCaptcha, Оповещение);
	Иначе
		ОбработатьЗагрузкуФотографииВАльбом(Результат, ИнформацияОбОшибке);
	КонецЕсли; 
	
КонецПроцедуры 

&НаКлиенте
Процедура ЗагрузитьФотографиюВАльбомПослеВводаCaptcha(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		ПоказатьПредупреждение(, НСтр("ru='Не введена Captcha.'"));
	Иначе
		ОбработатьЗагрузкуФотографииВАльбом(Результат.Ответ, Результат.ИнформацияОбОшибке);
	КонецЕсли; 
	
КонецПроцедуры 

&НаКлиенте
Процедура ОбработатьЗагрузкуФотографииВАльбом(Результат, ИнформацияОбОшибке = Неопределено) Экспорт
	
	Если ИнформацияОбОшибке <> Неопределено Тогда
		ТекстСообщения = СтрШаблон(НСтр("ru='Произошла ошибка при загрузке фотографии в альбом: %1'"),
			ИнформацияОбОшибке.Представление);
		Сообщить(ТекстСообщения);
	Иначе
		Сообщить(НСтр("ru='Фотография успешно загружена в альбом.'"));
	КонецЕсли;
	
КонецПроцедуры 

#КонецОбласти
