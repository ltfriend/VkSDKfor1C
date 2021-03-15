﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

#Область БезопасноеХранилище

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции для работы с хранилищем паролей.

// Записывает конфиденциальные данные в безопасное хранилище.
// Вызывающий код должен самостоятельно устанавливать привилегированный режим.
//
// Безопасное хранилище недоступно для чтения пользователям (кроме администраторов),
// а доступно только коду, который делает обращения только к своей части данных и
// в том контексте, который предполагает чтение или запись конфиденциальных данных.
//
// Параметры:
//  Владелец - ПланОбменаСсылка, СправочникСсылка, Строка - ссылка на объект информационной базы,
//             представляющий объект-владелец сохраняемого пароля или строка до 128 символов.
//             Для объектов других типов в качестве владельца рекомендуется использовать ссылку на
//             элемент метаданных этого типа в справочнике ИдентификаторыОбъектовМетаданных
//             или ключ в виде строки с учетом имен подсистем.
//             Например, для БСП:
//               Владелец = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("РегистрСведений.АдресныеОбъекты");
//             если нужно 1 хранилище на подсистему БСП:
//               Владелец = "СтандартныеПодсистемы.УправлениеДоступом";
//             если нужно более 1 хранилища на подсистему БСП:
//               Владелец = "СтандартныеПодсистемы.УправлениеДоступом.<Уточнение>";
//
//  Данные  - Произвольный - данные помещаемые в безопасное хранилище. Неопределенно - удаляет все данные.
//             Для удаления данных по ключу следует использовать процедуру УдалитьДанныеИзБезопасногоХранилища.
//  Ключ    - Строка       - ключ сохраняемых настроек, по умолчанию "Пароль".
//                           Ключ должен соответствовать правилам, установленным для идентификаторов:
//                           * Первым символом ключа должна быть буква или символ подчеркивания (_).
//                           * Каждый из последующих символов может быть буквой, цифрой или символом подчеркивания (_).
//
// Пример:
//  Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
//      Если ТекущийПользовательМожетИзменятьПароль Тогда
//          УстановитьПривилегированныйРежим(Истина);
//          ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(ТекущийОбъект.Ссылка, Логин, "Логин");
//          ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(ТекущийОбъект.Ссылка, Пароль);
//          УстановитьПривилегированныйРежим(Ложь);
//      КонецЕсли;
//  КонецПроцедуры
//
Процедура ЗаписатьДанныеВБезопасноеХранилище(Владелец, Данные, Ключ = "Пароль") Экспорт
	
	ОбщегоНазначенияКлиентСервер.Проверить(ЗначениеЗаполнено(Владелец),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Недопустимое значение параметра %1 в %2.
			           |параметр должен содержать ссылку; передано значение: %3 (тип %4).'"),
			"Владелец", "ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище", Владелец, ТипЗнч(Владелец)));
			
	ОбщегоНазначенияКлиентСервер.Проверить(ТипЗнч(Ключ) = Тип("Строка"),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Недопустимое значение параметра %1 в %2.
			           |параметр должен содержать строку; передано значение: %3 (тип %4).'"),
			"Ключ", "ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище", Ключ, ТипЗнч(Ключ)));
	
	ЭтоОбластьДанных = РазделениеВключено() И ДоступноИспользованиеРазделенныхДанных();
	Если ЭтоОбластьДанных Тогда
		БезопасноеХранилищеДанных = РегистрыСведений.БезопасноеХранилищеДанныхОбластейДанных.СоздатьМенеджерЗаписи();
	Иначе
		БезопасноеХранилищеДанных = РегистрыСведений.БезопасноеХранилищеДанных.СоздатьМенеджерЗаписи();
	КонецЕсли;
	
	БезопасноеХранилищеДанных.Владелец = Владелец;
	БезопасноеХранилищеДанных.Прочитать();
	Если Данные <> Неопределено Тогда
		Если БезопасноеХранилищеДанных.Выбран() Тогда
			ДанныеДляСохранения = БезопасноеХранилищеДанных.Данные.Получить();
			Если ТипЗнч(ДанныеДляСохранения) <> Тип("Структура") Тогда
				ДанныеДляСохранения = Новый Структура();
			КонецЕсли;
			ДанныеДляСохранения.Вставить(Ключ, Данные);
			ДанныеДляХранилищеЗначения = Новый ХранилищеЗначения(ДанныеДляСохранения, Новый СжатиеДанных(6));
			БезопасноеХранилищеДанных.Данные = ДанныеДляХранилищеЗначения;
			БезопасноеХранилищеДанных.Записать();
		Иначе
			ДанныеДляСохранения = Новый Структура(Ключ, Данные);
			ДанныеДляХранилищеЗначения = Новый ХранилищеЗначения(ДанныеДляСохранения, Новый СжатиеДанных(6));
			БезопасноеХранилищеДанных.Данные = ДанныеДляХранилищеЗначения;
			БезопасноеХранилищеДанных.Владелец = Владелец;
			БезопасноеХранилищеДанных.Записать();
		КонецЕсли;
	Иначе
		БезопасноеХранилищеДанных.Удалить();
	КонецЕсли;
	
