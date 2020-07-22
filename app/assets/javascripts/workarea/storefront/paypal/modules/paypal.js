/**
 *
 * Reliably ensure that the PayPal SDK is either loaded or will
 * be loading.
 *
 * @namespace WORKAREA.paypal
 */
WORKAREA.registerModule('paypal', (function () {
    'use strict';

    var handlers = [],
        attempts = 0,
        paypalLoaded = null,

        /**
         * Define a function that will be called when the paypal SDK has
         * loaded.
         *
         * @method
         * @name ready
         * @param function handler - A function to be called when PayPal
         *                           is available.
         * @memberof WORKAREA.paypal
         */
        ready = function(handler) {
            if (paypalLoaded) {
                handler();
            } else {
                handlers.push(handler);
            }
        },

        /**
         * Continuously check for whether the Paypal SDK has loaded
         * every 5 seconds, and call function handlers defined in
         * `ready()` when the `window.paypal` object is available. This
         * will only occur if the `<script>` tag containing the PayPal
         * SDK is detected to be on the page.
         *
         * @method
         * @name init
         * @memberof WORKAREA.paypal
         */
        init = function() {
            var $sdk = $('script[data-partner-attribution-id]'),
                paypalExpectedToLoad = !_.isEmpty($sdk);

            attempts += 1;
            paypalLoaded = window.paypal !== undefined;

            if (!paypalLoaded && paypalExpectedToLoad && attempts <= 20) {
                window.setTimeout(init, 2000);
            } else if (paypalLoaded) {
                _.each(handlers, function(handler) { handler(); });
                handlers = [];
            }
        };

    return {
        ready: ready,
        init: init
    };
}()));
