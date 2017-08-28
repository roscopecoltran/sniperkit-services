'use strict';

angular.module('zxinfoApp.details', ['ngRoute', 'zxinfoApp.gamedetails.gameDetails'])

.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/details/:gameId', {
        templateUrl: 'details/details.html',
        controller: 'GameDetailsCtrl'
    })
}]);