КонецПроцедуры

// Возвращает данные из безопасного хранилища.
// Вызывающий код должен самостоятельно устанавливать привилегированный режим.
//
// Безопасное хранилище недоступно для чтения пользователям (кроме администраторов),
// а доступно только коду, который делает обращения только к своей части данных и
// в том контексте, который предполагает чтение или запись конфиденциальных данных.
//
// Параметры:
//  Владелец    - ПланОбменаСсылка, СправочникСсылка, Строка - ссылка на объект информационной базы,
//                  представляющий объект-владелец сохраняемого пароля или строка до 128 символов.
//  Ключи       - Строка - содержит список имен сохраненных данных, указанных через запятую.
//  ОбщиеДанные - Булево - Истина, если требуется в модели сервиса получить данные из общих данных в разделенном режиме.
// 
// Возвращаемое значение:
//  Произвольный, Структура, Неопределенно - данные из безопасного хранилища. Если указан один ключ,
//                            то возвращается его значение, иначе структура.
//                            Если данные отсутствуют - Неопределенно.
//
// Пример:
//	Процедура ПриЧтенииНаСервере(ТекущийОбъект)
//		
//		Если ТекущийПользовательМожетИзменятьПароль Тогда
//			УстановитьПривилегированныйРежим(Истина);
//			Логин  = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(ТекущийОбъект.Ссылка, "Логин");
//			Пароль = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(ТекущийОбъект.Ссылка);
//			УстановитьПривилегированныйРежим(Ложь);
//		Иначе
//			Элементы.ГруппаЛогинИПароль.Видимость = Ложь;
//		КонецЕсли;
//		
//	КонецПроцедуры
//
Функция ПрочитатьДанныеИзБезопасногоХранилища(Владелец, Ключи = "Пароль", ОбщиеДанные = Неопределено) Экспорт
	
	ОбщегоНазначенияКлиентСервер.Проверить(ЗначениеЗаполнено(Владелец),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Недопустимое значение параметра %1 в %2.
			           |параметр должен содержать ссылку; передано значение: %3 (тип %4).'"),
			"Владелец", "ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища", Владелец, ТипЗнч(Владелец)));
	
	Если РазделениеВключено()
			И ДоступноИспользованиеРазделенныхДанных() Тогда
		Если ОбщиеДанные = Истина Тогда
			ИмяБезопасноеХранилищеДанных = "БезопасноеХранилищеДанных";
		Иначе
			ИмяБезопасноеХранилищеДанных = "БезопасноеХранилищеДанныхОбластейДанных";
		КонецЕсли;
	Иначе
		ИмяБезопасноеХранилищеДанных = "БезопасноеХранилищеДанных";
		
	КонецЕсли;
	Результат = ДанныеИзБезопасногоХранилища(Владелец, ИмяБезопасноеХранилищеДанных, Ключи);
	
	Если Результат <> Неопределено И Результат.Количество() = 1 Тогда
		Возврат ?(Результат.Свойство(Ключи), Результат[Ключи], Неопределено);
	КонецЕсли;
	
	Возврат Результат;

