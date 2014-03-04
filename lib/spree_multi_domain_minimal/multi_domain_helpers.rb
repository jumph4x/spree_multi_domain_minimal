module SpreeMultiDomainMinimal
  module MultiDomainHelpers
    def self.included(receiver)
      receiver.send :helper, 'spree/products'
      receiver.send :helper, 'spree/taxons'

      receiver.send :before_filter, :add_current_store_id_to_params
      receiver.send :helper_method, :current_store
      receiver.send :helper_method, :current_tracker
    end

    def current_store
      @current_store ||= Spree::Store.current(request.env['SERVER_NAME'])
    end

    def current_tracker
      @current_tracker ||= Spree::Tracker.current(request.env['SERVER_NAME'])
    end

    def add_current_store_id_to_params
      params[:current_store_id] = current_store.try(:id)
    end
  end
end
