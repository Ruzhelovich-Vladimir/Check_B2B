import os.path
from os import path
from requests import Session
from urllib.parse import quote
from bs4 import BeautifulSoup
import csv

import log.log as log
from config.config import settings


USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 YaBrowser/20.11.3.268 (beta) Yowser/2.5 Safari/537.36'
ROOT_DIR = path.dirname(path.abspath(__file__))

class Request:

    def __init__(self, auth, requests):

        self.result = []
        self.response = {}

        self.auth = auth
        self.base_url = auth['base_url']
        self.supplier_name = auth['supplier_name']
        # Создаём сессию
        self.__session = Session()
        # Получае куки в заголовке
        self.__get_cookie()
        # Выполняем запросы
        if self.response.status_code == 200:
            self.execute_requests(requests)
        else:
            logger.error(f'Ошибка:{self.response.status_code}')

    def __get_cookie(self):
        self.response = self.__session.get(
            self.base_url, headers={'UserAgent': USER_AGENT})

    def execute_requests(self, requests):
        for request in requests:
            logger.info(f'   {request["query_filename"]}')
            query_filename_path = path.join(
                ROOT_DIR, 'sql', request['query_filename'])
            # Считываем sql-запрос
            if os.path.isfile(query_filename_path):
                with open(query_filename_path, mode='r') as f:
                    query = f.read()
                    query = query.replace(
                        '@supplier_id', f'{self.auth["supplier_id"]}')
                    query = query.replace('\n', ' ')
                    request['query'] = query
            else:
                logger.warning(f'Файл запроса отсудствует:{query_filename_path} - пропускаем')
                continue

            # Выполняем Post запрос
            self.postRequest(request)
            self.save_to_csv(f'{self.supplier_name}_{request["filename"]}', self.response.text)

    @staticmethod
    def convert_value(value):
        result = value.replace('.', ',') if value.count(
            '.') < 2 and value.replace(".", "").isdigit() else value
        # Удаляю символ табуляции, перевод корректы и строки
        for char in ('\t', '\r', '\n'):
            result = result.replace(char, " ")

        return result

    def save_to_csv(self, filename, html):

        # ; \t, \r, \n
        soup = BeautifulSoup(html, "lxml")

        rows = soup.findAll("tr")
        filename_path = path.join(ROOT_DIR, 'csv_report', filename)
        with open(filename_path, "w", newline="", encoding=self.auth['file_encoding']) as csv_file:
            writer = csv.writer(csv_file, delimiter=self.auth['file_separators'])
            for cell in rows:
                writer.writerow([self.convert_value(text.get_text()) for text in cell])

    @property
    def __get_token(self):
        """Получаем токен формы
        Returns:
            [string]: [Токен формы]
        """
        result = ''
        try:
            selector_result = BeautifulSoup(
                self.response.text, 'lxml').select('input[name="token"]')
        except:
            return result
        if selector_result:
            result = selector_result[len(selector_result)-1].attrs['value']
        else:
            result = ''
        return result

    def __preparation(self, url):
        """Подготавливаем запрос

        Args:
            url ([строка]): [адрес заспроса]
        """
        # На всякий случай восстанавливаем агента
        self.__updateHeaders('User-Agent', USER_AGENT)
        # Иногда требуется указывать атрибут backUrl
        self.__updateHeaders('backUrl', url)
        self.__updateHeaders('referer', url)

    def __updateHeaders(self, key, value):
        """Обновляем  значения атрибут в заголовках
        Args:
            key ([строка]): [Наименование атрибута]
            value ([строка]): [Значение]
        """
        self.__session.headers.update({
            key: value
        })

    def postRequest(self, request):

        server = self.auth['server']
        username = self.auth['login']
        password = self.auth['password']
        db = self.auth['db']
        ns = self.auth['ns']

        # Получаем url
        query_url = quote(request['query'])
        url = f'{self.base_url}?mssql={server}&username={username}&db={db}&ns={ns}&sql={query_url}'
        # Заполняем атрибуты данные
        request['data'] = {}
        # Заполняем атрибут запроса
        request['data']['query'] = request['query']
        # Получаем текущий токен формы или пустую строку
        request['data']['token'] = self.__get_token
        request['data']['limit'] = ''
        request['data']['auth[server]'] = server
        request['data']['auth[username]'] = username
        request['data']['auth[password]'] = password
        request['data']['auth[db]'] = db
        request['data']['auth[ns]'] = ns

        self.__preparation(url)
        # Выполняем запрос
        self.response = self.__session.post(
            url, data=request['data'])

if __name__ == '__main__':

    logger = log.init()
    REQUESTS_DATA = settings['REQUEST_PLAN']
    for AUTH_DATA in settings.CONTROL_SUPPLIER:
        logger.info(f'Обработка поставщика: {AUTH_DATA["supplier_name"]}')
        Request(auth=AUTH_DATA, requests=REQUESTS_DATA)
