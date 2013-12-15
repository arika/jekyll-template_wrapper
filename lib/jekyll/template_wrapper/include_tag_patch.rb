module Jekyll
  module TemplateWrapper
    module LiquidWrappedInclude
      # ファイルに対するコンバータを
      # 検索するために使うクラス
      class PartialLiquidWrapper
        include Jekyll::Convertible

        attr_accessor :content, :data, :ext, :output
        attr_reader :site, :name, :path

        def initialize(path, context)
          @path = path
          @context = context
          @site ||= @context.registers[:site]
          @ext = File.extname(@path)
        end

        def wrap!(text)
          unless converter.respond_to?(:wrap!)
            return text
          end
          converter.wrap!(text)
        end
      end # class PartialLiquidWrapper

      # liquidテンプレートに変換する
      # 直前で呼び出されるsourceメソッドをフックする。
      #
      # コンバータを検索し、
      # コンバータに応じたliquidタグが
      # 設定されていれば、
      # それによってインクルードした
      # ファイルのコンテンツを包んで返す。
      #
      # このメソッドの呼び出しの後で
      # liquidテンプレートのコンパイルが行われる。
      def source(file, context)
        Jekyll.logger.debug('IncludeTag:', "loading #{file.inspect}")
        PartialLiquidWrapper.new(file, context).wrap!(super)
      end
    end # module LiquidWrappedInclude
  end # module TemplateWrapper

  module Tags
    class IncludeTag
      prepend Jekyll::TemplateWrapper::LiquidWrappedInclude
    end
  end
end
