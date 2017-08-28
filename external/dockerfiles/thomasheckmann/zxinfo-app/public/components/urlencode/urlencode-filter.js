'use strict';

angular.module('zxinfoApp.urlencode.urlencode-filter', [])

.filter('urlencode', [function() {
    return function(input) {
        return window.encodeURIComponent(input);
    }
}]);
