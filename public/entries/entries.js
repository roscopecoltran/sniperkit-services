'use strict';

angular.module('zxinfoApp.entries', ['ngRoute', 'zxinfoApp.search.searchUtils'])
.service('client', function(esFactory) {
    return esFactory({
        host: es_host,
        apiVersion: es_apiVersion,
        log: es_log
    });
})
.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/entries', {
        templateUrl: 'entries/entries.html',
        controller: 'EntriesCtrl'
    })
}])
.controller('EntriesCtrl', ['$scope', 'searchService', 'searchUtilities', '$routeParams', 'client',
    function entriesViewCtrl($scope, searchService, searchUtilities, $routeParams, client) {
        $scope.contenttype = $routeParams.contenttype;
        $scope.genretype = $routeParams.genretype;
        $scope.genresubtype = $routeParams.genresubtype;
        $scope.machinetype = $routeParams.machinetype;

        var filterObject = {
            contenttype: $scope.contenttype,
            machinetype: $scope.machinetype,

            genretype: $scope.genretype,
            genresubtype: $scope.genresubtype
        };

        var getSubTypes = function(gametype) {
            client.search({
                "index": zxinfo_index,
                "type": zxinfo_type,
                "body": {
                    "size": 0,
                    "query": {
                        "bool": {
                            "must": [{
                                "match": {
                                    "type": gametype
                                }
                            }]
                        }
                    },
                    "aggs": {
                        "subtypes": {
                            "terms": {
                                "size": 0,
                                "field": "subtype",
                                "order": {
                                    "_term": "desc"
                                }
                            }
                        }
                    }
                }
            }).then(function(result) {
                var aggs = result.aggregations;
                var items = [];
                var i = 0;
                for (; i < aggs.subtypes.buckets.length; i++) {
                    var bucket = aggs.subtypes.buckets[i];
                    var item = { name: bucket.key, count: bucket.doc_count };
                    items.push(item);
                }
                $scope.subtypes = items;
            }).catch(function(err) { console.log(err) });
        }

        var sHelper = searchUtilities;
        sHelper.init($scope);
        $scope.searchTerm = '';

        $scope.search = function() {
            $scope.searchTerm = '';
            return sHelper.search();
        }

        // sHelper.search();
        $scope.loadMore = function() {
            return sHelper.loadmore(searchService.getallgames(filterObject, $scope.page++));
        }

        $scope.search();

        if($scope.genretype !== undefined) {
            getSubTypes($scope.genretype);
        }
    }
]);
