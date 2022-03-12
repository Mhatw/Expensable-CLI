# Start here. Happy coding!

class Expensable
  def initialize; end

  def start
    prompt_sf("Welcome to Expensable") # prompt welcome
    show_get_do_actions # show options and start loop
  end

  def show_get_do_actions
    action = ""
    until action == "exit"
      print "login | create_user | exit\n> "
      action = gets.chomp
      case action
      when "login"
        puts "login"
      when "create_user"
        puts "createn"
      when "exit"
        prompt_sf("Thanks for using Expensable") # prompt goodbye
      else
        puts "Invalid option"
      end
    end
  end

  def prompt_sf(prompt)
    space = prompt.size < 34 ? (34 - prompt.size) / 2 : 0
    puts "#{'#' * 36}\n##{' ' * space}#{prompt} #{' ' * space}#\n#{'#' * 36}"
  end
end

app = Expensable.new
app.start
