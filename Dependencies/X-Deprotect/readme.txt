<<<<<<< HEAD
X-deprotect (hereinafter referred to as "xdep") is a utility for repairing Warcraft3: RoC/TFT maps damaged by special utilities ("optimizers" or "protectors") in such a way that they work in the game, but cannot be opened in the editor.

It should be understood that in general it is impossible to get exactly the same version as the original "protected" map. But you can almost always get a version that works absolutely indistinguishable from the original, while being freely editable.

"Restoration" hereinafter refers to the process of obtaining such a map that can be opened and saved in the editor, while the functionality of which will remain completely identical to the original map.

xdep performs the bare minimum necessary for such a restore, and optionally some additional operations to make the map easier to understand.
(these operations, detailed below, may cause a crash on some maps, but since they are not necessary to restore the map, they can be disabled in the configuration)

xdep is intended not so much for thoughtlessly removing "protection" in 1 click (although such use is possible), but for automating many routine operations during "manual" restoration of a map. At any step, you can intervene in the automatic recovery process by editing files in the temporary folder.

On the resulting restored map, you can use utilities like Deprotect, Dewidgetizer to further restore, for example, GUI triggers or object data.
(due to the fact that these operations are quite complex, and at the same time are not necessary, this utility does not perform them)
Or just edit the map script through the editor, without performing the routine operations of unpacking/packing the war3map.j file from the map with all the glitches associated with it.

What exactly does xdep do in the minimum working configuration:
- unpacks all map files into a separate temporary folder;
- restores the list of files in the archive by scanning all files in search of possible names of other files;
- fixes the war3map.w3i file, which is deliberately corrupted by security utilities;
- deletes files (attributes), (listfile), (signature), transfers the map script to war3map.j;
- restores the list of imported files (war3map.imp);
- restores war3map.wtg, war3map.wct, war3mapUnits.doo files based on map script;
(the map script itself is included in one trigger and changed in such a way that the map is saved without errors in the editor)
- collects the resulting files into a new archive, adding a header to it from the original one.

The list of additional features:
- rename functions with "standard" names assigned by the editor to avoid name conflicts when saving (this option is necessary if "obfuscation" of function names was not used when protecting the map)
- substitution of the code of single-use functions at the place of their call: it is necessary to recognize the initialization section, to restore data about start locations, units, regions, etc. (usually this is already done by some optimization utilities)
- renaming global variables with obfuscated names to something like "udg_integers01"

- indentation in the script
- restoring start locations data to war3mapUnits.doo file based on initialization section
(if this option is disabled, war3mapUnits.doo is still created, but empty as it is needed by WorldEditor)

