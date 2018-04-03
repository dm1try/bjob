module BJob
  class PriorityQueue
    UNUSED_ITEM = nil

    def initialize(comparator: nil)
      @comparator = comparator || ->(first, second) { first <=> second }
      @items = [UNUSED_ITEM]
    end

    def push(item)
      @items << item
      swim(@items.size - 1)
    end

    def pop
      exchange(1, @items.size - 1) if @items.size > 2
      max = @items.pop
      sink(1) if @items.size > 2
      max
    end

    def size
      @items.size - 1
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
