require_relative 'observer'
require 'fileutils'
require 'logger'

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
          FileUtils.mkdir_p File.dirname(@file)
          File.open(@file, File::WRONLY | File::APPEND | File::CREAT) do |file|
            logger = Logger.new(file)
            logger << values.
              map(&value_mapper).
              join(splitter) 
            logger << "\n"
          end
        end

        def file= f
          warn("Warning! Log file #{@file} was already set!") if @file
          @file = f
        end

        def display
          if @file
            File.open(@file, File::RDONLY) {|f| f.read }
          else
            ""
          end
        end

        def values
          if @file
            File.open(@file, File::RDONLY) {|f| f.readlines}.map(&:chomp).map do |line|
              if line.empty?
                nil
              else
                line.split(splitter).map(&value_mapper)
              end
            end.compact
          else
            []
          end
        end

        def purge
          File.delete(@file) if File.exist? @file
          @file = nil
        end

        private
        def splitter
          "\t\t"
        end

        def value_mapper
          ->v{
            case v
            when nil
              "nil"
            when "nil"
              nil
            when Symbol
              v.inspect
            when ->val{ val.is_a?(String) && val =~ /\A:/ }
              v[1..-1].to_sym
            else
              v
            end
          }
        end
      end
    end
  end
end
