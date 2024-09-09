module SpreeCmCommissioner
  module Admin
    module GuestHelper
      def badge_color_based_on_gender(gender)
        case gender
        when 'male'
          'badge-primary'
        when 'female'
          'badge-danger'
        when 'other'
          'badge-secondary'
        else
          ''
        end
      end

      def badge_color_base_on_id_card_status(id_card)
        case id_card
        when 'national_id_card'
          'badge-primary'
        when 'student_id_card'
          'badge-warning'
        when 'passport'
          'badge-success'
        else
          ''
        end
      end

      def badge_color_base_on_entry_type(entry_type)
        case entry_type
        when 1
          'badge-success'
        else
          'badge-secondary'
        end
      end

      def badge_color_base_on_check_in_type(check_in_type)
        case check_in_type
        when 'pre_check_in'
          'badge-danger'
        when 'walk_in'
          'badge-warning'
        else
          'badge-info'
        end
      end

      def badge_color_base_on_check_in_method(check_in_method)
        case check_in_method
        when 'manual'
          'badge-primary'
        when 'scan'
          'badge-warning'
        when 'sensor'
          'badge-success'
        when 'nfc'
          'badge-secondary'
        else
          'badge-info'
        end
      end
    end
  end
end
