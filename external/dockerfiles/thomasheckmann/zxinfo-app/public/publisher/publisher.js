'use strict';

angular.module('zxinfoApp.publisher', ['ngRoute', 'zxinfoApp.search.searchUtils'])

.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/publisher', {
            templateUrl: 'publisher/publisher.html',
            controller: 'PublisherCtrl'
        })
        .when('/publisher/:company', {
            templateUrl: 'publisher/publisher.html',
            controller: 'PublisherCtrl'
        })

}])

.controller('PublisherCtrl', ['$scope', 'searchService', 'searchUtilities', '$routeParams', 'client',
    function PublisherCtrl($scope, searchService, searchUtilities, $routeParams, client) {
        $scope.showPublisherIndex = false;
        if ($scope.company === undefined) {
            $scope.showPublisherIndex = true;
        }

        var selected = null,
            previous = null;

        $scope.tabs = tabs;
        $scope.selectedIndex = -1;

        $scope.togglePublisherTab = function() {
            $scope.showPublisherIndex = !$scope.showPublisherIndex;
        }

        $scope.$watch('selectedIndex', function(current, old) {
            if (current < 0) return;
            previous = selected;
            selected = tabs[current];

            /**
             * Aggregation
             */
            var getPublishersStartingWith = function(c) {
                var rStr = "[^A-Za-z]{1}.*";
                if (c !== '#') {
                    rStr = '[' + c.toLowerCase() + c.toUpperCase() + "]{1}.*";
                }

                client.search({
                    "index": zxinfo_index,
                    "type": zxinfo_type,
                    "body": {
                        "size": 0,
                        "query": {
                            "bool": {
                                "should": [{
                                    "nested": {
                                        "path": "publisher",
                                        "filter": {
                                            "query": {
                                                "regexp": {
                                                    "publisher.name.raw": rStr
                                                }
                                            }
                                        }
                                    }
                                }]
                            }
                        },
                        "aggs": {
                            "publisher": {
                                "nested": {
                                    "path": "publisher"
                                },
                                "aggs": {
                                    "name": {
                                        "terms": {
                                            "size": 5000,
                                            "field": "publisher.name.raw",
                                            "include": rStr
                                        }
                                    }
                                }
                            }
                        }
                    }
                }).then(function(result) {
                    var aggs = result.aggregations;
                    var items = [];
                    var i = 0;
                    for (; i < aggs.publisher.name.buckets.length; i++) {
                        var bucket = aggs.publisher.name.buckets[i];
                        var item = { name: bucket.key, count: bucket.doc_count };
                        items.push(item);
                    }
                    tabs[$scope.selectedIndex].publishers = items;
                    $scope.showPublisherIndex = true;

                }).catch(function(err) { console.log(err) });
            }

            tabs[$scope.selectedIndex].publishers = [];
            // clear search result
            $scope.result = {
                results: []
            };
            $scope.searching = false;
            $scope.page = 0; // A counter to keep track of our current page
            $scope.allResults = true; // Whether or not all results have been found.
            getPublishersStartingWith(tabs[$scope.selectedIndex].title);
        });


        var sHelper = searchUtilities;
        sHelper.init($scope);
        $scope.company = $routeParams.company;

        $scope.search = function(pubname) {
            $scope.company = pubname;
            return sHelper.search();
        }

        // sHelper.search();
        $scope.loadMore = function() {
            $scope.showPublisherIndex = false;
            return sHelper.loadmore(searchService.searchpublisher($scope.company, $scope.page++));
        }

        if ($scope.company !== undefined) {
            $scope.search($scope.company);
        } else {
            return {};
        }

    }
]);
