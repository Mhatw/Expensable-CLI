module Mtransactions
  def id_validation(action_id)
    id = get_id(action_id)
    if id == "no"
      [id.to_i, true]
    else
      [id.to_i, (@index_tr[:content].select { |n| n[:id] == id.to_i }).empty?]
    end
  end

  def get_id(data)
    a = /^\w+-?\w+\s(\d+)$/
    data.match(a).nil? ? "no" : data.match(a)[1]
  end

  def color_error(message)
    puts style.view("\t#{message}", :red, italic: true, bold: true)
    sleep(1)
  end

  def valid_date(value)
    y, m, d = value.split "-"
    Date.valid_date? y.to_i, m.to_i, d.to_i
  end

  def print_get(prompt)
    print(style.view(prompt, bold: true))
    gets.chomp
  end

  def add_to_info_tr
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
end
