'use strict';

angular.module('zxinfoApp.screens', ['ngRoute', 'zxinfoApp.search.searchUtils'])

    .config(['$routeProvider', function($routeProvider) {
        $routeProvider.when('/screens/loading', {
                templateUrl: 'screens/loading-screens.html',
                controller: 'ScreensLoadingCtrl'
            })
            .when('/screens/ingame', {
                templateUrl: 'screens/ingame-screens.html',
                controller: 'ScreensInGameCtrl'
            })
            .when('/screens/animated', {
                templateUrl: 'screens/animated-screens.html',
                controller: 'ScreensAnimatedCtrl'
            })

    }])

    .controller('ScreensLoadingCtrl', ['$q', '$scope', 'searchService', 'searchUtilities', '$routeParams', 'client',
        function loadingScreensViewCtrl($q, $scope, searchService, searchUtilities, $routeParams, client) {
            var selected = null,
                previous = null;

            $scope.tabs = tabs;
            $scope.selectedIndex = -1;

            $scope.$watch('selectedIndex', function(current, old) {
                if (current < 0) return;
                previous = selected;
                selected = tabs[current];

                $scope.search(tabs[$scope.selectedIndex].title);
                // getLoadingScreensForGamesStartingWith(tabs[$scope.selectedIndex].title);
            });

            var sHelper = searchUtilities;
            sHelper.init($scope);

            $scope.search = function(firstletter) {
                $scope.firstletter = firstletter;
                return sHelper.search();
            }

            // sHelper.search();
            $scope.loadMore = function() {
                $scope.showPublisherIndex = false;
                return sHelper.loadmore(getLoadingScreensForGamesStartingWith(searchService, $q, client, $scope.firstletter, $scope.page++));
            }
        }
    ])
    .controller('ScreensAnimatedCtrl', ['$scope',
        function animatedScreensViewCtrl($scope) {
            $scope.animatedscreens = [
                { src: media_url + '/new/sinclair/screens/load/animated/295-1-load-ani.gif', caption: 'Astro Marine Corps, Dinamic Software' },
                { src: media_url + '/new/sinclair/screens/load/animated/720-1-load-ani.gif', caption: '720 Degrees, US Gold Ltd' },
                { src: media_url + '/new/sinclair/screens/load/animated/996-1-load-ani.gif', caption: 'Cobra, Ocean Software Ltd' },
                { src: media_url + '/new/sinclair/screens/load/animated/1347-1-load-ani.gif', caption: 'Denizen, Players Software' },
                { src: media_url + '/new/sinclair/screens/load/animated/2274-1-load-ani.gif', caption: 'Heavy on the Magick, Gargoyle Games' },
                { src: media_url + '/new/sinclair/screens/load/animated/2580-1-load-ani.gif', caption: 'Jasper!, Micromega' },
                { src: media_url + '/new/sinclair/screens/load/animated/2623-1-load-ani.gif', caption: 'Joe Blade II, Players Software' },
                { src: media_url + '/new/sinclair/screens/load/animated/3268-1-load-ani.gif', caption: 'Moon Strike, Mirrorsoft Ltd' },
                { src: media_url + '/new/sinclair/screens/load/animated/4100-1-load-ani.gif', caption: 'Rescate Atlantida, Dinamic Software' },
                { src: media_url + '/new/sinclair/screens/load/animated/5156-1-load-ani.gif', caption: 'Academy, CRL Group PLC' },
                { src: media_url + '/new/sinclair/screens/load/animated/5160-1-load-ani.gif', caption: 'Technician Ted, Hewson Consultants Ltd' },
                { src: media_url + '/new/sinclair/screens/load/animated/5198-1-load-ani.gif', caption: 'Terror of the Deep, Mirrorsoft Ltd' },
                { src: media_url + '/new/sinclair/screens/load/animated/5317-1-load-ani.gif', caption: 'Tomahawk, Digital Integratiion Ltd' },
                { src: media_url + '/new/sinclair/screens/load/animated/5525-1-load-ani.gif', caption: 'Uridium, Hewson Consultants Ltd' },
                { src: media_url + '/new/sinclair/screens/load/animated/5795-1-load-ani.gif', caption: 'Xevious, US Gold Ltd' },
                { src: media_url + '/new/sinclair/screens/load/animated/14431-1-load-ani.gif', caption: 'Vega Solaris, Eclipse' }
            ];

        }
    ])
    .controller('ScreensInGameCtrl', ['$q', '$scope', 'searchService', 'searchUtilities', '$routeParams', 'client',
        function inGameScreensViewCtrl($q, $scope, searchService, searchUtilities, $routeParams, client) {
            var randomSpan = function() {
                var r = Math.random();
                if (r < 0.7) {
                    return 1;
                } else if (r < 0.8) {
                    return 2;
                } else {
                    return 2;
                }
            }

            var selected = null,
                previous = null;

            $scope.tabs = tabs;
            $scope.selectedIndex = -1;

            $scope.$watch('selectedIndex', function(current, old) {
                if (current < 0) return;
                previous = selected;
                selected = tabs[current];

                $scope.search(tabs[$scope.selectedIndex].title);
            });

            var sHelper = searchUtilities;
            sHelper.init($scope);

            $scope.search = function(firstletter) {
                $scope.firstletter = firstletter;
                return sHelper.search();
            }

            // sHelper.search();
            $scope.loadMore = function() {
                $scope.showPublisherIndex = false;
                getInGameScreensForGamesStartingWith(searchService, $q, client, $scope.firstletter, $scope.page++).then(function(results) {
                    var imageArray = $scope.result.results;
                    var r = {};
                    r.timeTook = results.timeTook;
                    r.hits = results.hitsCount;
                    r.resultsLabel = (r.hits != 1) ? "results" : "result";

                    if (results.hits.length !== PAGE_SIZE) {
                        $scope.allResults = true;
                    }
                    var ii = 0;
                    for (; ii < results.hits.length; ii++) {
                        var jj = 0;
                        var id = results.hits[ii]._id;
                        for (; jj < results.hits[ii].screens.length; jj++) {
                            var add = results.hits[ii].screens[jj];
                            if ("In-game screen" == add.type && "Picture" == add.format) {
                                var randomSize = randomSpan();
                                if (randomSize > 1) {
                                    add.colspan = 2;
                                    add.rowspan = 2;
                                } else {
                                    add.colspan = 1;
                                    add.rowspan = 1;
                                }
                                add.url = media_url + add.url;
                                add._id = id;
                                imageArray.push(add);
                            }
                        }
                    }

                    $scope.searching = false;
                    $scope.result.results = imageArray;
                });
            }
        }
    ]);


