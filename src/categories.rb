require "date"
require "terminal-table"
require_relative "m_categories"
require_relative "services"
require_relative "extra"

class Categories
  include Mcategories
  include Extra
  attr_accessor :style
  def initialize(session = nil, date = Date.today)
    @style = Colorizator
    @cat = session.nil? ? Services::Session.new : session
    @date_today = date
    # @cat.login(credentials: { email: "test7@mail.com", password: "123456" })
    @index_cat = @cat.index_categories[:content]
    @month_var_cat = 5
    @toggle_value = "expense"
    menu
  end

  # new_category: { name: string, transaction_type: expense }
  def create_cat
    new_cat = cat_get_info
    new_cat_on = @cat.create_category(new_category: new_cat)
    @index_cat << new_cat_on[:content]
    loading
    puts style.view("\tCreated success", :green, bold: true, italic: true)
    sleep(1)
    show_cat(@toggle_value)
  end



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

  def update_cat(id)
    upd_cat = cat_get_info
    @cat.update_category(category_id: id, new_data: upd_cat)
    (@index_cat.select { |n| n[:id] == id.to_i })[0][:name] = upd_cat[:name]
    (@index_cat.select { |n| n[:id] == id.to_i })[0][:transaction_type] = upd_cat[:transaction_type]
    show_cat(@toggle_value)
  end

  def delete_cat(id)
    @cat.delete_category(category_id: id)
    @index_cat.delete_if { |dd| dd[:id] == id }
    show_cat(@toggle_value)
  end

  def add_to_cat(id)
    new_trs = add_to_info
    new_trs_on = @cat.create_transaction(category_id: id, new_data: new_trs)
    pp new_trs_on
    (@index_cat.select { |n| n[:id] == id.to_i })[0][:transactions] << new_trs_on[:content]
    show_cat(@toggle_value)
  end

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

  def menu
    action = ""
    until action == "logout"
      clear_screen
      show_cat(@toggle_value)
      puts "create | show ID | update ID | delete ID\nadd-to ID | toggle | next | prev | logout"
      print "> "
      action = gets.chomp
      menu1(action)
    end
  end
end
