module Workarea
  class Payment::Tender::Paypal < Payment::Tender
    field :token, type: String
    field :payer_id, type: String
    field :details, type: Hash

    def slug
      :paypal
    end
  end
end
