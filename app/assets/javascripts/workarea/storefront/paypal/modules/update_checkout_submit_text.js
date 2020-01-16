/**
 * @namespace WORKAREA.updateCheckoutSubmitText
 */
WORKAREA.registerModule('updateCheckoutSubmitText', (function () {
    'use strict';

    var submitButtonText = function (data) {
            if (data.prevent) { return; }

            if (data.text) {
                return data.text;
            } else {
                return I18n.t('workarea.storefront.checkouts.place_order');
            }
        },

        updateText = function($selectedPaymentMethod, $checkoutSubmit) {
            var data = $selectedPaymentMethod.data('updateCheckoutSubmitText') || {},
                text = submitButtonText(data);

            if (_.isEmpty(text)) {  return;  }

            if (data.disabled && !data.prevent) {
                $checkoutSubmit.attr('disabled', 'disabled');
            } else {
                $checkoutSubmit.removeAttr('disabled');
            }

            $checkoutSubmit.text(text);
        },

        setup = function($paymentMethodRadios){
            var $initialPaymentMethod = $paymentMethodRadios.filter(':checked');

            if ($initialPaymentMethod.data('updateCheckoutSubmitText')) {
                var $checkoutSubmit = $('#checkout_form [type="submit"]');
                updateText($initialPaymentMethod, $checkoutSubmit);
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.updateCheckoutSubmitText
         */
        init = function ($scope) {
            var $paymentMethodRadios = $('[type="radio"][name="payment"]', $scope),
                $textChangeRadios = $paymentMethodRadios.filter('[data-update-checkout-submit-text]');

            if (_.isEmpty($textChangeRadios)) {  return;  }

            setup($paymentMethodRadios);

            $paymentMethodRadios.on('change', function(event){
                var $selectedPaymentMethod = $(event.currentTarget),
                    $checkoutSubmit = $selectedPaymentMethod.closest('form').find('[type=submit]');

                updateText($selectedPaymentMethod, $checkoutSubmit);
            });
        };

    return {
        init: init,
        updateText: updateText
    };
}()));
