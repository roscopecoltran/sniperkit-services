'use strict';

angular.module('zxinfoApp.home', ['ngRoute'])

    .config(['$routeProvider', function($routeProvider) {
        $routeProvider.when('/search/:query', {
                templateUrl: 'home/search.html',
                controller: 'HomeCtrl',
                controllerAs: 'sctrl'
            })
            .when('/home', {
                templateUrl: 'home/home.html',
                controller: 'HomeCtrl',
                controllerAs: 'hctrl'
            });
    }])

    .controller('HomeCtrl', ['$scope', 'client', 'searchService', 'searchUtilities', '$q', '$routeParams', function($scope, client, searchService, searchUtilities, $q, $routeParams) {
        /**
         * autocomplete
         */
        var self = this;
        self.selectedItem;
        self.searchText = $routeParams.query;
        self.searchTextChange = searchTextChange;
        self.selectedItemChange = selectedItemChange;
        self.suggest = suggest;

        /** labes are used to highlight which fields was matched **/
        $scope.labels = { "fulltitle": "Full title", "alsoknownas": "Also known as", "releases.as_title": "Re-released as", "publisher.name": "Publisher", "releases.name": "Re-Released by", "authors.authors": "Author", "authors.group": "Group" };

        function searchTextChange(text) {
            self.searchText = text;
        }

        function selectedItemChange(item) {
            self.selectedItem = item;
            if (item !== undefined) {
                self.searchText = item.text;
                $scope.search1();
            }
        }

        /** General search function **/
        var sHelper = searchUtilities;

        $scope.search1 = function() {
            $scope.changeView('/search/' + self.searchText);
        }

        $scope.search = function() {
            angular.element(document.querySelector('#autocomplete')).blur();
            sHelper.init($scope);
            return sHelper.search();
        }

        $scope.loadMore = function() {
            return sHelper.loadmore(searchService.search(self.searchText, $scope.page++));
        }

        if (self.searchText !== undefined) {
            $scope.search();
        }

        // ******************************
        // Internal methods
        // ******************************

        /** calls Elasticsearch suggest api **/
        function suggest(query) {
            var deferred = $q.defer();
            client.suggest({
                "index": zxinfo_suggests_index,
                "type": zxinfo_suggests_type_title,
                "body": {
                    "titles": {
                        "text": query,
                        "completion": {
                            "field": "suggest"
                        }
                    }
                }

            }).then(function(result) {
                return deferred.resolve(result.titles[0].options);
            }).catch(function(err) { console.log(err) });

            return deferred.promise;
        }


        // find 5 random
        client.search({
            "index": zxinfo_index,
            "type": zxinfo_type,
            "body": {

                "size": 5,
                "query": {
                    "function_score": {
                        "query": {
                            "bool": {
                                "must": [{
                                        "query": {
                                            "term": {
                                                "contenttype": "SOFTWARE"
                                            }
                                        }
                                    },
                                    {
                                        "nested": {
                                            "path": "screens",
                                            "query": {
                                                "bool": {
                                                    "must": [{
                                                            "match": {
                                                                "screens.type": "Loading screen"
                                                            }
                                                        },
                                                        {
                                                            "match": {
                                                                "screens.format": "Picture"
                                                            }
                                                        }
                                                    ]
                                                }
                                            }
                                        }
                                    }
                                ],
                                "must_not": [{
                                    "query": {
                                        "term": {
                                            "type": "Compilation"
                                        }
                                    }
                                }]
                            }
                        },
                        "random_score": {}
                    }
                }
            } // end body
        }).then(function(result) {
            var prepend = function(value, array) {
                var newArray = array.slice(0);
                newArray.unshift(value);
                return newArray;
            }
            var i = 0,
                itemArray = [];
            for (; i < result.hits.hits.length; i++) {
                var item = result.hits.hits[i]._source;
                var id = result.hits.hits[i]._id;
                var title = item.fulltitle;

                var loadscreen = "/images/empty.png";
                if (typeof(item.screens) != "undefined") {
                    var idx = 0;
                    for (; idx < item.screens.length; idx++) {
                        if ("Loading screen" == item.screens[idx].type && "Picture" == item.screens[idx].format) {
                            loadscreen = item.screens[idx].url;
                        }
                    }
                }
                itemArray = prepend({ title: title, src: media_url + loadscreen, id: id }, itemArray);
            }
            $scope.imageArrayRnd5 = itemArray;
        }).catch(function(err) { console.log(err) });

    }]);