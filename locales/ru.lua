return {
    asserts = {
        src = 'Источник запроса равен nil',
        key = 'Игрок: %s | Ключ мэрии равен nil',
        license = 'Игрок: %s | Лицензия равна nil',
        cityhall = 'Игрок: %s | Ключ, указанный для Config.Cityhalls, не существует',
        no_licenses = 'Игрок: %s | Для этой мэрии не настроены лицензии',
        license_config_missing = 'Игрок: %s | Для указанной лицензии нет конфигурации | %s',
        cityhall_too_far = 'Игрок: %s | Игрок слишком далеко от мэрии',
        job_doesnt_exist = 'Игрок: %s | Работа: %s | не существует в Config.AvailableJobs'
    },
    notify = {
        no_cash = 'У вас при себе недостаточно денег: нужно %s наличными',
        too_far = 'Вы слишком далеко от мэрии.',
        inventory_full = 'Ваш инвентарь заполнен.',
        license_unavailable = 'Эта лицензия недоступна.',
        job_applied = 'Вы успешно устроились на работу.'
    },
    menus = {
        license_cost = 'Цена: $%s',
        job_center = 'Центр занятости',
        apply_job = 'Устроиться на эту работу',
        city_hall = 'Мэрия',
        city_hall_icon = 'fas fa-city',
        id_card = 'Удостоверение личности',
        id_card_desc = 'Получите удостоверение личности',
        job_center_desc = 'Доступные вакансии',
        purchase = 'Купить',
        apply = 'Устроиться',
        confirm_purchase = 'Купить «%s» за $%s?',
        confirm_apply = 'Устроиться на работу «%s»?',
    }
}
