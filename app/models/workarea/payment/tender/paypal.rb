module Workarea
  class Payment::Tender::Paypal < Payment::Tender
    field :paypal_id, type: String
    field :payer_id, type: String
    field :details, type: Hash, default: {}
    field :approved, type: Boolean, default: false

    def slug
      :paypal
    end
  end
end
