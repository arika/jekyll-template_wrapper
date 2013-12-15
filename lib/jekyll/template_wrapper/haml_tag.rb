require 'haml'

Haml::Options.defaults[:format] = :html5
# 実装の都合上、「=」などで使うメソッドが
# <pre>を含むことがあり
# このときHAMLによるインデントが
# 行われと都合が悪いのでuglyモードにする
Haml::Options.defaults[:ugly] = true

module Jekyll
  module TemplateWrapper
    # foo.hamlを処理するためのコンバータ
    #
    # ただしHAMLコンパイルは
    # このコンバータでは実施せず、
    # コンテンツの前後に
    # liquidタグの挿入のみ行う。
    #
    # HAMLテキストからのコンパイルは
    # jekyllによるliquidテンプレートの
    # コンパイルの中で実施される。
    class HamConverter < Jekyll::Converter
      safe true
      priority :low

      def matches(ext)
        /\A\.haml\z/i =~ ext
      end

      def output_ext(ext)
        '.html'
      end

      def convert(content)
        content
      end

      # ページやレイアウトのコンテンツを
      # HAML変換するためのliquidタグで包む。
      def wrap!(content)
        '{% haml %}' + content + '{% endhaml %}'
      end
    end # class HamConverter

    class HamlBlock < Liquid::Block
      @@cache = {}
      @@cache_status = {
        hit: 0,
        miss: 0,
        use: {},
      }

      def self.cache_status
        @@cache_status
      end

      def render(context)
        if context.scopes.size == 1
          page = context.registers[:page]
          Jekyll.logger.debug('HamlTag:', "rendering #{page.inspect}")
        end

        haml_text = super
        if @@cache[haml_text]
          @@cache_status[:hit] += 1
          @@cache_status[:use][haml_text] += 1
        else
          @@cache[haml_text] = ::Haml::Engine.new(haml_text)
          @@cache_status[:miss] += 1
          @@cache_status[:use][haml_text] = 1
        end

        @@cache[haml_text].render(Buffer.new(context), context)
      rescue Exception
        Jekyll.logger.debug('HamlTag:', "Exception: #{$!.message} #{$!.class}")
        $!.backtrace.each do |line|
          Jekyll.logger.debug('HamlTag:', "\t#{line}")
        end
        raise
      end
    end # HamlBlock
  end
end

Liquid::Template.register_tag('haml', Jekyll::TemplateWrapper::HamlBlock)

=begin
# DEBUG
END {
  status = HamlBlock.cache_status
  $stderr.puts "haml cache size = #{status[:use].size}"
  $stderr.puts "hit = #{status[:hit]}, miss = #{status[:miss]}"

  status[:use].sort_by {|text, count| [count, text] }.each do |text, count|
    $stderr.puts "-- #{count} --"
    $stderr.puts text
  end
}
=end
