module Workarea
  class Payment::Tender::Paypal < Payment::Tender
    field :paypal_id, type: String
    field :payer_id, type: String
    field :details, type: Hash, default: {}
    field :approved, type: Boolean, default: false
    field :direct_payment, type: Boolean, default: false

    def slug
      :paypal
    end

    def display_number
      return unless direct_payment?
      details['display_number']
    end

    def issuer
      return unless direct_payment?
      details['issuer']
    end
  end
end
