 
import Foundation

enum LocalizedText {
    enum General {
        static let done = NSLocalizedString("Готово", comment: "")
        static let complete = NSLocalizedString("Завершить", comment: "")
        static let send = NSLocalizedString("Отправить", comment: "")
        static let yes = NSLocalizedString("Да", comment: "")
        static let cancel = NSLocalizedString("Отменить", comment: "")
        static let delete = NSLocalizedString("Удалить", comment: "")
        static let logIn = NSLocalizedString("Войти", comment: "")
        static let signUp = NSLocalizedString("Регистрация", comment: "")
        static let other = NSLocalizedString("", comment: "")
        static let man = NSLocalizedString("Мужчина", comment: "")
        static let woman = NSLocalizedString("Женщина", comment: "")
        static let app = NSLocalizedString("Wanty", comment: "")
        static let or = NSLocalizedString("или", comment: "")
        static let more = NSLocalizedString("Подробнее", comment: "")
        static let createAccount = NSLocalizedString("Создать аккаунт", comment: "")
        
    }
    enum Onboarding {
        enum page1 {
            static let title = NSLocalizedString("Добавляй желания", comment: "")
            static let description = NSLocalizedString("и исполняй", comment: "")
        }
        
        enum page2 {
            static let title = NSLocalizedString("Объединяйся", comment: "")
            static let description = NSLocalizedString("и заводи знакомства", comment: "")
        }
        
        enum page3 {
            static let title = NSLocalizedString("Открывай", comment: "")
            static let description = NSLocalizedString("новые возможности", comment: "")
        }
        
        enum page4 {
            static let title = NSLocalizedString("Добро\nпожаловать", comment: "")
            static let description = NSLocalizedString("в социальную сеть желаний.\nВместе мы изменим историю.", comment: "")
        }
    }
    
    enum registration {
        static let title = NSLocalizedString("Регистрация в Wanty", comment: "")
        static let description = NSLocalizedString("", comment: "")
        static let email = NSLocalizedString("Электронная почта", comment: "")
        static let phone = NSLocalizedString("Номер телефона", comment: "")
        static let facebook = NSLocalizedString("Facebook", comment: "")
        static let apple = NSLocalizedString("Apple", comment: "")
        static let google = NSLocalizedString("Google", comment: "")
        static let iAgree = NSLocalizedString("Регистрируясь в сервисе или используя приложение любым способом, вы соглашаетесь и принимаете настоящие", comment: "")
        static let terms = NSLocalizedString(" Условия", comment: "")
        static let andWithSpaces = NSLocalizedString(" и ", comment: "")
        static let dataPolicy = NSLocalizedString("Политику конфиденциальности", comment: "")
        static let haveAccount = NSLocalizedString("У вас уже есть аккаунт? ", comment: "")
        static let dontHaveAccount = NSLocalizedString("Еще нет аккаунта? ", comment: "")
        static let logIn = NSLocalizedString("Войти", comment: "")
        static let logInWith = NSLocalizedString("Войти через", comment: "")
        static let signUpWith = NSLocalizedString("Регистрация через", comment: "")
        
        enum registerWithEmail {
            static let title = NSLocalizedString("Регистрация", comment: "")
            static let username = NSLocalizedString("Никнейм", comment: "")
            static let email = NSLocalizedString("Электронная почта", comment: "")
            static let password = NSLocalizedString("Пароль", comment: "")
            static let passwordPlaceHolder = NSLocalizedString("Минимум 6 символов", comment: "")
            static let next = NSLocalizedString("Создать аккаунт", comment: "")
        }
        
        enum registerWithPhone {
            static let enterPhone = NSLocalizedString("Введите номер телефона", comment: "")
            static let yourPhone = NSLocalizedString("Ваш номер телефона", comment: "")
            static let smsCode = NSLocalizedString("СМС-код", comment: "")
            static let change = NSLocalizedString("Изменить", comment: "")
            static let recieveCode = NSLocalizedString("Получить SMS-код", comment: "")
            static let enterCode = NSLocalizedString("Введите код подтверждения", comment: "")
            static let enterCodeDescription = NSLocalizedString("Мы отправим вам SMS-код для подтверждения", comment: "")
        }
        
