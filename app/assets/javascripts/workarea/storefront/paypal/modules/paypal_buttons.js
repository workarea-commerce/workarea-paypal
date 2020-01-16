/**
 * @namespace WORKAREA.paypalButtons
 */
WORKAREA.registerModule('paypalButtons', (function () {
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

        getConfig = function () {
            return _.assign({}, WORKAREA.config.paypalButtons, {
                createOrder: createOrder,
                onApprove: onApprove
            });
        },

        setup = function($container) {
            paypal
            .Buttons(getConfig())
            .render($container[0]);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.paypalButtons
         */
        init = function ($scope) {
            var $buttonContainer = $('#paypal-button-container', $scope);

            if (window.paypal === undefined) { return; }
            if (_.isEmpty($buttonContainer)) { return; }

            setup($buttonContainer);
        };

    return {
        init: init
    };
}()));
