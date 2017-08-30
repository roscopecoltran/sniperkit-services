'use strict';
angular.module(
    'sps', [
        'ngRoute', 
        'ngWebSocket', 
        'angularUtils.directives.dirPagination',
    ]
)
.constant("httpBaseUrl","http://0.0.0.0:4000/")
.constant("wsBaseUrl","ws://0.0.0.0:4000/party")
.config(function ($httpProvider) {
  $httpProvider.defaults.headers.common = {};
  $httpProvider.defaults.headers.post = {};
  $httpProvider.defaults.headers.put = {};
  $httpProvider.defaults.headers.patch = {};
})
.config(function($routeProvider, $locationProvider) {
        $routeProvider
            .when('/', {
                templateUrl : 'nosong.html',
                controller  : ''
            })
            .when('', {
                templateUrl : 'nosong.html',
                controller  : ''
            })
            .when('/about', {
                templateUrl : 'about.html',
                controller  : ''
            })
            .when('/songs/:id', {
                templateUrl : 'showsong.html',
                controller  : 'ShowsongController'
            })
            .when('/search', {
                templateUrl : 'search.html',
                controller  : 'SearchController'
            })
            .otherwise('/');
            $locationProvider.hashPrefix('');
    });

var hideit = function () {
    $('#nowInGroup').hide();
    $('#leaderPanel').hide();
    $('#userPanel').hide();
};

var groupWebSocket = {};

