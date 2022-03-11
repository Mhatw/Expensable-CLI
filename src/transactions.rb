require "date"
require_relative "services"
require "terminal-table"

class Transactions
  def initialize(category = 56)
    @tr = Services::Session.new
    @tr.login(credentials: { email: "test7@mail.com", password: "123456" }) # validacion provicional
    @month_var = 4 # variable para selector de mes +1 retrocede -1 avanza en 4 para ver data 0 es actual
    @category = category # var de ins por si se necesita el id de la cat
    @index_tr = @tr.index_transactions(category_id: @category) # Guardo info de index provisional pa obtener name
    @cat_tr = @tr.show_category(category_id: @category) # guardo info de trs en memoria
  end

  def show_tr
    @date_today = Date.today << @month_var # trae fecha actual y le suma o resta dependiendo
    table = Terminal::Table.new # genero tabla
    table.title = "#{@cat_tr[:content][:name]}\n#{@date_today.strftime('%B %Y')}"
    table.headings = ["ID", "Date", "Amount", "Notes"]
    @index_tr[:content].map do |trs|
      dat = Date.parse(trs[:date])
      if dat.strftime("%B %Y") == @date_today.strftime("%B %Y") # valido el mes y año a mostrar
        table.add_row [trs[:id], dat.strftime("%a, %b %d"), trs[:amount],
                       trs[:notes]]
      end
    end
    puts table
  end

  def add_tr; end

  def update_tr; end

  def delete_tr; end

  def next_tr
    @month_var -= 1 # resto a la var de ins para avanzar un mes
    show_tr # traigo la tabla denuevo pero se actualiza el month_var y avanza
  end

  def preview_tr
    @month_var += 1 # sumo a la var de ins para avanzar un mes
    show_tr # traigo la tabla denuevo pero se actualiza el month_var y retrocedo
  end
end

# menu provisional para testear
app = Transactions.new
action = ""
until action == "exit"
  puts "next | prev | show"
  action = gets.chomp
  case action
  when "show"
    app.show_tr
  when "next"
    app.next_tr
  when "prev"
    app.preview_tr
  end
end