var getLoadingScreensForGamesStartingWith = function(searchService, $q, client, c, offset) {
    var deferred = $q.defer();

    var rStr = "[^A-Za-z]{1}.*";
    if (c !== '#') {
        rStr = '[' + c.toLowerCase() + c.toUpperCase() + "]{1}.*";
    }

    client.search({
        "index": zxinfo_index,
        "type": zxinfo_type,
        "body": {
            "size": PAGE_SIZE,
            "from": offset * PAGE_SIZE,
            "query": {
                "bool": {
                    "must": [{
                            "query": {
                                "regexp": {
                                    "fulltitle.raw": rStr
                                }
                            }
                        },
                        {
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
                                        }, {
                                            "match": {
                                                "screens.format": "Picture"
                                            }
                                        }]
                                    }
                                }
                            }
                        }
                    ],
                    "must_not": [
                    {
                        "query": {
                                "term": {
                                    "type": "Compilation"
                                }
                            }
                    }]
                }
            }
        } // end body
    }).then(function(result) {
        var hitsOut = searchService.mapgames(result);
        deferred.resolve({
            timeTook: result.took,
            hitsCount: result.hits.total,
            hits: hitsOut
        });
    });

    return deferred.promise;
}

var getInGameScreensForGamesStartingWith = function(searchService, $q, client, c, offset) {
    var deferred = $q.defer();

    var rStr = "[^A-Za-z]{1}.*";
    if (c !== '#') {
        rStr = '[' + c.toLowerCase() + c.toUpperCase() + "]{1}.*";
    }

    client.search({
        "index": zxinfo_index,
        "type": zxinfo_type,
        "body": {
            "size": PAGE_SIZE,
            "from": offset * PAGE_SIZE,
            "query": {
                "bool": {
                    "must": [{
                            "query": {
                                "regexp": {
                                    "fulltitle.raw": rStr
                                }
                            }
                        },
                        {
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
                                                "screens.type": "In-game screen"
                                            }
                                        }, {
                                            "match": {
                                                "screens.format": "Picture"
                                            }
                                        }]
                                    }
                                }
                            }
                        }
                    ],
                    "must_not": [
                    {
                        "query": {
                                "term": {
                                    "type": "Compilation"
                                }
                            }
                    }]
                }
            }
        } // end body
    }).then(function(result) {
        var hitsOut = searchService.mapgames(result);
        deferred.resolve({
            timeTook: result.took,
            hitsCount: result.hits.total,
            hits: hitsOut
        });
    });

    return deferred.promise;
}