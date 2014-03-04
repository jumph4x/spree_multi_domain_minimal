module SpreeMultiDomainMinimal
  class Engine < Rails::Engine
    engine_name 'spree_multi_domain_minimal'

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      ['app', 'lib'].each do |dir|
        Dir.glob(File.join(File.dirname(__FILE__), "../../#{dir}/**/*_decorator*.rb")) do |c|
          Rails.application.config.cache_classes ? require(c) : load(c)
        end
      end

      ApplicationController.send :include, SpreeMultiDomainMinimal::MultiDomainHelpers
    end

    config.to_prepare &method(:activate).to_proc

    initializer "current order decoration" do |app|
      require 'spree/core/controller_helpers/order'
      ::Spree::Core::ControllerHelpers::Order.module_eval do
        def current_order_with_multi_domain(create_order_if_necessary = false)
          current_order_without_multi_domain(create_order_if_necessary: create_order_if_necessary)

          if @current_order and current_store and @current_order.store.nil?
            @current_order.update_attribute(:store_id, current_store.id)
          end

          @current_order
        end
        alias_method_chain :current_order, :multi_domain
      end
    end

    initializer 'spree.promo.register.promotions.rules' do |app|
      app.config.spree.promotions.rules << Spree::Promotion::Rules::Store
    end
  end
end