        enum registrationFinal {
            static let title = NSLocalizedString("Осталось совсем \n чуть чуть ..", comment: "")
            static let descrtiption = NSLocalizedString("", comment: "")
            static let dateOfBirth = NSLocalizedString("День рождения", comment: "")
            static let yourBirth = NSLocalizedString("Выберите ваше день рождения", comment: "")
            static let createAccount = NSLocalizedString("Создать аккаунт", comment: "")
        }
    }
    
    enum logInPage {
        
        enum email {
            static let email = NSLocalizedString("Электронная почта", comment: "")
            static let emailOrUsername = NSLocalizedString("Почта или имя профиля", comment: "")
            static let username = NSLocalizedString("имя профиля", comment: "")
            static let password = NSLocalizedString("Пароль", comment: "")
            static let forgotPassword = NSLocalizedString("Забыли пароль?", comment: "")
            static let next = NSLocalizedString("Далее", comment: "")
        }
        
        enum phone {
            static let justPhone = NSLocalizedString("Телефон", comment: "")
            static let enterPhone = NSLocalizedString("Напишите номер телефона", comment: "")
            static let yourPhone = NSLocalizedString("Ваш номер телефона", comment: "")
            static let smsCode = NSLocalizedString("SMS-code", comment: "")
            static let change = NSLocalizedString("Изменить", comment: "")
            static let recieveCode = NSLocalizedString("Получить код", comment: "")
            static let enterCode = NSLocalizedString("Введите код подтверждение", comment: "")
            static let enterCodeDescription = NSLocalizedString("Мы отправим вам код подтверждение на номер", comment: "")
        }
        
        enum ForgotPassword {
            static let title = NSLocalizedString("Восстановить доступ", comment: "")
            static let description = NSLocalizedString("Введите почту и вы получите ссылку на восстановление", comment: "")
            static let restore = NSLocalizedString("Восстановить пароль", comment: "")
            static let successfully = NSLocalizedString("Ссылка отправлена", comment: "")
        }
    }
    
    enum tabBar {
        static let FEED = NSLocalizedString("Лента", comment: "")
        static let INTERESTING = NSLocalizedString("Интересное", comment: "")
        static let ADD = NSLocalizedString("Добавить", comment: "")
        static let MESSAGES = NSLocalizedString("Чаты", comment: "")
        static let PROFILE = NSLocalizedString("Профиль", comment: "")
        static let ACTIVITIES  = NSLocalizedString("Уведомления", comment: "")
        static let CITY = NSLocalizedString("Город", comment: "")
    }
    
    enum feed {
        static let feedWelcome = NSLocalizedString("Добро пожаловать в Wanty!", comment: "")
        static let feedPlaceholder = NSLocalizedString("Здесь вы будете видеть желания ваших подписок", comment: "")
        static let feedFind = NSLocalizedString("Найти друзей", comment: "")
        static let search = NSLocalizedString(" Поиск... ", comment: "")
    }
    
    enum activities {
        static let title = NSLocalizedString("Что нового", comment: "")
        static let description = NSLocalizedString("Уведомления о новых подписчиках и новых запросах на участие в ваших желаниях", comment: "")
    }
    
