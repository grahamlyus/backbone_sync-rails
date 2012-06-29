require 'backbone_sync-rails/pusher/event'

module BackboneSync
  module Rails
    module Pusher
      module Observer
        def after_update(model)
          accessible_attributes = model.class.accessible_attributes.to_a
          changed_attributes = model.changes.keys.select {|i|accessible_attributes.include?(i)}
          return if changed_attributes.empty?
          ::Rails.logger.debug("BROADCASTING update of changes: #{model.class.name}[#{model.id}] -> #{model.changes}")
          begin
            BackboneSync::Rails::Pusher::Event.new(model, :update).broadcast
          rescue *NET_HTTP_EXCEPTIONS => e
            handle_net_http_exception(e)
          end
        end

        def after_create(model)
          begin
            BackboneSync::Rails::Pusher::Event.new(model, :create).broadcast
          rescue *NET_HTTP_EXCEPTIONS => e
            handle_net_http_exception(e)
          end
        end

        def after_destroy(model)
          begin
            BackboneSync::Rails::Pusher::Event.new(model, :destroy).broadcast
          rescue *NET_HTTP_EXCEPTIONS => e
            handle_net_http_exception(e)
          end
        end

        def handle_net_http_exception(exception)
          ::Rails.logger.error("")
          ::Rails.logger.error("Backbone::Sync::Rails::Pusher::Observer encountered an exception:")
          ::Rails.logger.error(exception.class.name)
          ::Rails.logger.error(exception.message)
          ::Rails.logger.error(exception.backtrace.join("\n"))
          ::Rails.logger.error("")
        end
      end
    end
  end
end
