#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'leprosorium.db'
  @db.results_as_hash = true
end

# before вызывается каждый раз при перезагрузке
# любой страницы

before do
  # инициализация базы данных
  init_db
end

# configure вызывается каждый раз при конфигурации приложения:
# когда изменился код программы И перезагрузилась страница

configure do
  # инициализация базы данных

  init_db

  # создает таблицу если таблица не существует
  @db.execute 'create table if not exists Posts
  (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_date DATE,
      content TEXT
  )'
end

get '/' do

  # выбираем список постов из БД

  @results = @db.execute 'select * from Posts order by  id desc'

	erb :index
end

# обработчик get-запроса /new
# (браузер отправляет данные на сервер)
get '/new' do
  erb :new
end

# обработчик post-запроса /new
post "/new" do

  # получаем переменную из post-запроса
  content = params[:content]

  if content.length <= 0
    @error = 'Type post text'
    return erb :new
  end

  # сохранение данных в бд

  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

  # перенаправление на главную страницу

  redirect to '/'
  erb "You typed: #{content}"
end

