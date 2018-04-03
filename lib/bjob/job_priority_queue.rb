require_relative 'sync_priority_queue'

module BJob
  class JobPriorityQueue < SyncPriorityQueue
    def initialize
      super(comparator: ->(first, second) { first['priority'] <=> second['priority'] } )
    end
  end
end
