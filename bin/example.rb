#!/usr/bin/env ruby

module Thing
  def self.included(base)
    class << base
      attr_accessor :foo
      def foo
        @foo ||= 'foo'
      end
    end
  end
end

class A
  include Thing
end

class B < A
end

puts A.foo
puts B.foo
B.foo = "Boo"
puts A.foo
puts B.foo
