module Builders

  class StatementChargeBuilder

    def self.build(params)
      StatementCharge.create!(params)
    end

  end
end
