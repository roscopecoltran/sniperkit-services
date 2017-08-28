'use strict';

angular.module('zxinfoApp.search.result-directive', ['ngRoute'])

.directive('zxSearchResult', function() {
    return {
        restrict: 'E',
        require: '^ngModel',
        templateUrl: 'components/search/result-directive-search-result.html'
    };
})

.directive('zxSearchResultGrid', function() {
    return {
        restrict: 'E',
        require: '^ngModel',
        templateUrl: 'components/search/result-directive-search-result-grid.html'
    };
})

.directive('zxScreenResult', function() {
    return {
        restrict: 'E',
        require: '^ngModel',
        templateUrl: 'components/search/result-directive-screen-result.html'
    };
});
