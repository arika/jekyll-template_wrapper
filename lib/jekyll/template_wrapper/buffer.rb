module Jekyll
  module TemplateWrapper
    # wrapされたテンプレートをコンパイルする際の
    # バインディングのためのクラス
    #
    # 以下のローカル変数やメソッドを
    # 設定した上でHAMLコンパイルを実行する。
    #
    #  * content - 処理中のページや
    #    レイアントのコンテンツ
    #
    #    liquidテンプレート中でのcontentと同じ。
    #
    #  * _(key) - contextへのショートカット
    #
    #    _('page.title')はliquidでの
    #    {{ page.title }} に相当する。
    #
    #    また _('page.title', :filter1, :filter2) は
    #    {{ page.title | filter1 | filter2 }} に、
    #    _('page.title', filter1: 'arg1', filter2: 'arg2') は
    #    {{ page.title | filter1 arg1 | filter2 arg2 }} に、
    #    それぞれ相当する。
    #
    #  * page - _('page')へのショートカット
    #
    #  * site - _('site')へのショートカット
    #
    #  * _* - フィルタを呼び出す
    #
    #    以下のようにフィルタ名に +_+ を前置すると、
    #    そのフィルタを直接呼び出すことができる。
    #
    #        = _date_to_string(Time.now)
    #
    #    フィルタにオプションを渡すには
    #    次のようにする。
    #
    #        = _array_join(%w(foo bar baz), ', ')
    #
    #  * liquid_include - jekyllのincludeタグを呼び出す
    #
    #        = liquid_include 'foo.haml', foo: 'bar', ...
    #
    #    foo.hamlを読み込む。ローカル変数としてfooを設定する。
    #    foo.hamlの中では_('include.foo')によって参照できる。
    #    (liquidレベルでも {{ includde.foo }} のように参照できる。)
    #
    #  * その他のliquid_* - liquidタグを呼び出す
    #
    #    liquidテンプレート中でのタグ名に
    #    +liquid_+ を前置する。
    #    タグの引数はliquidテンプレートでの
    #    記述方法と同じ。
    #
    #        =liquid_gist '1234567 file.rb'
    #
    #    第二引数以降を指定した場合には
    #    空白(0x20)で連結してliquidタグに渡す。
    #    上の例と下の例は同じ結果になる。
    #
    #        =liquid_gist '1234567', 'file.rb'
    #
    class Buffer
      def initialize(context)
        @context = context
      end
      attr_reader :context

      [:content, :page, :site].each do |sym|
        define_method(sym) do
          context[sym.to_s]
        end
      end

      def _(key, filters = {})
        filters.inject(context[key]) do |output, (fname, fargs)|
          context.invoke(fname.to_s, output, *fargs)
        end
      end

      # jekyllyのinlcudeタグの
      # ローカルパラメータ機能をエミュレートする
      #
      # loacalsにはハッシュを与える。
      # includeされた側のテンプレートでは
      # context['include.<key>']によって
      # HAMLレベルでも参照できる。
      # ただし値はハッシュ化(to_liquid)されてしまうことに注意。
      def liquid_include(name, locals = {})
        locals = locals.inject({}) {|h, (k, v)| h[k.to_s] = v; h }
        tag_class = Liquid::Template.tags['include']
        @context.stack do
          @context['include'] = locals unless locals.empty?
          tag_class.new('include', name, []).render(@context)
        end
      end

      def method_missing(sym, *args)
        case sym.to_s
        when /\Aliquid_/ # liquidタグの呼び出し
          tag_name = $'
          tag_class = Liquid::Template.tags[tag_name]
          if tag_class <= Liquid::Block ||
              !(tag_class <= Liquid::Tag)
            return super
          end
          tag_class.new(tag_name, args.join(' '), []).render(@context)

        when /\A_(.+)/ # liquidフィルタの呼び出し
          unless context.strainer.invokable?($1)
            #Jekyll.logger.info "Unknown liquid filter \"#{$1}\" in #{context['page.path']}"
          end
          context.invoke($1, *args)

        else
          return super
        end
      end
    end # class Buffer
  end # module TemplateWrapper
end
