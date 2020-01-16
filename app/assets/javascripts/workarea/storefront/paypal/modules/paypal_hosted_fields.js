/**
 * @namespace WORKAREA.paypalHostedFields
 */
WORKAREA.registerModule('paypalHostedFields', (function () {
    'use strict';

    var requestWrapper = function (requestData) {
            var deferred = $.Deferred();

            $.ajax(requestData)
            .done(function(data) {
                deferred.resolve(data);
            })
            .fail(function(data, status, xhr) {
                deferred.reject(xhr);
            });

            return deferred.promise();
        },

        createOrder = function() {
            return requestWrapper({
                url: WORKAREA.routes.storefront.paypalPath(),
                type: 'post',
                dataType: 'json'
            }).then(
                function (data) { return data.id; },
                function (xhr) { WORKAREA.messages.insertPageMessages({}, xhr); }
            );
        },

        onApprove = function(data) {
            return requestWrapper({
                url: WORKAREA.routes.storefront.paypalApprovedPath({ id: data.orderID }),
                type: 'put',
                dataType: 'json'
            }).then(
                function(data) {
                    window.location = data.redirect_url;
                },
                function(xhr) {
                    WORKAREA.messages.insertPageMessages({}, xhr);
                }
            );
        },

        addSubmitListener = function($container, hostedFields) {
            var $form = $container.parents('form');

            $form.on('submit', function(event) {
                if ($form.find('#payment_new_card').is(':checked')) {
                    event.preventDefault();
                    hostedFields.submit({
                        vault: $container.find('input[name="save_card"]').is(':checked')
                    }).then(onApprove);
                }
            });
        },

        getConfig = function () {
            return _.assign({}, WORKAREA.config.paypalHostedFields, {
                createOrder: createOrder
            });
        },


        setup = function($placeholder, $scope) {
            var template = JST['workarea/storefront/paypal/templates/paypal_fields'],
                options = $placeholder.data('paypalHostedFields'),
                $container = $('.checkout-payment__primary-method--new .checkout-payment__primary-method-edit', $scope);

            $container.html(template(options));

            paypal
                .HostedFields
                .render(getConfig())
                .then(_.partial(addSubmitListener, $container));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.paypalHostedFields
         */
        init = function ($scope) {
            var $placeholder = $('[data-paypal-hosted-fields]', $scope);

            if (_.isEmpty($placeholder)) {  return;  }
            if (window.paypal === undefined) { return; }
            if (!paypal.HostedFields.isEligible()) { return; }

            setup($placeholder, $scope);
        };

    return {
        init: init
    };
}()));
