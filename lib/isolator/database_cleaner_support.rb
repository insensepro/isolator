# frozen_string_literal: true

transaction_class = ::DatabaseCleaner::ActiveRecord::Transaction if defined?(::DatabaseCleaner::ActiveRecord::Transaction)
transaction_class = ::DatabaseCleaner::Sequel::Transaction if defined?(::DatabaseCleaner::Sequel::Transaction)

transaction_class.prepend(
  Module.new do
    def start
      super
      connection_id = connection_class.connection.object_id
      Isolator.set_connection_threshold(
        Isolator.transactions_threshold(connection_id) + 1,
        connection_id
      )
    end

    def clean
      connection_id = connection_class.connection.object_id
      Isolator.set_connection_threshold(
        Isolator.transactions_threshold(connection_id) - 1,
        connection_id
      )
      super
    end
  end
)
