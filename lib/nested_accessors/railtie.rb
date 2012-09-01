module NestedAccessors
  class Railtie < Rails::Railtie
    initializer 'nested_accessors' do
      ActiveSupport.on_load :active_record do
        include NestedAccessors
      end
    end
  end
end
