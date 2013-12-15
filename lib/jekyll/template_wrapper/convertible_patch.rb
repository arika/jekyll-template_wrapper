module Jekyll
  module TemplateWrapper
    module LiquidWrappedConvertible
      def read_yaml(*args)
        ret = super
        if converter.respond_to?(:wrap!)
          self.content = converter.wrap!(self.content)
        end
        ret
      end
    end
  end

  module Convertible
    prepend TemplateWrapper::LiquidWrappedConvertible
  end
  [Page, Post, Excerpt, Layout].each do |cls|
    cls.instance_eval { include Convertible } # NOTE: applies patch existing classes
  end
end