    enum Interesting {
        static let WISHES_NEARBY = NSLocalizedString("Желания поблизости", comment: "")
        static let YOUR_CITY = NSLocalizedString("Ваш город", comment: "")
        static let PEOPLE = NSLocalizedString("Люди", comment: "")
        static let HISTORY = NSLocalizedString("Истории", comment: "")
        static let POPULAR_HISTORY = NSLocalizedString("Популярные истории", comment: "")
        static let NEARBY = NSLocalizedString("недели", comment: "")
        static let SHOW_NEARBY = NSLocalizedString("Показать желания рядом", comment: "")
        static let SHOW_OTHER = NSLocalizedString("Показать другие", comment: "")
        static let NO_WISHES_CITY = NSLocalizedString("В вашем городе нет желании", comment: "")
        static let FIND_NEAR_WISH = NSLocalizedString("Найдите желания рядом с вами", comment: "")
        static let PEOPLE_IN_YOUR_CITY = NSLocalizedString("Люди в вашем городе", comment: "")
        static let TOP_NEW_USERS = NSLocalizedString("Новички недели", comment: "")
        static let TOP_NEW_USERS_DESCRIPTION = NSLocalizedString("Популярные пользователи", comment: "")
        static let WHAT_ARE_LOOKING_FOR = NSLocalizedString("Что будем искать?", comment: "")
        static let WE_DIDNT_FIND = NSLocalizedString("Мы не нашли ничего по запросу:", comment: "")
        static let CITY_ERROR = NSLocalizedString("В этом городе еще не созданы желания", comment: "")
        static let INTERESTING_PEOPLE_ERROR = NSLocalizedString("В этом городе еще нет пользователей", comment: "")
        static let MOMENTS_ERROR = NSLocalizedString("В этом городе еще не созданы истории", comment: "")
        static let ASK_PERMISSION = NSLocalizedString("Дайте разрешение на геопозицию, чтобы приложение вывело желания в вашем городе.", comment: "")
        static let GIVE_PERMISSION = NSLocalizedString("Дать разрешение", comment: "")
        static let DENIED_PERMISSION = NSLocalizedString("Вы не дали разрешение на геопозицию или мы не смогли найти ваш город, выберите город через поиск.", comment: "")
        static let CHOOSE_CITY = NSLocalizedString("Выбрать город", comment: "")
        
    }
    
    enum addWish {
        static let NEW_WISH = NSLocalizedString("Создать желание", comment: "")
        static let WHAT_YOU_WANT = NSLocalizedString("Ваше желание...", comment: "")
        static let ADD_DESCRIPTION = NSLocalizedString("Добавить описание", comment: "")
        static let ADD_DESCRIPTION_MINI = NSLocalizedString("Описание", comment: "")
        static let NOT_NECESSARY = NSLocalizedString("необязательно", comment: "")
        static let WISH_ADDED_SUCCESS = NSLocalizedString("Желание успешно добавлено", comment: "")
        static let GROUP = NSLocalizedString("Группа", comment: "")
        static let SINGLE = NSLocalizedString("Тет-а-тет", comment: "")
        static let GROUP_CREATED = NSLocalizedString("Групповой чат создан", comment: "")
        static let SINGLE_CHAT_CREATED = NSLocalizedString("Тет-а-тет чат создан", comment: "")
        static let ADD_WISH_ON_MAP = NSLocalizedString("Показать желание на карте", comment: "")
        
        static let GROUP_TITLE_TEXT = NSLocalizedString("Что такое групповое желание?", comment: "")
        static let groupDescriptionText = NSLocalizedString("- Желание, которое вы хотите выполнить коллективно с несколькими людьми.\n- Общайтесь с заинтересованными пользователями в групповом чате.", comment: "")
        
        static let singleTitleText = NSLocalizedString("Что такое тет-а-тет хобби?", comment: "")
        static let singleDescriptionText = NSLocalizedString("- Желание, которое вы хотите выполнить с одним человеком.\n- Общайтесь с заинтересованными пользователями тет-а-тет в личном чате.", comment: "")
        
        static let createGroup = NSLocalizedString("Создать группу", comment: "")
        static let cantCreateWish = NSLocalizedString("Встряхните телефон для получения рандомного желания", comment: "")
        static let shake = NSLocalizedString("Встряхните телефон для получения рандомного желания.", comment: "")
        
        static let ADD_COVER_IMAGE = NSLocalizedString("Загрузите обложку", comment: "")
        static let ADD_COVER_IMAGE_DESCRIPTION = NSLocalizedString("Люди чаще откликаются на хобби с картинкой или фото", comment: "")
        
    }
    
