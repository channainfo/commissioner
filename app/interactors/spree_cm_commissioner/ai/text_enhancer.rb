module SpreeCmCommissioner
  module Ai
    class TextEnhancer
      include Interactor
      include ::SpreeCmCommissioner::Ai::EnhancerAdapter::Openai

      delegate :terms, :type, to: :context

      # type: rewrite|summarize|suggest
      # rewrite: For clarity and improvement
      # summarise: For conciseness
      # suggest: For engagement or promotion
      def call
        context.enhanced_text = nil
        ensure_max_token_count
        context.enhanced_text = enhance_text
      rescue StandardError => e
        context.fail!(message: e.message)
      end

      def lang
        return default_lang unless defined?(context.lang)
        return context.lang if supported_langs.include?(context.lang)

        default_lang
      end

      def max_token_count
        return default_max_token_count unless defined?(context.max_token_count)
        return context.max_token_count if context.max_token_count < default_max_token_count

        default_max_token_count
      end

      def ensure_max_token_count
        return if token_count <= max_token_count

        context.fail!(message: "Token length = #{token_count} is greater than #{max_token_count}")
      end

      def default_lang
        :en
      end

      def default_max_token_count
        150
      end

      def supported_langs
        %i[en es]
      end
    end
  end
end
