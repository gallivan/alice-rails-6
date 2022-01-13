module Workers
  class BookerOfItdAbn < Booker

    # should only be one running
    # do this as a singleton?

    def initialize(i_queue)
      @i_queue = i_queue
    end

  end
end