    enum messages {
        static let title = NSLocalizedString("", comment: "")
        static let description = NSLocalizedString("Все ваши чаты будут отображаться здесь", comment: "")
        static let CHATS = NSLocalizedString("Чаты", comment: "")
        static let CHAT = NSLocalizedString("Чат", comment: "")
        static let NOTIFICATIONS = NSLocalizedString("Уведомления", comment: "")
        static let BLACKLIST = NSLocalizedString("Черный список", comment: "")
        static let GROUP_CHAT_OF_WISH = NSLocalizedString("Групповой чат по желанию", comment: "")
        static let SINGLE_CHAT_OF_WISH = NSLocalizedString("Личный чат по желанию", comment: "")
        static let PARTICIPANTS = NSLocalizedString("участники: ", comment: "")
        static let ONLINE = NSLocalizedString("онлайн", comment: "")
        static let OFFLINE = NSLocalizedString("оффлайн", comment: "")
        static let WRITE_MESSAGE = NSLocalizedString("Написать сообщение...", comment: "")
        static let MEMBER = NSLocalizedString("Участник группы", comment: "")
        static let NEWMEMBER = NSLocalizedString("Встречайте нового участника! 🎉", comment: "")
        static let wish_author = NSLocalizedString("автор желания", comment: "")
        static let leftChat = NSLocalizedString("покинул(-a) чат", comment: "")
        static let deleteParticipantTitle = NSLocalizedString("Удаление участника", comment: "")
        static let deleteParticipantMessage = NSLocalizedString("Вы уверены что хотите удалить с чата %@ ?", comment: "")
        static let returnParticipantTitle = NSLocalizedString("Вернуть участника", comment: "")
        static let returnParticipantMessage = NSLocalizedString("Вы уверены что хотите вернуть %@ в чат?", comment: "")
    }
    
    enum profile {
        static let WISHES = NSLocalizedString("Желания", comment: "")
        static let SETTINGS = NSLocalizedString("Настройки", comment: "")
        static let INFORMATION = NSLocalizedString("Информация", comment: "")
        static let LOGOUT = NSLocalizedString("Выйти", comment: "")
        static let EDIT_PROFILE = NSLocalizedString("Редактирование профиля", comment: "")
        static let FOLLOW = NSLocalizedString("Подписаться", comment: "")
        static let FOLLOWING = NSLocalizedString("Вы подписаны", comment: "")
        static let EDIT = NSLocalizedString("Редактировать", comment: "")
        static let BLOCK = NSLocalizedString("Заблокировать", comment: "")
        static let COMPLAIN = NSLocalizedString("Пожаловаться", comment: "")
        static let CANCEL = NSLocalizedString("Отмена", comment: "")
        static let BLOCK_USER_TITLE = NSLocalizedString("Заблокировать %@", comment: "")
        static let BLOCK_USER_MESSAGE = NSLocalizedString("Этот пользователь не сможет найти ваш профиль, публикации или истории в Wanty  и не узнает о том, что вы его заблокировали.", comment: "")
        
        enum myActive {
            static let title = NSLocalizedString("Активные желания", comment: "")
            static let description = NSLocalizedString("Здесь, будут отображаться ваши активные желания", comment: "")
            static let button = NSLocalizedString("Создать желание", comment: "")
        }
        enum myComplete {
            static let title = NSLocalizedString("Завершенные желания", comment: "")
            static let description = NSLocalizedString("Здесь, будут отображаться ваши завершенные желания", comment: "")
        }
        enum myParticipant {
            static let title = NSLocalizedString("Участвую", comment: "")
            static let description = NSLocalizedString("Здесь, будут отображаться желания, где вы участвуете", comment: "")
        }
        enum otherActive {
            static let description = NSLocalizedString("Пока нет активных желаний", comment: "")
        }
        enum otherComplete {
            static let description = NSLocalizedString("Пока нет завершенных желаний", comment: "")
        }
        enum otherParticipant {
            static let title = NSLocalizedString("Желания где %@ участвует", comment: "")
            static let description = NSLocalizedString("Пока нет желаний, где %@ участвует", comment: "")
        }
        