КонецФункции

// Удаляет конфиденциальные данные в безопасное хранилище.
// Вызывающий код должен самостоятельно устанавливать привилегированный режим.
//
// Безопасное хранилище недоступно для чтения пользователям (кроме администраторов),
// а доступно только коду, который делает обращения только к своей части данных и
// в том контексте, который предполагает чтение или запись конфиденциальных данных.
//
// Параметры:
//  Владелец - ПланОбменаСсылка, СправочникСсылка, Строка - ссылка на объект информационной базы,
//               представляющий объект-владелец сохраняемого пароля или строка до 128 символов.
//  Ключи    - Строка - содержит список имен удаляемых данных, указанных через запятую. 
//               Неопределено - удаляет все данные.
//
// Пример:
//	Процедура ПередУдалением(Отказ)
//		
//		// Проверка значения свойства ОбменДанными.Загрузка отсутствует, так как удалять данные
//		// из безопасного хранилища нужно даже при удалении объекта при обмене данными.
//		
//		УстановитьПривилегированныйРежим(Истина);
//		ОбщегоНазначения.УдалитьДанныеИзБезопасногоХранилища(Ссылка);
//		УстановитьПривилегированныйРежим(Ложь);
//		
//	КонецПроцедуры
//
Процедура УдалитьДанныеИзБезопасногоХранилища(Владелец, Ключи = Неопределено) Экспорт
	
	ОбщегоНазначенияКлиентСервер.Проверить(ЗначениеЗаполнено(Владелец),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Недопустимое значение параметра %1 в %2.
			           |параметр должен содержать ссылку; передано значение: %3 (тип %4).'"),
			"Владелец", "ОбщегоНазначения.УдалитьДанныеИзБезопасногоХранилища", Владелец, ТипЗнч(Владелец)));
	
	Если РазделениеВключено() И ДоступноИспользованиеРазделенныхДанных() Тогда
		БезопасноеХранилищеДанных = РегистрыСведений.БезопасноеХранилищеДанныхОбластейДанных.СоздатьМенеджерЗаписи();
	Иначе
		БезопасноеХранилищеДанных = РегистрыСведений.БезопасноеХранилищеДанных.СоздатьМенеджерЗаписи();
	КонецЕсли;
	
	БезопасноеХранилищеДанных.Владелец = Владелец;
	БезопасноеХранилищеДанных.Прочитать();
	Если ТипЗнч(БезопасноеХранилищеДанных.Данные) = Тип("ХранилищеЗначения") Тогда
		ДанныеДляСохранения = БезопасноеХранилищеДанных.Данные.Получить();
		Если Ключи <> Неопределено И ТипЗнч(ДанныеДляСохранения) = Тип("Структура") Тогда
			СписокКлючей = СтрРазделить(Ключи, ",", Ложь);
			Если БезопасноеХранилищеДанных.Выбран() И СписокКлючей.Количество() > 0 Тогда
				Для каждого КлючДляУдаления Из СписокКлючей Цикл
					Если ДанныеДляСохранения.Свойство(КлючДляУдаления) Тогда
						ДанныеДляСохранения.Удалить(КлючДляУдаления);
					КонецЕсли;
				КонецЦикла;
				ДанныеДляХранилищеЗначения = Новый ХранилищеЗначения(ДанныеДляСохранения, Новый СжатиеДанных(6));
				БезопасноеХранилищеДанных.Данные = ДанныеДляХранилищеЗначения;
				БезопасноеХранилищеДанных.Записать();
				Возврат;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	БезопасноеХранилищеДанных.Удалить();
	
КонецПроцедуры

#КонецОбласти

#Область УсловныеВызовы

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции для вызова необязательных подсистем.

