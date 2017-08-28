'use strict';

var es_host, es_apiVersion, api_url, media_url, PAGE_SIZE;
var zxinfo_index, zxinfo_type;
var zxinfo_suggests_index, zxinfo_suggests_type_title;
var es_log;

var tabs = [
    { title: '#', publishers: [] },
    { title: 'A', publishers: [] },
    { title: 'B', publishers: [] },
    { title: 'C', publishers: [] },
    { title: 'D', publishers: [] },
    { title: 'E', publishers: [] },
    { title: 'F', publishers: [] },
    { title: 'G', publishers: [] },
    { title: 'H', publishers: [] },
    { title: 'I', publishers: [] },
    { title: 'J', publishers: [] },
    { title: 'K', publishers: [] },
    { title: 'L', publishers: [] },
    { title: 'M', publishers: [] },
    { title: 'N', publishers: [] },
    { title: 'O', publishers: [] },
    { title: 'P', publishers: [] },
    { title: 'Q', publishers: [] },
    { title: 'R', publishers: [] },
    { title: 'S', publishers: [] },
    { title: 'T', publishers: [] },
    { title: 'U', publishers: [] },
    { title: 'V', publishers: [] },
    { title: 'W', publishers: [] },
    { title: 'X', publishers: [] },
    { title: 'Y', publishers: [] },
    { title: 'Z', publishers: [] }
];

// Declare app level module which depends on views, and components
angular.module('zxinfoApp', [
    'ngRoute',
    'ngMaterial',
    'ngMaterialSidemenu',
    'material.components.expansionPanels',
    'elasticsearch',
    'jkAngularCarousel',
    'SinclairAppCfg',
    'zxinfoApp.Graph',
    'zxinfoApp.home',
    'zxinfoApp.publisher',
    'zxinfoApp.entries',
    'zxinfoApp.group',
    'zxinfoApp.details',
    'zxinfoApp.screens',
    'zxinfoApp.sidemenu.sideMenu',
    'zxinfoApp.gamedetails.gameDetails',
    'zxinfoApp.search.search',
    'zxinfoApp.search.searchUtils',
    'zxinfoApp.search.result-directive',
    'zxinfoApp.urlencode.urlencode-filter',
    'zxinfoApp.test'
])

.config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $routeProvider
        /** DEFAULT ROUTE **/
        .otherwise('/home', {
            templateUrl: 'home/home.html',
            controller: 'HomeCtrl',
            controllerAs: 'hctrl'
        });
        $locationProvider.html5Mode({
          enabled: true,
          requireBase: true
        });
}])

.controller('AppCtrl', ['$scope', '$anchorScroll', '$location', '$mdSidenav', 'searchService', 'searchUtilities', 'client', '$q', '$mdUtil',
    function AppCtrl($scope, $anchorScroll, $location, $mdSidenav, searchService, searchUtilities, client, $q, $mdUtil) {
        var self = this;

        self.toggleLeftNav      = toggleLeftNav;
        self.scrollTop          = scrollTop;
        var scrollContentEl = document.querySelector("md-content[md-scroll-y]");

        function scrollTop() {
            $mdUtil.animateScrollTo(scrollContentEl, 0, 200);
        }

        function toggleLeftNav() {
            $mdSidenav('left').toggle();
        };

        $scope.changeView = function(view) {
            $location.path(view); // path not hash
        }

    }
])

/** Directive which applies a specified class to the element when being scrolled */
.directive('docsScrollClass', function() {
return {
    restrict: 'A',
    link: function(scope, element, attr) {

      var scrollParent = element.parent();
      var isScrolling = false;

      // Initial update of the state.
      updateState();

      // Register a scroll listener, which updates the state.
      scrollParent.on('scroll', updateState);

      function updateState() {
        var newState = scrollParent[0].scrollTop !== 0;

        if (newState !== isScrolling) {
          element.toggleClass(attr.docsScrollClass, newState);
        }

        isScrolling = newState;
      }
    }
  };
})

.run(function(EnvironmentConfig) {
    console.log(EnvironmentConfig);
    es_host = EnvironmentConfig.es_host;
    es_apiVersion = EnvironmentConfig.es_apiVersion;
    es_log = EnvironmentConfig.log;

    zxinfo_index = EnvironmentConfig.zxinfo_index;
    zxinfo_type = EnvironmentConfig.zxinfo_type;
    zxinfo_suggests_index = EnvironmentConfig.zxinfo_suggests_index;
    zxinfo_suggests_type_title = EnvironmentConfig.zxinfo_suggests_type_title;
    api_url = EnvironmentConfig.api_url;
    media_url = EnvironmentConfig.media_url;
    PAGE_SIZE = EnvironmentConfig.page_size;
});