        enum editProfile {
            static let NAME = NSLocalizedString("Имя пользователя", comment: "")
            static let BIO = NSLocalizedString("О себе", comment: "")
            static let ADDITIONAL = NSLocalizedString("Дополнительное", comment: "")
            static let BIRTHDAY = NSLocalizedString("День рождения", comment: "")
            static let GENDER = NSLocalizedString("Пол", comment: "")
        }
        
        enum follow {
            static let FOLLOWERS = NSLocalizedString("Подписчики", comment: "")
            static let FOLLOWINGS = NSLocalizedString("Подписки", comment: "")
        }
    }
    
    enum wish {
        static let COMPLETE_WISH = NSLocalizedString("Завершить желание", comment: "")
        static let WISH = NSLocalizedString("Желание", comment: "")
        static let COMPLETED = NSLocalizedString("завершено", comment: "")
        static let ACTIVE = NSLocalizedString("активно", comment: "")
        static let WISH_BEEN_CREATED = NSLocalizedString("Желание создано", comment: "")
        static let YOUR_REQUEST_WISH = NSLocalizedString("Ваш запрос на желание", comment: "")
        static let PARTICIPATE = NSLocalizedString("Участвовать", comment: "")
        static let FULFILL = NSLocalizedString("Исполнить", comment: "")
        static let REQUESTED = NSLocalizedString("Запрошено", comment: "")
        static let WISH_COMPLETED = NSLocalizedString("Желание завершено", comment: "")
        static let GROUP_CHAT = NSLocalizedString("Групповой чат", comment: "")
        static let SINGLE_CHAT = NSLocalizedString("Личный чат", comment: "")
        static let REQUEST_SUCCESS = NSLocalizedString("Запрос успешно отправлен", comment: "")
        static let WAIT_DESCRIPTION = NSLocalizedString("Вы уже отправили запрос. Ожидайте уведомления.", comment: "")
        static let HISTORY_OF_WISH = NSLocalizedString("Дневник этого желания", comment: "")
        static let STORIES_AT_WILL = NSLocalizedString("Истории по желанию", comment: "")
        static let STORIES_TITLE_FULL = NSLocalizedString("дальше...", comment: "")
        static let COMPLETION_DATE = NSLocalizedString("Дата завершения", comment: "")
        static let CREATE_CONNECTS = NSLocalizedString("Завершить желание", comment: "")
        static let END_WISH = NSLocalizedString("Выберите участников", comment: "")
        static let CONNECTS_CREATED = NSLocalizedString("Коннекты созданы", comment: "")
        static let CONNECTS = NSLocalizedString("Коннекты", comment: "")
        static let CONNECTS_COUNT = NSLocalizedString("%@ коннектов", comment: "")
        static let EMPTY_CONNECTS = NSLocalizedString("У пользователя еще нет коннектов. Выполните желание с %@ и вы отобразитесь здесь", comment: "")
        static let EMPTY_CONNECTS_ME = NSLocalizedString("Исполняйте желания вместе и создавайте коннекты", comment: "")
        static let MOMENT_TITLE = NSLocalizedString("История", comment: "")
        static let MOMENT_MESSAGE = NSLocalizedString("Выберите опцию", comment: "")
        static let MOMENT_SHARE = NSLocalizedString("Поделиться", comment: "")
        static let MOMENT_COMPLAIN = NSLocalizedString("Пожаловаться", comment: "")
        static let MOMENT_DELETE = NSLocalizedString("Удалить", comment: "")
        static let VOTE_UP = NSLocalizedString("Рейтинг повышен", comment: "")
        static let VOTE_DOWN = NSLocalizedString("Рейтинг понижен", comment: "")
        static let VOTE_DOUBLE = NSLocalizedString("Ваш голос учтён", comment: "")
        static let MOMENTS = NSLocalizedString("Истории", comment: "")
        static let PARTICIPANTS = NSLocalizedString("Участники", comment: "")
        static let WANT_TOO = NSLocalizedString("Я тоже", comment: "")
        static let GO_CHAT = NSLocalizedString("Перейти в чат", comment: "")
        
        
        
