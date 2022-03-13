module Mcategories
  def cat_get_info
    category = print_get("Name: ")
    while category == ""
      color_error("Cannot be blank")
      category = print_get("Name: ")
    end

    transaction_type = print_get("Transaction type: ")
    until ["income", "expense"].include?(transaction_type)
      color_error("Only income or expense")
      transaction_type = print_get("Transaction type: ")
    end
    { name: category, transaction_type: transaction_type }
  end

  def color_error(message)
    puts style.view("\t#{message}",:red, italic: true, bold: true)
    sleep(1)
  end

  # new_transaction = { "amount": 2000,"notes": "TestNotes","date": "2020-10-10" }
  def add_to_info
    amount = print_get("Amount: ")
    while amount == "" || !amount.to_i.positive?
      color_error("Cannot be zero")
      amount = print_get("Amount: ")
    end
    date = print_get("Date: ")
    while date == "" || (valid_date(date)) == false
      color_error("Required format: YYYY-MM-DD")
      date = print_get("Date: ")
    end
    notes = print_get("Notes: ")
    { amount: amount.to_i, notes: notes, date: date }
  end

  def print_get(prompt)
    print (style.view(prompt, bold: true))
    gets.chomp
  end

  def valid_date(value)
    y, m, d = value.split "-"
    Date.valid_date? y.to_i, m.to_i, d.to_i
  end

  def id_validation(action_id)
    id = get_id(action_id)
    if id == "no"
      [id.to_i, true]
    else
      [id.to_i, (@index_cat.select { |n| n[:id] == id.to_i }).empty?]
    end
  end

  def get_id(data)
    a = /^\w+-?\w+\s(\d+)$/
    data.match(a).nil? ? "no" : data.match(a)[1]
  end

  def menu1(action)
    if action == "create"
      create_cat
    elsif action == "show"
      show_cat(@toggle_value)
    elsif action == "next"
      next_cat
    elsif action == "prev"
      preview_cat
    elsif action == "logout"
      @cat.logout
    elsif action != ""
      menu2(action)
    else
      color_error("Invalid option")
    end
  end

  def menu2(action)
    if action.include? "update"
      id_validation(action)[1] == false ? update_cat(id_validation(action)[0]) : (puts "Not Found")
    elsif action.include? "delete"
      id_validation(action)[1] == false ? delete_cat(id_validation(action)[0]) : (puts "Not Found")
    elsif action.include? "add-to"
      id_validation(action)[1] == false ? add_to_cat(id_validation(action)[0]) : (puts "Not Found")
    elsif action == "toggle"
      toggle_cat
    else
      color_error("Invalid option")
    end
  end
end
