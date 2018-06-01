module DiningTable

  module Presenters

    module HTMLPresenterConfiguration

      # configuration classes that allow us to avoid implementing a deep-merge for the config hash,
      # and are more user friendly for use in config blocks in the table definition
      class TagConfiguration

        attr_accessor :__data_hash

        def initialize
          self.__data_hash = {}
        end

        def method_missing(name, *args, &block)
          if name.to_s[-1] == '='
            key = name.to_s[0..-2]   # strip away '='
            __data_hash[ key.to_sym ] = args.first
          else
            __data_hash.key?( name ) ? __data_hash[ name ] : super
          end
        end

        def respond_to_missing?(method_name, *args)
          return true if method_name.to_s[-1] == '='
          __data_hash.key?( method_name ) ? true : super
        end

        # override class method (since it is a very common html attribute), and the method missing approach doesn't
        # work here, as it returns the Ruby class by default.
        def class
          __data_hash.key?( :class ) ? __data_hash[ :class ] : super
        end

        def to_h
          __data_hash
        end

        def merge_hash( hash )
          return self if !hash
          hash.each do |key, value|
            self.send("#{ key }=", value)
          end
          self
        end

        def self.from_hash( hash )
          new.merge_hash( hash )
        end

        # for deep dup
        def initialize_copy( source )
          self.__data_hash = source.__data_hash.dup
        end

      end

      class TagsConfiguration
        TAGS = [ :table, :thead, :tbody, :tfoot, :tr, :th, :td ]
        attr_accessor(*TAGS)

        def initialize
          TAGS.each do |tag|
            self.send("#{ tag }=", TagConfiguration.new)
          end
        end

        def to_h
          hashes = TAGS.map do |identifier|
            self.send(identifier).to_h
          end
          { :tags => Hash[ TAGS.zip( hashes ) ] }
        end

        def merge_hash( hash )
          return self if !hash
          tags = hash[ :tags ]
          TAGS.each do |tag|
            self.send("#{ tag }").merge_hash( tags[ tag ] )
          end if tags
          self
        end

        def self.from_hash( hash )
          new.merge_hash( hash )
        end

        # for deep dup
        def initialize_copy( source )
          TAGS.each do |tag|
            self.send("#{ tag }=", source.send( tag ).dup)
          end
        end

      end

    end

  end

end