// Возвращает Истина, если "функциональная" подсистема существует в конфигурации.
// Предназначена для реализации вызова необязательной подсистемы (условного вызова).
//
// У "функциональной" подсистемы снят флажок "Включать в командный интерфейс".
//
// Параметры:
//  ПолноеИмяПодсистемы - Строка - полное имя объекта метаданных подсистема
//                        без слов "Подсистема." и с учетом регистра символов.
//                        Например: "СтандартныеПодсистемы.ВариантыОтчетов".
//
// Пример:
//  Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВариантыОтчетов") Тогда
//  	МодульВариантыОтчетов = ОбщегоНазначения.ОбщийМодуль("ВариантыОтчетов");
//  	МодульВариантыОтчетов.<Имя метода>();
//  КонецЕсли;
//
// Возвращаемое значение:
//  Булево - Истина, если существует.
//
Функция ПодсистемаСуществует(ПолноеИмяПодсистемы) Экспорт
	
	ИменаПодсистем = СтандартныеПодсистемыПовтИсп.ИменаПодсистем();
	Возврат ИменаПодсистем.Получить(ПолноеИмяПодсистемы) <> Неопределено;
	
КонецФункции

// Возвращает ссылку на общий модуль или модуль менеджера по имени.
//
// Параметры:
//  Имя - Строка - имя общего модуля.
//
// Возвращаемое значение:
//  ОбщийМодуль, МодульМенеджераОбъекта - общий модуль.
//
// Пример:
//	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
//		МодульОбновлениеКонфигурации = ОбщегоНазначения.ОбщийМодуль("ОбновлениеКонфигурации");
//		МодульОбновлениеКонфигурации.<Имя метода>();
//	КонецЕсли;
//
//	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолнотекстовыйПоиск") Тогда
//		МодульПолнотекстовыйПоискСервер = ОбщегоНазначения.ОбщийМодуль("ПолнотекстовыйПоискСервер");
//		МодульПолнотекстовыйПоискСервер.<Имя метода>();
//	КонецЕсли;
//
Функция ОбщийМодуль(Имя) Экспорт
	
	Если Метаданные.ОбщиеМодули.Найти(Имя) <> Неопределено Тогда
		// АПК:488-выкл ВычислитьВБезопасномРежиме не используется, чтобы избежать вызова ОбщийМодуль рекурсивно.
		УстановитьБезопасныйРежим(Истина);
		Модуль = Вычислить(Имя);
		// АПК:488-вкл
	ИначеЕсли СтрЧислоВхождений(Имя, ".") = 1 Тогда
		Возврат СерверныйМодульМенеджера(Имя);
	Иначе
		Модуль = Неопределено;
	КонецЕсли;
	
	Если ТипЗнч(Модуль) <> Тип("ОбщийМодуль") Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Общий модуль ""%1"" не найден.'"),
			Имя);
	КонецЕсли;
	
	Возврат Модуль;
	
КонецФункции

#КонецОбласти

#Область ТекущееОкружение

// Возвращает признак работы в режиме разделения данных по областям
// (технически это признак условного разделения).
// 
// Возвращает Ложь, если конфигурация не может работать в режиме разделения данных
// (не содержит общих реквизитов, предназначенных для разделения данных).
//
// Возвращаемое значение:
//  Булево - Истина, если разделение включено,
//         - Ложь,   если разделение выключено или не поддерживается.
//
Функция РазделениеВключено() Экспорт
	
	Если ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса") Тогда
		МодульРаботаВМоделиСервиса = ОбщийМодуль("РаботаВМоделиСервиса");
		Возврат МодульРаботаВМоделиСервиса.РазделениеВключено();
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

