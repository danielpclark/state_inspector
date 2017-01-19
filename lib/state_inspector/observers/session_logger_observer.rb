require_relative 'observer'

module StateInspector
  module Observers
    module SessionLoggerObserver
      class << self
        include Observer
        def update *values
          @file ||= File.open(['session', Time.now.to_i, 'log'].join('.'), File::WRONLY | File::APPEND)
          @logger ||= Logger.new(file)
          @logger << values.join(splitter)
        end

        def display
          if @file
            File.open(@file).read 
          else
            ""
          end
        end

        def values
          if @file
            File.open(@file).readlines.map(&:chomp).map  do |line|
              if line.empty?
                nil
              else
                line.split(splitter)
              end
            end
          else
            []
          end
        end

        private
        def splitter
          "\t\t"
        end
      end
    end
  end
end
