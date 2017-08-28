/***
    Helper functions for doing search.
    Rquires the following on page:
    'searchTerm' - input text for query
    'page' - current page in result
    'result' - an array of items returned by search
    'allResults' - boolean indicating if all results has been found
    'searching' - boolean indicating if searching is running
**/
'use strict';

angular.module('zxinfoApp.search.searchUtils', ['ngResource'])
    .factory('searchUtilities', ['$q', '$resource', function($q, $resource) {
        var $scope = null;

        var init = function(s) {
            $scope = s;

            // init search result
            $scope.result = {
                results: []
            };
            $scope.searching = false;
            $scope.page = 0; // A counter to keep track of our current page
            $scope.allResults = true; // Whether or not all results have been found.
        }

        var search = function() {
            $scope.page = 0;
            $scope.searching = true;
            $scope.result = {
                results: []
            };
            $scope.allResults = false;
            $scope.loadMore();
        }

        var loadMore = function(search) {
            search.then(function(results) {
                var r = {};
                r.results = $scope.result.results;
                r.timeTook = results.timeTook;
                r.hits = results.hitsCount;
                r.facets = results.facets;
                r.resultsLabel = (r.hits != 1) ? "results" : "result";

                if (results.hits.length !== PAGE_SIZE) {
                    $scope.allResults = true;
                }

                var ii = 0;
                for (; ii < results.hits.length; ii++) {
                    r.results.push(results.hits[ii]);
                }

                $scope.searching = false;
                $scope.result = r;
            });
        }

        return {
            "init": init,
            "search": search,
            "loadmore": loadMore
        };
    }]);
