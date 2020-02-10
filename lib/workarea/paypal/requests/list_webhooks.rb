module Workarea
  module Paypal
    module Requests
      class ListWebhooks
        attr_accessor :path, :body, :headers, :verb

        def initialize
          @headers = {}
          @body = nil
          @verb = "GET"
          @path = "/v1/notifications/webhooks"
          @headers["Content-Type"] = "application/json"
        end
      end
    end
  end
end
