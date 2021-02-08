from os import path
from requests import Session
from urllib.parse import quote
from bs4 import BeautifulSoup

import json

USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 YaBrowser/20.11.3.268 (beta) Yowser/2.5 Safari/537.36'
AUTH_FILENAME = 'auth.json'
REQUESTS_FILENAME = 'requests.json'


class Request:

    def __init__(self, auth, requests):

        self.result = []
        self.response = {}

        self.auth = auth
        self.base_url = requests['base_url']

        # Создаём сессию
        self.__session = Session()
        # Получае куки в заголовке
        self.__get_cookie
        # Выполняем запросы
        if self.response.status_code == 200:
            self.execute_requests(requests['requests'])
        else:
            print(f'Ошибка:{self.response["status_code"]}')

    @property
    def __get_cookie(self):
        self.response = self.__session.get(
            self.base_url, headers={'UserAgent': USER_AGENT})

    def execute_requests(self, requests):
        for request in requests:

            query_filename_path = path.join(
                self.auth['sql_path'], request['query_filename'])
            # Считываем sql-запрос
            with open(query_filename_path, 'r') as f:
                query = f.read()
                query = query.replace(
                    '@supplier_id', f'{self.auth["supplier_id"]}')
                query = query.replace('\n', ' ')
                request['query'] = query

            # Выполняем Post запрос
            self.postRequest(request)
            self.save_to_csv(request['filename'], self.response.text)

    @staticmethod
    def convert_value(value):
        result = value.replace('.', ',') if value.count(
            '.') < 2 and value.replace(".", "").isdigit() else value
        for char in ('\t', '\r', '\n'):
            result = result.replace(char, " ")

        return result

    def save_to_csv(self, filename, html):

        # ; \t, \r, \n
        soup = BeautifulSoup(html, "lxml")

        rows = soup.findAll("tr")
        filename_path = path.join(self.auth['csv_path'], filename)
        with open(filename_path, "w", newline="", encoding=self.auth['file_encoding']) as f:
            for cell in rows:

                elem = self.auth['file_separators'].join(
                    [self.convert_value(text.get_text()) for text in cell])
                # elem = cell.get_text(self.auth['file_separators'])
                f.write(elem+'\n')

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
        result = selector_result[len(selector_result)-1].attrs['value']
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
        username = self.auth['username']
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

        # # Вход успешно воспроизведен и мы сохраняем страницу в html файл
        # with open("result.html", "w", encoding="utf-8") as f:
        #     f.write(self.response.text)

        # pass


if __name__ == '__main__':

    # Считываем данные авторизации
    with open(AUTH_FILENAME, 'r') as f:
        AUTH_DATA = json.load(f)

    # Считываем данные авторизации
    with open(REQUESTS_FILENAME, 'r') as f:
        REQUESTS_DATA = json.load(f)

    Request(auth=AUTH_DATA, requests=REQUESTS_DATA)
