module Workarea
  module Paypal
    module Requests
      class CreateWebhook
        attr_accessor :path, :body, :headers, :verb

        def initialize
          @headers = {}
          @body = nil
          @verb = "POST"
          @path = "/v1/notifications/webhooks"
          @headers["Content-Type"] = "application/json"
        end

        def request_body(body)
          @body = body
        end
      end
    end
  end
end
