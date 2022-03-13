require "date"
require_relative "services"
require_relative "extra"
require_relative "m_transactions"
require "terminal-table"

class Transactions
  include Mtransactions
  include Extra
  attr_accessor :style

  def initialize(session = nil, category, month)
    @style = Colorizator
    @tr = session.nil? ? Services::Session.new : session
    @tr.login(credentials: { email: "test7@mail.com", password: "123456" })
    # @date_today = date
    @@month_var = month # variable para selector de mes +1 retrocede -1 avanza en 4 para ver data 0 es actual
    @category = category # var de ins por si se necesita el id de la cat
    @index_tr = @tr.index_transactions(category_id: @category) # Guardo info de index provisional pa obtener name
    @cat_tr = @tr.show_category(category_id: @category) # guardo info de trs en memoria
    menu_tr
  end

  def show_tr
    @@date_today = Date.today << @@month_var # trae fecha actual y le suma o resta dependiendo
    table = Terminal::Table.new # genero tabla
    table.title = "#{@cat_tr[:content][:name]}\n#{@@date_today.strftime('%B %Y')}"
    table.headings = ["ID", "Date", "Amount", "Notes"]
    @index_tr[:content].map do |trs|
      dat = Date.parse(trs[:date])
      if dat.strftime("%B %Y") == @@date_today.strftime("%B %Y") # valido el mes y año a mostrar
        table.add_row [trs[:id], dat.strftime("%a, %b %d"), trs[:amount],
                       trs[:notes]]
      end
    end
    puts table
  end

  def add_tr
    new_trs = add_to_info_tr
    new_trs_on = @tr.create_transaction(category_id: @category, new_data: new_trs)
    @index_tr[:content] << new_trs_on[:content]
    # show_tr
  end

  def update_tr(id)
    new_trs = add_to_info_tr
    @tr.update_transaction(@category, id, new_trs)
    (@index_tr[:content].select { |n| n[:id] == id.to_i })[0][:amount] = new_trs[:amount]
    (@index_tr[:content].select { |n| n[:id] == id.to_i })[0][:notes] = new_trs[:notes]
    (@index_tr[:content].select { |n| n[:id] == id.to_i })[0][:date] = new_trs[:date]
    # show_tr
  end

  def delete_tr(id)
    @tr.delete_transaction(category_id: @category, transaction_id: id)
    @index_tr[:content].delete_if { |dd| dd[:id] == id }
    # show_tr
  end

  def next_tr
    @@month_var -= 1 # resto a la var de ins para avanzar un mes
    # show_tr # traigo la tabla denuevo pero se actualiza el month_var y avanza
  end

  def preview_tr
    @@month_var += 1 # sumo a la var de ins para avanzar un mes
    # show_tr # traigo la tabla denuevo pero se actualiza el month_var y retrocedo
  end

  def menu_tr
    action = ""
    until action == "back"
      clear_screen
      show_tr
      print "add | update ID | delete ID\nnext | prev | back\n> "
      action = gets.chomp
      if action == "next"
        next_tr
      elsif action == "prev"
        preview_tr
      elsif action == "add"
        add_tr
      elsif action.include? "update"
        id_validation(action)[1] == false ? update_tr(id_validation(action)[0]) : (puts "Not Found")
      elsif action.include? "delete"
        id_validation(action)[1] == false ? delete_tr(id_validation(action)[0]) : (puts "Not Found")
      elsif action != "back"
        color_error("Invalid option")
      end
    end
  end
end