In the next versions, it is planned to bring the functionality closer to that with which the open version of Dota was obtained (http://dimon.xgm.ru/opendota/), namely:
- data recovery of regions, sounds, cameras, units in the editor format;
- splitting the script into separate triggers;
- renaming functions/variables/triggers/regions and other things according to user-defined lists of names;

The utility is a console one, all parameters, including the names of the input and output files, are described in the xdep.ini text file.
The configuration file is provided with more or less detailed comments on each option.
To start, just enter the path to the required map in the configuration and run xdep.exe.

To work with MPQ, the well-known SFmpq.dll library with a custom-written console archiver is used.
The listfile for the archiver is located in the file listfile.txt, includes lists of names from the standard War3 TFT archives, as well as from several maps on which testing was carried out.

Utility author: zibada aka DimonT, zibada@xgm.guru, ICQ 937160
Thanks for testing help goes to Sky.

XGM - Russian modmaker portal
=======
X-deprotect (далее "xdep") - утилита для восстановления карт для Warcraft3: RoC/TFT, поврежденных специальными утилитами ("оптимизаторами" или "протекторами") таким образом, что в игре они работают, но в редакторе - не открываются.

Следует понимать, что получить из "защищенной" карты в точности ту версию, какой она была исходно, в общем случае невозможно. Но почти всегда можно получить версию, работающую абсолютно неотличимо от оригинала, при этом свободно редактируемую.

Под "восстановлением" здесь и далее подразумевается процесс получения такой карты, которую можно открыть и сохранить в редакторе, при этом функциональность которой останется полностью идентичной исходной карте.

xdep выполняет необходимый минимум операций для такого восстановления, а также, опционально, некоторые дополнительные операции для облегчения понимания устройства карты.
(эти операции, подробно описанные ниже, могут вызывать сбой на некоторых картах, но так как для восстановления карты они не обязательны, их можно отключить в конфигурации)

xdep предназначен не столько для бездумного снятия "защиты" в 1 клик (хотя и такое использование возможно), сколько для автоматизации многих рутинных операций при "ручном" восстановлении карты. На любом шаге в автоматический процесс восстановления можно вмешаться, редактируя файлы во временной папке.

На получившейся восстановленой карте можно применять утилиты типа Deprotect, Dewidgetizer для дальнейшего восстановления, например, GUI-триггеров или объектных данных.
(в силу того, что эти операции довольно сложны, и при этом не являются необходимыми, эта утилита их не выполняет)
Или же просто редактировать скрипт карты через редактор, не выполняя рутинных операций распаковывания/запаковывания файла war3map.j из карты со всеми связанными с этим глюками.


Что конкретно делает xdep в минимальной работающей конфигурации:
- распаковывает все файлы карты в отдельную временную папку;
- восстанавливает список файлов в архиве, методом сканирования всех файлов в поисках возможных имен других файлов;
- исправляет файл war3map.w3i, намеренно повреждаемый утилитами для защиты;
- удаляет файлы (attributes), (listfile), (signature), переносит скрипт карты в war3map.j;
- восстанавливает список импортированных файлов (war3map.imp);
- восстанавливает файлы war3map.wtg, war3map.wct, war3mapUnits.doo на основе скрипта карты;
(сам скрипт карты вносится в один триггер и изменяется таким образом, чтобы карта сохранялась без ошибок в редакторе)
- собирает получившиеся файлы в новый архив, добавляя ему заголовок от исходного.

В списке дополнительных возможностей:
- переименовывание функций со "стандартными" именами, назначаемыми редактором, во избежание конфликтов имен при сохранении (эта опция необходима, если при защите карты не использовалось "запутывание" имен функций)
- подстановка кода однократно используемых функций на место их вызова: нужно для распознавания секции инициализации, для восстановлениия данных о start locations, юнитах, регионах и прочем (обычно это и так выполняется некоторыми утилитами для оптимизации)
- переименовывание глобальных переменных с "запутанными" (obfuscated) именами в нечто типа "udg_integers01"
- расстановка отступов в скрипте
- восстановление данных о start locations в файл war3mapUnits.doo на основе секции инициализации
(если эта опция отключена, war3mapUnits.doo все равно создается, но пустым, т.к. он необходим WE)

В следующих версиях планируется приблизить функциональность к той, с помощью которой была получена открытая версия доты (http://dimon.xgm.ru/opendota/), а именно:
- восстановление данных регионов, звуков, камер, юнитов в формат редактора;
- разбиение скрипта на отдельные триггеры;
- переименование функций/переменных/триггеров/регионов и прочего по заданным пользователем спискам имен;


Утилита является консольной, все параметры, включая имена входного и выходного файлов, описываются в текстовом файле xdep.ini.
Файл конфигурации снабжен более-менее подробными комментариями по каждой опции.
Для запуска достаточно прописать путь к требуемой карте в конфигурации и запустить xdep.exe.

Для работы с MPQ используется известная библиотека SFmpq.dll с консольным архиватором собственного написания.
Листфайл для архиватора находится в файле listfile.txt, включает в себя списки имен от стандартных архивов War3 TFT, а также от нескольких карт, на которых проводилось тестирование.


Автор утилиты: zibada aka DimonT, zibada@xgm.guru, ICQ 937160
Благодарность за помощь в тестировании выражается Sky.

XGM - Российский модмейкерский портал
>>>>>>> 788fb75 (Add dependencies)
http://xgm.guru/
