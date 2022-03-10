require 'httparty'
require 'json'

module Services
  class Session
    include HTTParty

    def initialize
      self.class.base_uri("https://expensable-api.herokuapp.com/")
      @auth_token = nil
    end
    
    # ------------------------------- USER Services -------------------------------
    # credentials : {username: string, password: string}
    def login(credentials: )
      response = self.class.post('/login', get_options(body: credentials.to_json))
      @auth_token = response.parsed_response["token"] if response.success?
      handling_response(response: response)
    end

    # user_data: { email: string, password: string, first_name: string, last_name: string, phone: string }
    def create_user(user_data: )
      response = self.class.post('/signup', get_options(body: user_data.to_json))
      @auth_token = response.parsed_response["token"] if response.success?
      handling_response(response: response)
    end

    def logout
      @auth_token = nil
    end

    # ------------------------------- CATEGORY Services -------------------------------
    def index_categories
      response = self.class.get("/categories", get_options)
      handling_response(response: response)
    end

    # new_category: { name: string, transaction_type: expense }
    def create_category(new_category: )
      response = self.class.post("/categories", get_options(body: new_category.to_json))
      handling_response(response: response)
    end

    def show_category(category_id: )
      response = self.class.get("/categories/#{category_id}", get_options)
      handling_response(response: response)
    end

    #new_data : { name: string, transaction_type : string }
    def update_category(category_id: , new_data: )
      response = self.class.patch("/categories/#{category_id}", get_options(body: new_data.to_json))
      handling_response(response: response)
    end

    def delete_category(category_id: )
      response = self.class.delete("/categories/#{category_id}", get_options)
      handling_response(response: response)
    end

    # ------------------------------- TRANSACTIONS Services -------------------------------
    def index_transactions(category_id: )
      response = self.class.get("/categories/#{category_id}/transactions", get_options)
      handling_response(response: response)
    end

    # new_data : { amount: integer, notes: string, date: string }
    def create_transaction(category_id:, new_data: )
      response = self.class.post("/categories/#{category_id}/transactions",
                                 get_options(body: new_data.to_json))
      handling_response(response: response)
    end

    def show_transaction(category_id:, transaction_id: )
      response = self.class.get("/categories/#{category_id}/transactions/#{transaction_id}",
                                get_options)
      handling_response(response: response)
    end

    def update_transaction(category_id, transaction_id, transaction_new_data)
      response = self.class.patch("/categories/#{category_id}/transactions/#{transaction_id}",
                                  get_options(body: transaction_new_data.to_json))
      handling_response(response: response)
    end

    def delete_transaction(category_id:, transaction_id:)
      response = self.class.delete("/categories/#{category_id}/transactions/#{transaction_id}", get_options)
      handling_response(response: response)
    end

    private

    def handling_response(response:)
      t_response = { code: response.code }
      raise HTTParty::ResponseError.new(response) unless response.success?
    rescue HTTParty::ResponseError => e
      if e.message.empty?
        t_response.merge!({ content: { errors: ["Element can't be found"] } })
      else
        t_response.merge!({ content: JSON.parse(e.message, symbolize_names: true) })
      end
    else
      case response.code
      when 204
        t_response.merge!({ content: { message: "Operation completed" } })
      else
        t_response.merge!({ content: JSON.parse(response.body, symbolize_names: true) })
      end
    ensure
      return t_response
    end

    # Body -> JSON format
    def get_options(body: nil)
      toptions = { headers: get_headers }
      toptions.merge!({ body: body }) unless body.nil?
      toptions
    end

    def get_headers
      theader = { "Content-Type": "application/json" }
      theader.merge!({ Authorization: "Token token=#{@auth_token}" }) unless @auth_token.nil?
      theader
    end

    def to_s
      "AuthToken: #{@auth_token}"
    end
  end
end

include Services

session = Session.new
new_user = { "email" => "dave@mail.com",
             "password" => "123456",
             "first_name" => "crazy",
             "last_name" => "dave" }
# pp Session.create_user(user_data: new_user)

# pp session.login(credentials: {email: "dave@mail.com", password: "123456"}) # Dave account
# pp session.login(credentials: {email: "test7@mail.com", password: "123456"}) # Group account
pp session.index_categories

new_category = { "name": "TestCategory2",
                 "transaction_type": "expense" }
# pp session.create_category(new_category: new_category)
# pp session.index_categories

# pp session.show_category(category_id: 714)

new_category_data = { "name": "TestCategory5",
                      "transaction_type": "income" }
# pp session.update_category(category_id: 714, new_data: new_category_data)

# pp session.delete_category(category_id: 656)

# pp session.index_transactions(category_id: 56)

new_transaction = { "amount": 2000,
                    "notes": "TestNotes",
                    "date": "2020-10-10" }
# pp session.create_transaction(category_id: 56, new_data: new_transaction)

# pp session.show_transaction(category_id: 56, transaction_id: 448)
new_transaction_data = { "amount": 2000,
                         "notes": "TestNotes",
                         "date": "2020-10-10" }
# pp session.update_transaction(56, 446, new_transaction_data)

# pp session.delete_transaction(category_id: 56, transaction_id: 2838)
