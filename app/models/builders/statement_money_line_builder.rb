module Builders

  class StatementMoneyLineBuilder

    def self.build(params)
      StatementMoneyLine.create!(params)
    end

  end
end
