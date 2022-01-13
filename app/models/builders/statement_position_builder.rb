module Builders

  class StatementPositionBuilder

    def self.build(params)
      StatementPosition.create!(params)
    end

  end
end
