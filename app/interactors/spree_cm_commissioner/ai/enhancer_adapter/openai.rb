module SpreeCmCommissioner
  module Ai
    module EnhancerAdapter
      module Openai
        def client
          @client ||= OpenAI::Client.new(
            access_token: access_token,
            log_errors: true # Hig
          )
        end

        def enhance_text
          parameters = {
            model: 'gpt-4',
            messages: [
              { role: 'system', content: 'You are a helpful assistant.' },
              { role: 'user', content: prompt }
            ],
            max_tokens: max_token_count
          }
          response = client.chat(parameters: parameters)
          response.dig('choices', 0, 'message', 'content').strip
        end

        def prompt
          #  "Provide a summary for the following event: #{term}"
          prompt_templates[type][lang]
        end

        def token_count
          @token_count ||= OpenAI.rough_token_count(terms)
        end

        # type: rewrite|summay|suggest
        # Rewrite: For clarity and improvement
        # Summarize: For conciseness
        # Suggest: For engagement or promotion
        def prompt_templates
          @prompt_template ||= {
            rewrite: {
              en: "rewrite: #{terms}",
            },
            suggest: {
              en: "suggest: #{terms}",
            },
            summarise: {
              en: "summarise: #{terms}",
            },
          }
        end

        def access_token
          ENV.fetch('OPENAI_API_KEY', '')
        end
      end
    end
  end
end
