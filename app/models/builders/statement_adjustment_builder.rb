module Builders
  class StatementAdjustmentBuilder
    def self.build(params)
      StatementAdjustment.create!(params)
    end
  end
end
