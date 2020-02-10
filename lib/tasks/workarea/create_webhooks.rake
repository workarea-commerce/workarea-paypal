namespace :workarea do
  namespace :paypal do
    desc 'Register webhook listeners for PayPal'
    task create_webhooks: :environment do
      puts 'Unsubscribing existing webhooks...'
      webhooks = Workarea::Paypal.gateway.list_webhooks.result.webhooks


      webhooks.each do |webhook|
        begin
          Workarea::Paypal.gateway.delete_webhook(webhook.id)
        rescue Workarea::Paypal::Gateway::RequestError => e
          puts "Webhook deletion #{id} failed. #{e.message}"
        end
      end

      puts 'Subscribing to PayPal webhook events...'
      Workarea::Paypal.gateway.create_webhook(
        url: Workarea::Storefront::Engine.routes.url_helpers.paypal_event_url(
          host: Workarea.config.host
        ),
        event_types: Workarea.config.default_webhook_events
      )

      puts 'completed successfully!'
    end
  end
end
