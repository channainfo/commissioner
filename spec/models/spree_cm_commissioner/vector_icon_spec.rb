require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VectorIcon, type: :model do
  describe '.initialize' do
    context 'for base file name' do
      it 'construct correct attributes on base path' do
        path = 'backend-keyboard.svg'
        icon = SpreeCmCommissioner::VectorIcon.new(path: path)

        expect(icon.path).to eq path
        expect(icon.set_name).to eq 'backend'
        expect(icon.icon_name).to eq 'keyboard'
      end

      it 'construct correct attributes on more "-" on base path' do
        path = 'backend-arrow-up-down.svg'
        icon = SpreeCmCommissioner::VectorIcon.new(path: path)

        expect(icon.path).to eq path
        expect(icon.set_name).to eq 'backend'
        expect(icon.icon_name).to eq 'arrow-up-down'
      end

      it 'construct correct attributes on unstructured base path' do
        path = 'backend-arrow_up_down.svg'
        icon = SpreeCmCommissioner::VectorIcon.new(path: path)

        expect(icon.path).to eq path
        expect(icon.set_name).to eq 'backend'
        expect(icon.icon_name).to eq 'arrow_up_down'
      end

      # Instead, make sure to give SET as the prefix with "-", eg. "backend-"
      it 'construct incorrect attributes on invalid base path' do
        path = 'backend_arrow_up_down.svg'
        icon = SpreeCmCommissioner::VectorIcon.new(path: path)

        expect(icon.path).to eq path
        expect(icon.set_name).to eq 'backend_arrow_up_down'
        expect(icon.icon_name).to eq 'backend_arrow_up_down'
      end
    end

    context 'for parent path' do
      it 'construct correct attributes on nested path' do
        path = 'no-icon/backend-move.svg'
        icon = SpreeCmCommissioner::VectorIcon.new(path: path)

        expect(icon.path).to eq path
        expect(icon.set_name).to eq 'backend'
        expect(icon.icon_name).to eq 'move'
      end

      it 'construct correct attributes on root nest path' do
        path = '/heroku/central_market/commissioner/app/assets/images/cm-let-drawing.svg'
        icon = SpreeCmCommissioner::VectorIcon.new(path: path)

        expect(icon.path).to eq path
        expect(icon.set_name).to eq 'cm'
        expect(icon.icon_name).to eq 'let-drawing'
      end
    end

  end
end