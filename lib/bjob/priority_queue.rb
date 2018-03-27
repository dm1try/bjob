module BJob
  class PriorityQueue
    include MonitorMixin

    UNUSED_ITEM = nil

    def initialize(comparator: nil)
      super()
      @empty_condition = new_cond

      @comparator = comparator || ->(first, second) { first <=> second }
      @items = [UNUSED_ITEM]
    end

    def push(item)
      synchronize do
        @items << item
        swim(@items.size - 1)
        @empty_condition.signal
      end
    end

    def pop
      synchronize do
        @empty_condition.wait_while { @items.size == 1 }

        exchange(1, @items.size - 1) if @items.size > 2
        max = @items.pop
        sink(1) if @items.size > 2
        max
      end
    end

    private

    def swim(k)
      while (k > 1 && less(k/2, k))
        exchange(k, k/2)
        k = k/2
      end
    end

    def sink(k)
      while (2*k <= @items.size)
        j = 2*k
        j +=1 if ((j < @items.size - 1) && less(j, j+1))
        break if !less(k, j)
        exchange(k, j)
        k = j
      end
    end

    def less(first, second)
      @comparator.call(@items[first], @items[second]) < 0
    end

    def exchange(first, second)
      @items[first], @items[second] = @items[second], @items[first]
    end
  end
end
