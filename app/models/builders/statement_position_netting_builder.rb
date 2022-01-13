module Builders
  class StatementPositionNettingBuilder

    def self.build(params)
      StatementPositionNetting.create!(params)
    end

  end
end