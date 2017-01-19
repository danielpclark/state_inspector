require_relative 'observer'

module StateInspector
  module Observers
    module SessionLoggerObserver
      class << self
        include Observer
        def update *values
          @file ||= File.join(
              'log', 'state_inspector',
              ['session', Time.now.to_i, 'log'].join('.')
            )
          @logger ||= Logger.new(File.open(file, File::WRONLY | File::APPEND))
          @logger << values.join(splitter)
        end

        def display
          if @file
            File.open(@file, File::RDONLY).read 
          else
            ""
          end
        end

        def values
          if @file
            File.open(@file, File::RDONLY).readlines.map(&:chomp).map do |line|
              if line.empty?
                nil
              else
                line.split(splitter)
              end
            end.compact
          else
            []
          end
        end

        def purge
          File.delete(@file) if File.exist? @file
          @file = nil
          @logger = nil
        end

        private
        def splitter
          "\t\t"
        end
      end
    end
  end
end
