require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramChatsFinder do
  let(:updates) { {
    "ok"=>true,
    "result"=> [
      {
        "update_id"=>31545797,
        "my_chat_member"=> {
          "chat"=>{"id"=>-1001712207468, "title"=>"BookMe+ DEV Exception", "type"=>"channel"},
          "from"=>{"id"=>969777666, "is_bot"=>false, "first_name"=>"Savuth", "last_name"=>"Yuvaneath", "username"=>"va_neath"},
          "date"=>1695185042,
          "old_chat_member"=>{"user"=>{"id"=>6441690414, "is_bot"=>true, "first_name"=>"Contigo Asia", "username"=>"contigoasiabot"}, "status"=>"left"},
          "new_chat_member"=> {
            "user"=>{"id"=>6441690414, "is_bot"=>true, "first_name"=>"Contigo Asia", "username"=>"contigoasiabot"},
            "status"=>"administrator",
            "can_be_edited"=>false,
            "can_manage_chat"=>true,
            "can_change_info"=>true,
            "can_post_messages"=>true,
            "can_edit_messages"=>true,
            "can_delete_messages"=>true,
            "can_invite_users"=>true,
            "can_restrict_members"=>true,
            "can_promote_members"=>false,
            "can_manage_video_chats"=>true,
            "is_anonymous"=>false,
            "can_manage_voice_chats"=>true
          }
        }
      }
    ]
  } }

  it 'return chats matched to telegram_chat_name & telegram_chat_type' do
    subject = described_class.new(telegram_chat_name: 'BookMe+ DEV Exception', telegram_chat_type: 'channel')
    allow(subject).to receive(:fetch_updates).and_return(updates)

    chats = subject.call
    expect(chats).to match({:id=>-1001712207468, :title=>"BookMe+ DEV Exception", :type=>"channel"})
  end

  it 'return empty chats when no matched to telegram_chat_name' do
    subject = described_class.new(telegram_chat_name: 'Wrong name', telegram_chat_type: 'channel')
    allow(subject).to receive(:fetch_updates).and_return(updates)

    chats = subject.call
    expect(chats).to be_empty
  end

  it 'return empty chats when no matched to telegram_chat_type' do
    subject = described_class.new(telegram_chat_name: 'BookMe+ DEV Exception', telegram_chat_type: 'group')
    allow(subject).to receive(:fetch_updates).and_return(updates)

    chats = subject.call
    expect(chats).to be_empty
  end
end
