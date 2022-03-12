require "date"
require_relative "services"
require "terminal-table"

class Categories
  def initialize
    @cat = Services::Session.new
    @cat.login(credentials: { email: "test7@mail.com", password: "123456" })
    @index_cat = @cat.index_categories[:content]
    @month_var_cat = 5
    @toggle_value = "expense"
    # pp @index_cat = @cat.index_categories[:content].select { |n| n[:transaction_type] == "expense"}
    show_cat(@toggle_value)
  end

  def create_cat; end

  def show_cat(type)
    @date_today = Date.today << @month_var_cat # trae fecha actual y le suma o resta dependiendo
    data_type = @index_cat.select { |n| n[:transaction_type] == type }
    table = Terminal::Table.new # genero tabla
    table.title = "#{type}\n#{@date_today.strftime('%B %Y')}"
    table.headings = ["ID", "Category", "Total"]
    data_type.map do |trs|
      amount = 0
      trs[:transactions].map do |tr|
        amount += tr[:amount] if Date.parse(tr[:date]).strftime("%B %Y") == @date_today.strftime("%B %Y")
      end
      table.add_row [trs[:id], trs[:name], amount]
    end
    puts table
  end

  def update_cat; end

  def delete_cat; end

  def add_to_cat; end

  def toggle_cat
    @toggle_value = @toggle_value == "expense" ? "income" : "expense"
    show_cat(@toggle_value)
  end

  def next_cat
    @month_var_cat -= 1 # resto a la var de ins para avanzar un mes
    show_cat(@toggle_value) # traigo la tabla denuevo pero se actualiza el month_var_cat y avanza
  end

  def preview_cat
    @month_var_cat += 1 # sumo a la var de ins para avanzar un mes
    show_cat(@toggle_value) # traigo la tabla denuevo pero se actualiza el month_var_cat y retrocedo
  end

  def menu_prov
    action = ""
    until action == "exit"
      puts "next | prev | show | toggle"
      action = gets.chomp
      case action
      when "show"
        show_cat(@toggle_value)
      when "next"
        next_cat
      when "prev"
        preview_cat
      when "toggle"
        toggle_cat
      end
    end
  end
end

# menu provisional para testear
app = Categories.new
app.menu_prov
