'use strict';

var zxinfo_suggests_author_index = 'zxinfo_suggests_author';
var zxinfo_suggests_author_type_title = 'zxinfo_suggests_author';
var es_host = 'http://search.kolbeck.dk';
var es_log = "error";
var api_url = 'http://incubator.kolbeck.dk/sinclairsite/api';
var media_url = 'http://incubator.kolbeck.dk/media';
var neo4jurl = 'bolt://zxinfo-neo4j:7687';

angular.module('zxinfoApp.Graph', [
        'SinclairAppCfg',
        'elasticsearch',
        'ngMessages',
        'ngResource',
        'ngMaterial'
    ])
    .run(function(EnvironmentConfig) {
        es_host = EnvironmentConfig.es_host;
        es_log = EnvironmentConfig.log;

        zxinfo_suggests_author_index = EnvironmentConfig.zxinfo_suggests_author_index;
        zxinfo_suggests_author_type_title = EnvironmentConfig.zxinfo_suggests_author_type_title;

        neo4jurl = EnvironmentConfig.neo4jurl;

        api_url = EnvironmentConfig.api_url;
        media_url = EnvironmentConfig.media_url;
    })
    .service('client', function(esFactory) {
        return esFactory({
            host: es_host,
            apiVersion: '2.4',
            log: es_log
        });
    })
    .config(['$routeProvider', function($routeProvider) {
        $routeProvider.when('/graph', {
                templateUrl: 'graph/graph.html',
                controller: 'GraphCtrl'
            });
    }])
    .controller('GraphCtrl', ['$q', '$log', 'client', '$resource', '$scope', function($q, $log, client, $resource, $scope) {

        // $scope.local = {
        //     author1 : 'William J. Wray',
        //     author2 : 'Matthew Smith'
        // }
        $scope.author1 = 'William J. Wray';
        $scope.author2 = 'Matthew Smith';

        var self = this;

        self.selectedItem1Change = selectedItem1Change;
        self.searchText1Change = searchText1Change;
        self.author1 = $scope.author1;

        self.selectedItem2Change = selectedItem2Change;
        self.searchText2Change = searchText2Change;
        self.author2 = $scope.author2;

        self.querySearch = querySearch;
        self.findPath = findPath;

        self.degrees = null;

        function findPath() {
            queryPath(self.author1, self.author2, self.allEntries, self.allReReleases, self.allSteps);
        }

        function queryPath(a1, a2, includeAllEntries, includeRereleases, includeAllSteps) {
            var deferred = $q.defer();
            // http://localhost:3000/api/path/William%20J.%20Wray/Matthew%20Smith

            var include = "?";
            if (includeAllEntries !== undefined && includeAllEntries == true) {
                include += "&includeall=1";
            }
            if (includeRereleases !== undefined && includeRereleases == true) {
                include += "&includerereleases=1";
            }
            if (includeAllSteps !== undefined && includeAllSteps == true) {
                include += "&includeallsteps=1";
            }

            var game = $resource(api_url + '/graph/path/:a1/:a2' + include);
            game.get({
                    a1: a1,
                    a2: a2
                })
                .$promise.then(function(result) {
                    self.degrees = result.result;
                });
        };


        function querySearch(query) {
            var deferred = $q.defer();
            client.suggest({
                "index": zxinfo_suggests_author_index,
                "type": zxinfo_suggests_author_type_title,
                "body": {
                    "names": {
                        "text": query,
                        "completion": {
                            "field": "suggest"
                        }
                    }
                }
            }).then(function(result) {
                return deferred.resolve(result.names[0].options);
            }).catch(function(err) { console.log(err) });

            return deferred.promise;
        }

        function searchText1Change(text) {
            self.author1 = text;
        }

        function selectedItem1Change(item) {
            if (item !== undefined) {
                self.author1 = item.text;
            }
        }

        function searchText2Change(text) {
            self.author2 = text;
        }

        function selectedItem2Change(item) {
            if (item !== undefined) {
                self.author2 = item.text;
            }
        }

    }]);
