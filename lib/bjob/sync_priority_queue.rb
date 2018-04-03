require_relative 'priority_queue'

module BJob
  class SyncPriorityQueue < PriorityQueue
    include MonitorMixin

    def initialize(*args)
      super(*args)
      @empty_condition = new_cond
    end

    def push(item)
      synchronize do
        super(item)
        @empty_condition.signal
      end
    end

    def pop
      synchronize do
        @empty_condition.wait_while { @items.size == 1 }

        super
      end
    end
  end
end
