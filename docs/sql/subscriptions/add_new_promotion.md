# Promotions

Promotions within Spree are used to provide discounts to orders, as well as to add potential additional items at no extra cost.
Promotions relate to two other main components: `actions` and `rules`. When a promotion is activated, the actions for the promotion are performed, passing in the payload from the fire_event call that triggered the activator becoming active. Rules are used to determine if a promotion meets certain criteria in order to be applicable.

### Registering a New Action

1. You can create a new action for Spree's promotion engine by inheriting from Spree::PromotionAction, like this:

```ruby
class CreateGuestItemAdjustments < Spree::PromotionAction
  def perform(options={})
    ...
  end
end
```

2. This action must then be registered with Spree, which can be done by add this class to :`lib/spree_cm_commissioner/engine.rb`

```ruby
Rails.application.config.spree.promotions.actions.concat
[
  SpreeCmCommissioner::Promotion::Actions::CreateGuestItemAdjustments
]
```

3. Create a partial for your new action in

```bash
  app/models/spree_cm_commissioner/promotion/actions/_create_guest_item_adjustments.html.erb
```

4. Once this has been registered, it will be available within Spree's interface. To provide translations for the interface, you will need to define them within your locale file. For instance, to define English translations for your new promotion action, use this code within config/locales/en.yml:

```yml
en:
  spree:
    promotion_action_types:
      create_guest_item_adjustments:
        name: Create guest item adjustment
        description: Performs guest promotion action.
```

### Registering a New Rule

1.  you can create and register a new rule for your Spree app with custom business logic specific to your needs. First, define a class that inherits from Spree::PromotionRule, like this:

```ruby
module SpreeCmCommissioner
 class Promotion
   module Rules
     class Guests < Spree::PromotionRule
       def applicable?(promotable)
         promotable.is_a?(Spree::Order)
       end

       def eligible?(order, options = {})
         ...
       end

       def actionable?(line_item)
         ...
       end
     end
   end
 end
end

```

- The `eligible?` method should then return true or false to indicate if the promotion should be eligible for an order
- If your promotion supports some giving discounts on some line items, but not others, you should define `actionable?` to return true if the specified line item meets the criteria for promotion. It should return true or false to indicate if this line item can have a line item adjustment carried out on it.

2. This rule must then be registered with Spree, which can be done by add this class to :`lib/spree_cm_commissioner/engine.rb`

```ruby
Rails.application.config.spree.promotions.rules.concat
[
  SpreeCmCommissioner::Promotion::Rules::Guests
]
```

3. Create a partial for your new rule in

```bash
  app/views/spree/admin/promotions/rules/guests.html.erb
```

4. And finally, your new rule must have a name and description defined for the locale you will be using it in. For English, edit config/locales/en.yml and add the following to support our new example rule:

```yml
en:
  spree:
    promotion_rule_types:
      guest_occupations:
        name: "Guest Rule"
        description: "Rule to define guest promotion"
```
