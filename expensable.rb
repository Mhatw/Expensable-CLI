require "date"
require_relative "src/services"
require_relative "src/extra"
require_relative "src/categories"

# rubocop:disable Metrics/ClassLength
class Expensable
  include Extra
  include Services
  attr_accessor :style

  def initialize
    @style = Colorizator
    @session = Session.new
    @current_date = Date.today
  end

  def start
    show_get_do_actions # show options and start loop
  end

  def show_get_do_actions
    loop do
      clear_screen
      prompt_sf("Welcome to Expensable") # prompt welcome
      puts
      puts style.view("login | create_user | exit", bold: false, italic: true)
      print "> "
      case gets.chomp.downcase
      when "login"
        Categories.new(@session, @current_date) if login
      when "create_user"
        Categories.new(@session, @current_date) if create
      when "exit"
        logout
        break
      else
        puts error_m("\tInvalid option")
        sleep(0.5)
      end
    end
  end

  def login
    puts
    email = ask_something("Email: ", "Cannot be blank") { |x| !x.empty? }
    password = ask_something("Password: ", "Cannot be blank") { |x| !x.empty? }
    loading(3)
    tsession = @session.login(credentials: { email: email, password: password })
    if tsession[:code] == 200
      tusername = "#{tsession[:content][:first_name]} #{tsession[:content][:last_name]}"
      print style.view("\tWelcome back ", :green)
      puts style.view(tusername, :green, bold: true)
      true
    else
      puts error_m("\t#{tsession[:content][:errors][0]}")
      false
    end
  ensure
    sleep(1)
  end

  def create
    puts
    tsession = @session.create_user(user_data: define_new_user)
    loading(3)
    if tsession[:code] == 201
      tusername = "#{tsession[:content][:first_name]} #{tsession[:content][:last_name]}"
      print style.view("\tWelcome Expensable ", :green)
      puts style.view(tusername, :green, bold: true)
      true
    else
      puts error_m("\t#{tsession[:content][:errors][0]}")
      false
    end
  ensure
    sleep(1)
  end

  def logout
    clear_screen
    @session.logout
    prompt_sf("Thanks for using Expensable") # prompt goodbye
    sleep(2)
    clear_screen
  end

  private

  def prompt_sf(prompt)
    space = prompt.size < 34 ? (34 - prompt.size) / 2 : 0
    puts "#{'#' * 36}\n##{' ' * space}#{prompt} #{' ' * space}#\n#{'#' * 36}"
  end

  def ask_something(m_presentation, m_error = nil, &block)
    something = ""
    loop do
      print enfatize_m(m_presentation)
      something = gets.chomp
      break if block.nil? || block.call(something)

      puts "\t#{error_m(m_error)}"
    end
    something
  end

  def define_new_user
    user_data = {
      email: ask_something("Email: ", "Invalid format") { |x| !x.match(/\A\w+@\w+.\w{2,3}\z/).nil? },
      password: ask_something("Password: ", "Minimun 6 characters") { |x| x.length >= 6 },
      first_name: ask_something("First name: "),
      last_name: ask_something("Last name: ")
    }
    phone = ask_something("Phone: ", "Required format: +51 111222333 or 111222333") do |x|
      x.empty? || x.match(/\A(\+\d{2} )?\d{9}\z/)
    end
    user_data.merge!({ phone: phone }) unless phone.empty?
    user_data
  end

  def error_m(message)
    style.view(message, :red, bold: true, italic: true)
  end

  def enfatize_m(message)
    style.view(message, bold: true)
  end
end
# rubocop:enable Metrics/ClassLength

app = Expensable.new
app.start
