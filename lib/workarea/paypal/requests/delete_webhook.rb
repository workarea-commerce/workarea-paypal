module Workarea
  module Paypal
    module Requests
      class DeleteWebhook
        attr_accessor :path, :body, :headers, :verb

        def initialize(id)
          @headers = {}
          @body = nil
          @verb = "DELETE"
          @path = "/v1/notifications/webhooks/#{id}"
          @headers["Content-Type"] = "application/json"
        end
      end
    end
  end
end
