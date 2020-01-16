json.type 'paypal'
json.amount tender.amount
json.paypal_id tender.paypal_id
json.payer_id tender.payer_id
json.direct_payment tender.direct_payment?
if tender.direct_payment?
  json.display_number tender.display_number
  json.issuer tender.issuer
end
