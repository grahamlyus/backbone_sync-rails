module BackboneSync
  module Rails
    module Pusher
      class Event
        def initialize(model, event)
          @model = model
          @event = event
        end

        def broadcast
          trigger(collection_channel_name, @event, data)
          trigger(model_channel_name, @event, data) if @event == :update
        end

        private

        def trigger(channel, event, data)
          if defined?(EventMachine) && EventMachine.reactor_running?
            ::Pusher[channel].trigger_async(event, data)
          else
            ::Pusher[channel].trigger!(event, data)
          end
        end

        def collection_channel_name
          "presence-sync-#{@model.class.table_name}"
        end

        def model_channel_name
          "#{collection_channel_name}-#{@model.id}"
        end

        def data
          { @model.id => @model.as_json }
        end
      end
    end
  end
end
