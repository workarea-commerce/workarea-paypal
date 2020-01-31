namespace :workarea do
  namespace :paypal do
    desc 'Register webhook listeners for PayPal'
    task create_webhooks: :environment do
      puts 'Unsubscribing existing webhooks...'
      webhooks = begin
        Workarea::Paypal.gateway.list_webhooks.result.webhooks
      rescue Workarea::Paypal::Gateway::RequestError => e
        puts e.message
        exit
      end

      webhooks.each do |webhook|
        begin
          Workarea::Paypal.gateway.delete_webhook(webhook.id)
        rescue Workarea::Paypal::Gateway::RequestError => e
          puts "Webhook deletion #{id} failed. #{e.message}"
        end
      end

      puts 'Subscribing to PayPal webhook events...'
      begin
        create = Workarea::Paypal::CreateWebhook.new(
          url: 'https://webhook.site/1c080afd-bd8b-432c-9d72-38cbddaea44f',
          # url: Workarea::Storefront::Engine.routes.url_helpers.paypal_event_url(
          #   host: Workarea.config.host
          # ),
          event_types: Workarea.config.default_webhook_events
        )

        puts 'completed successfully!'
      rescue Workarea::Paypal::Gateway::RequestError => e
        puts "Webhook creation failed. #{e.message}"
      end
    end
  end
end