        enum addHistory {
            static let NEW_HISTORY = NSLocalizedString("Новая история", comment: "")
            static let FINAL_HISTORY = NSLocalizedString("завершающая история", comment: "")
            static let HISTORY_ADDED_SUCCESS = NSLocalizedString("История успешно добавлена", comment: "")
            static let LEAST_ONE_PHOTO = NSLocalizedString("Вы должны добавить минимум одну фотографию", comment: "")
            static let ADDED_NEW_HISTORY = NSLocalizedString("%@: Добавил новую историю", comment: "")
        }
        
        enum singleWishChats {
            static let title = NSLocalizedString("У вас пока нет чатов по этому желанию", comment: "")
            static let description = NSLocalizedString("Одобрите запросы от людей и здесь появятся тет-а-тет чаты", comment: "")
        }
        
        enum requests {
            static let title = NSLocalizedString("У вас пока нет запросов на это желание", comment: "")
            static let description = NSLocalizedString("Ждите, когда люди откликнуться на ваше желание", comment: "")
            static let TITLE_FOR_COMPLETED_WISH = NSLocalizedString("Это желание уже завершено", comment: "")
            static let SUBTITLE_FOR_COMPLETED_WISH = NSLocalizedString("Создайте новое желание чтобы получать новые запросы", comment: "")
            static let REQUESTS = NSLocalizedString("Запросы", comment: "")
            static let REQUESTS_WISH = NSLocalizedString("Запросы на желание", comment: "")
            static let NO_REQUESTS = NSLocalizedString("По данному желанию еще нет запросов", comment: "")
            static let CONFIRM_REQUEST_TITLE = NSLocalizedString("Подтвердите заявку", comment: "")
            static let CONFIRM_REQUEST_DESCRIPTION = NSLocalizedString("При подтверждении,", comment: "")
            static let CONFIRM_REQUEST_DESCRIPTION_GROUP = NSLocalizedString("добавится в групповой чат", comment: "")
            static let CONFIRM_REQUEST_DESCRIPTION_SINGLE = NSLocalizedString("у вас откроется личный чат с", comment: "")
            static let CONFIRM_REQUEST_HUD = NSLocalizedString("Подтверждение принято", comment: "")
            static let REJECT_REQUEST_TITLE = NSLocalizedString("Отклонить заявку?", comment: "")
            static let REJECT_REQUEST_DESCRIPTION = NSLocalizedString("%@ не узнает, что вы отклонили заявку", comment: "")
            static let REJECT_REQUEST_HUD = NSLocalizedString("Участнику отказано", comment: "")
            static let ADDED = NSLocalizedString("добавлен(-а)", comment: "")
            static let CHAT_CREATED = NSLocalizedString("Чат создан", comment: "")
            static let ACCEPT_TET_A_TET = NSLocalizedString("После подтверждения, вы сможете общаться с %@ в личном чате", comment: "")
            static let ACCEPT_GROUP = NSLocalizedString("После подтверждения, %@ добавится в групповой чат", comment: "")
            static let ACCEPTED_TITLE = NSLocalizedString("%@ подтвержден", comment: "")
            static let ACCEPTED_TET_A_TET = NSLocalizedString("Вы можете перейти в личный чат с %@ или перейти на к другим заявкам на ваше желание", comment: "")
            static let STAY_ON_REQUESTS = NSLocalizedString("Другие заявки", comment: "")
            static let ACCEPTED_GROUP = NSLocalizedString("Вы можете перейти в групповой чат или смотреть другие заявки на ваше желание", comment: "")
            static let INTRODUCE_YOURSELF = NSLocalizedString("Представьте себя", comment: "")
            static let OPTIONAL_FIELD = NSLocalizedString("Необязательное поле", comment: "")
        }
    }
    