// Возвращает признак возможности обращения к разделенным данным (которые входят в состав разделителей).
// Признак относится к сеансу, но может меняться во время работы сеанса, если разделение было включено
// в самом сеансе, поэтому проверку следует делать непосредственно перед обращением к разделенным данным.
// 
// Возвращает Истина, если конфигурация не может работать в режиме разделения данных
// (не содержит общих реквизитов, предназначенных для разделения данных).
//
// Возвращаемое значение:
//   Булево - Истина, если разделение не поддерживается, либо разделение выключено,
//                    либо разделение включено и разделители    установлены.
//          - Ложь,   если разделение включено и разделители не установлены.
//
Функция ДоступноИспользованиеРазделенныхДанных() Экспорт
	
	Если ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса") Тогда
		МодульРаботаВМоделиСервиса = ОбщийМодуль("РаботаВМоделиСервиса");
		Возврат МодульРаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных();
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область УсловныеВызовы

// Возвращает серверный модуль менеджера по имени объекта.
Функция СерверныйМодульМенеджера(Имя)
	ОбъектНайден = Ложь;
	
	ЧастиИмени = СтрРазделить(Имя, ".");
	Если ЧастиИмени.Количество() = 2 Тогда
		
		ИмяВида = ВРег(ЧастиИмени[0]);
		ИмяОбъекта = ЧастиИмени[1];
		
		Если ИмяВида = ВРег("Константы") Тогда
			Если Метаданные.Константы.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("РегистрыСведений") Тогда
			Если Метаданные.РегистрыСведений.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("РегистрыНакопления") Тогда
			Если Метаданные.РегистрыНакопления.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("РегистрыБухгалтерии") Тогда
			Если Метаданные.РегистрыБухгалтерии.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("РегистрыРасчета") Тогда
			Если Метаданные.РегистрыРасчета.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("Справочники") Тогда
			Если Метаданные.Справочники.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("Документы") Тогда
			Если Метаданные.Документы.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("Отчеты") Тогда
			Если Метаданные.Отчеты.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("Обработки") Тогда
			Если Метаданные.Обработки.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("БизнесПроцессы") Тогда
			Если Метаданные.БизнесПроцессы.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("ЖурналыДокументов") Тогда
			Если Метаданные.ЖурналыДокументов.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("Задачи") Тогда
			Если Метаданные.Задачи.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("ПланыСчетов") Тогда
			Если Метаданные.ПланыСчетов.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("ПланыОбмена") Тогда
			Если Метаданные.ПланыОбмена.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("ПланыВидовХарактеристик") Тогда
			Если Метаданные.ПланыВидовХарактеристик.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		ИначеЕсли ИмяВида = ВРег("ПланыВидовРасчета") Тогда
			Если Метаданные.ПланыВидовРасчета.Найти(ИмяОбъекта) <> Неопределено Тогда
				ОбъектНайден = Истина;
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не ОбъектНайден Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Объект метаданных ""%1"" не найден,
			           |либо для него не поддерживается получение модуля менеджера.'"),
			Имя);
	КонецЕсли;
	
	// АПК:488-выкл ВычислитьВБезопасномРежиме не используется, чтобы избежать вызова ОбщийМодуль рекурсивно.
	УстановитьБезопасныйРежим(Истина);
	Модуль = Вычислить(Имя);
	// АПК:488-вкл
	
	Возврат Модуль;
КонецФункции

#КонецОбласти

#Область БезопасноеХранилище

Функция ДанныеИзБезопасногоХранилища(Владелец, ИмяБезопасноеХранилищеДанных, Ключ)
	
	Результат = Новый Структура(Ключ);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	БезопасноеХранилищеДанных.Данные КАК Данные
	|ИЗ
	|	РегистрСведений." + ИмяБезопасноеХранилищеДанных + " КАК БезопасноеХранилищеДанных
	|ГДЕ
	|	БезопасноеХранилищеДанных.Владелец = &Владелец";
	
	Запрос.УстановитьПараметр("Владелец", Владелец);
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Если РезультатЗапроса.Следующий() Тогда
		Если ЗначениеЗаполнено(РезультатЗапроса.Данные) Тогда
			СохраненныеДанные = РезультатЗапроса.Данные.Получить();
			Если ЗначениеЗаполнено(СохраненныеДанные) Тогда
				ЗаполнитьЗначенияСвойств(Результат, СохраненныеДанные);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

#КонецОбласти

#КонецОбласти
