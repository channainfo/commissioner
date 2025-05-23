# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramSyncInventoryItemExceptionSender do
  describe '#call' do
    let(:chat_id) { '123456789' }
    let(:telegram_client) { double('Telegram::Bot::Client') }
    let(:line_item_ids) { [1, 2, 3] }
    let(:inventory_id_and_quantities) { [{ inventory_id: 1, quantity: 2 }, { inventory_id: 2, quantity: 1 }] }
    let(:exception) { StandardError.new('Test error') }
    let(:context) do
      double('Context',
             line_item_ids: line_item_ids,
             inventory_id_and_quantities: inventory_id_and_quantities,
             exception: exception)
    end

    before do
      allow(ENV).to receive(:fetch).with('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil).and_return(chat_id)
      allow(::Telegram).to receive(:bots).and_return({ exception_notifier: telegram_client })
      allow(subject).to receive(:context).and_return(context)
      allow(telegram_client).to receive(:send_message)
    end

    it 'sends a telegram message with the correct parameters' do
      expect(telegram_client).to receive(:send_message).with(
        chat_id: chat_id,
        parse_mode: 'HTML',
        text: kind_of(String)
      )

      subject.call
    end
  end

  describe '#body' do
    let(:line_item_ids) { [1, 2, 3] }
    let(:inventory_id_and_quantities) { [{ inventory_id: 1, quantity: 2 }, { inventory_id: 2, quantity: 1 }] }
    let(:exception) do
      error = StandardError.new('Test error')
      allow(error).to receive(:backtrace).and_return([
        'app/models/test.rb:10:in `method1`',
        'app/controllers/test_controller.rb:20:in `method2`',
        'app/services/test_service.rb:30:in `method3`'
      ])
      error
    end
    let(:context) do
      double('Context',
             line_item_ids: line_item_ids,
             inventory_id_and_quantities: inventory_id_and_quantities,
             exception: exception)
    end

    before do
      allow(subject).to receive(:context).and_return(context)
    end

    it 'generates the correct message body with backtrace' do
      body = subject.send(:body)
      expect(body).to include('<b>InventoryItemSyncer Fails!</b>')
      expect(body).to include("Params: <b>line_item_ids</b>: <pre>#{JSON.pretty_generate(line_item_ids)}</pre>")
      expect(body).to include("Params: <b>inventory_id_and_quantities</b>: <pre>#{JSON.pretty_generate(inventory_id_and_quantities)}</pre>")
      expect(body).to include("Error: <b>message</b>: <pre>#{exception.message}</pre>")
      expect(body).to include("Error: <b>backtrace</b>: <pre>#{subject.send(:backtrace_message, exception)}</pre>")
    end

    context 'when exception has no backtrace' do
      let(:exception) { StandardError.new('Test error') }

      before do
        allow(exception).to receive(:backtrace).and_return([])
      end

      it 'generates the message body without backtrace' do
        body = subject.send(:body)
        expect(body).to include('<b>InventoryItemSyncer Fails!</b>')
        expect(body).to include("Params: <b>line_item_ids</b>: <pre>#{JSON.pretty_generate(line_item_ids)}</pre>")
        expect(body).to include("Params: <b>inventory_id_and_quantities</b>: <pre>#{JSON.pretty_generate(inventory_id_and_quantities)}</pre>")
        expect(body).to include("Error: <b>message</b>: <pre>#{exception.message}</pre>")
        expect(body).not_to include("Error: <b>backtrace</b>")
      end
    end
  end

  describe '#backtrace_message' do
    let(:exception) do
      error = StandardError.new('Test error')
      allow(error).to receive(:backtrace).and_return([
        'app/models/test.rb:10:in `method1`',
        'app/controllers/test_controller.rb:20:in `method2`',
        'app/services/test_service.rb:30:in `method3`',
        'app/other/file.rb:40:in `method4`',
        'app/other/another_file.rb:50:in `method5`',
        'app/other/last_file.rb:60:in `method6`'
      ])
      error
    end

    it 'returns formatted backtrace limited to first 5 lines' do
      result = subject.send(:backtrace_message, exception)
      expect(result).to include('```')
      expect(result.scan(/\* /).count).to eq(5)
      expect(result).to include('* app/models/test.rb:10:in `method1`')
      expect(result).to include('* app/controllers/test_controller.rb:20:in `method2`')
      expect(result).to include('* app/services/test_service.rb:30:in `method3`')
      expect(result).to include('* app/other/file.rb:40:in `method4`')
      expect(result).to include('* app/other/another_file.rb:50:in `method5`')
      expect(result).not_to include('* app/other/last_file.rb:60:in `method6`')
    end

    it 'returns nil when backtrace is empty' do
      allow(exception).to receive(:backtrace).and_return([])
      expect(subject.send(:backtrace_message, exception)).to be_nil
    end
  end

  describe '#chat_id' do
    it 'fetches chat_id from environment variable' do
      expect(ENV).to receive(:fetch).with('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil).and_return('123456789')
      expect(subject.send(:chat_id)).to eq('123456789')
    end
  end

  describe '#telegram_client' do
    it 'returns the exception_notifier telegram bot' do
      expect(::Telegram).to receive(:bots).and_return({ exception_notifier: 'bot_instance' })
      expect(subject.send(:telegram_client)).to eq('bot_instance')
    end
  end
end