    enum permissions {
        static let PERMISSION_CAMERA_TITLE = NSLocalizedString("Камера", comment: "")
        static let PERMISSION_CAMERA_DESCRIPTION = NSLocalizedString("Доступ к использованию камеры", comment: "")
        static let PERMISSION_GALLERY_TITLE = NSLocalizedString("Галерея", comment: "")
        static let PERMISSION_GALLERY_DESCRIPTION = NSLocalizedString("Предоставьте доступ к вашей галерее для использования ваших фотографий", comment: "")
        static let PERMISSION_LOCATION_TITLE = NSLocalizedString("Геопозиция при использовании", comment: "")
        static let PERMISSION_LOCATION_DESCRIPTION = NSLocalizedString("Доступ к вашей геолокации", comment: "")
        static let PERMISSION_DENIED_TITLE = NSLocalizedString("Упс.. нужен доступ", comment: "")
        static let PERMISSION_DENIED_DESCRIPTION = NSLocalizedString("Перейдите в Настройки и дайте разрешение.", comment: "")
        static let PERMISSION_HEADER = NSLocalizedString("Предоставить", comment: "")
        static let PERMISSION_TITLE = NSLocalizedString("Доступ", comment: "")
        static let PERMISSION_DESCRIPTION = NSLocalizedString("Разрешения необходимы для правильной работы приложения.", comment: "")
        static let PERMISSION_ALLOW = NSLocalizedString("Разрешить", comment: "")
        static let PERMISSION_ALLOWED = NSLocalizedString("Разрешено", comment: "")
        
    }
    
    enum alert {
        static let fillAll = NSLocalizedString("Заполните все поля", comment: "")
        static let usernameUnavailable = NSLocalizedString("Имя пользователя недоступно", comment: "")
        static let pickPhoto = NSLocalizedString("Выберите фото", comment: "")
        static let fillEmail = NSLocalizedString("Заполните почту", comment: "")
        static let fillPassword = NSLocalizedString("Заполните пароль", comment: "")
        static let saved = NSLocalizedString("Сохранено", comment: "")
        static let photoUpdated = NSLocalizedString("Аватарка обновлена", comment: "")
        static let shareWish = NSLocalizedString("Поделиться", comment: "")
        static let completeWish = NSLocalizedString("Завершить", comment: "")
        static let completionWish = NSLocalizedString("Завершение желания", comment: "")
        static let completionWishTitle = NSLocalizedString("Вы уверены что хотите завершить желание?", comment: "")
        static let deleteWish = NSLocalizedString("Удалить", comment: "")
        static let deleteWishTitle = NSLocalizedString("Вы точно хотите удалить желание?", comment: "")
        static let deleteWishSuccess = NSLocalizedString("Удалено!", comment: "")
        static let exitWish = NSLocalizedString("Покинуть", comment: "")
        static let exitWishTitle = NSLocalizedString("Вы уверены что хотите покинуть желание?", comment: "")
        static let exitWishSubtitle = NSLocalizedString("Покинуть желание", comment: "")
        static let exitWishSuccess = NSLocalizedString("Вышли успешно!", comment: "")
        static let complainOnWish = NSLocalizedString("Пожаловаться", comment: "")
        static let complain = NSLocalizedString("Жалоба", comment: "")
    }
    
    enum ImagePicker {
        static let title = NSLocalizedString("", comment: "")
        static let description = NSLocalizedString("", comment: "")
    }
    
    enum notifications {
        static let sendFollowNotification = NSLocalizedString(" подписался(-лась)", comment: "")
    }
    
    enum error {
        static let city = NSLocalizedString("В этом городе пока нет желаний", comment: "")
        static let activiries = NSLocalizedString("Здесь будут отображаться все ваши уведомления", comment: "")
        static let requests = NSLocalizedString("Здесь будут отображаться запросы на это желание/n Ждите, когда люди откликнуться", comment: "")
        static let search = NSLocalizedString("Увы.. по вашему запросу ничего не найдено", comment: "")
        static let connects = NSLocalizedString("Исполняйте желания с вашими единомышленниками для пополнения коннектов", comment: "")
        static let rooms = NSLocalizedString("Здесь будут ваши чаты", comment: "")
        static let moments = NSLocalizedString("В этом желаний еще нет моментов", comment: "")
        static let city_moments = NSLocalizedString("В этом городе пока нет моментов", comment: "")
    }
    
}
