module Workers
  class BookerOfEodCme < Booker

    # allow for multiple bookers
    # since multiple packed queues
    # need to be read in parallel

    # def initialize(i_queue)
    #   @i_queue = i_queue
    # end

  end
end