'use strict';

angular.module('zxinfoApp.group', ['ngRoute', 'zxinfoApp.search.searchUtils'])

.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/group/:groupid/:groupname/games', {
        templateUrl: 'group/group.html',
        controller: 'GroupCtrl'
    })
}])

.controller('GroupCtrl', ['$scope', 'searchService', 'searchUtilities', '$routeParams',
    function publisherViewCtrl($scope, searchService, searchUtilities, $routeParams) {
        $scope.groupid = $routeParams.groupid.toUpperCase();
        $scope.groupname = $routeParams.groupname;

        var sHelper = searchUtilities;
        sHelper.init($scope);
        $scope.searchTerm = '';

        $scope.search = function() {
            $scope.searchTerm = '';
            return sHelper.search();
        }

        // sHelper.search();
        $scope.loadMore = function() {
            return sHelper.loadmore(searchService.getallgamesbygroup($scope.groupid, $scope.groupname, $scope.page++));
        }

        $scope.search();
    }
]);
