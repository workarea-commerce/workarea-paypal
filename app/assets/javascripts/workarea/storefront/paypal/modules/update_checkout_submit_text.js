/**
 * @namespace WORKAREA.updateCheckoutSubmitText
 */
WORKAREA.registerModule('updateCheckoutSubmitText', (function () {
    'use strict';

    var submitButtonText = function ($selectedPaymentMethod) {
            var data = $selectedPaymentMethod.data('updateCheckoutSubmitText') || {};

            if (data.prevent) { return; }

            if (data.text) {
                return data.text;
            } else {
                return I18n.t('workarea.storefront.checkouts.place_order');
            }
        },

        updateText = function($selectedPaymentMethod, $checkoutSubmit) {
            var text = submitButtonText($selectedPaymentMethod);

            if (_.isEmpty(text)) {  return;  }

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
        init: init
    };
}()));
