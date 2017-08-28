'use strict';

angular.module('zxinfoApp.gamedetails.gameDetails', ['ngRoute', 'ngSanitize'])
    .service('client', function(esFactory) {
        return esFactory({
            host: es_host,
            apiVersion: es_apiVersion,
            log: es_log
        });
    })
    .controller('GameDetailsCtrl', ['$scope', '$mdDialog', 'searchService', '$location', '$routeParams', 'client',
        function GameDetailsCtrl($scope, $mdDialog, searchService, $location, $routeParams, client) {
            $scope.gameId = $routeParams.gameId;
            $scope.media_url = media_url;

            function DialogController($scope, gameId, $location) {
                var moreLikeThis = function(gameId) {
                    client.search({
                        "index": zxinfo_index,
                        "type": zxinfo_type,
                        "body": {
                            "size": 3,
                            "query": {
                                "more_like_this": {
                                    "fields": [
                                        "fulltitle",
                                        "alsoknownas",
                                        "type",
                                        "subtype"
                                    ],
                                    "like": [{
                                        "_id": gameId
                                    }],
                                    "min_term_freq": 1,
                                    "max_query_terms": 12
                                }
                            }
                        }
                    }).then(function(result) {
                        $scope.morelikethis = searchService.mapgames(result);
                    }).catch(function(err) { console.log(err) });
                }

                var getMagazines = function(gameId) {
                    client.search({
                        "index": zxinfo_index,
                        "type": zxinfo_type,
                        "body": {
                            "size": 0,
                            "query": {
                                "match": {
                                    "_id": gameId
                                }
                            },
                            "aggs": {
                                "magrefs": {
                                    "nested": {
                                        "path": "magazinereview"
                                    },
                                    "aggs": {
                                        "magazine": {
                                            "terms": {
                                                "size": 5000,
                                                "field": "magazinereview.magazine.raw",
                                                "order": {
                                                    "_term": "asc"
                                                }
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
                        for (; i < aggs.magrefs.magazine.buckets.length; i++) {
                            var bucket = aggs.magrefs.magazine.buckets[i];
                            var item = { name: bucket.key, count: bucket.doc_count };
                            items.push(item);
                        }
                        $scope.magazinenames = items;
                    }).catch(function(err) { console.log(err) });
                }

                $scope.filterByMagazine = function(name) {
                    $scope.magsearch = { magazine: name };
                }

                $scope.cancel = function() {
                    $mdDialog.cancel();
                };
                $scope.hide = function() {
                    $mdDialog.hide();
                };

                $scope.answer = function(answer) {
                    $mdDialog.hide(answer);
                };

                $scope.getGameByPublisher = function(title, publisher) {
                    $scope.item = {};
                    $scope.imageArray = [];
                    searchService.getgamebypublisher(title, publisher).then(function(result) {
                        var images = result.screens;
                        var i = 0,
                            x = 0,
                            add, itemArray = [];
                        for (; i < images.length; i++) {
                            add = images[i];
                            if (add.type == 'Loading screen' && "Picture" == add.format) {
                                itemArray.push({
                                    src: media_url + add.url,
                                    title: add.title
                                });
                            } else if (add.type == 'In-game screen' && "Picture" == add.format) {
                                itemArray.push({
                                    src: media_url + add.url,
                                    title: add.title
                                });
                            }
                        }

                        $scope.item = result;
                        getMagazines(result._id);
                        moreLikeThis(result._id);
                        $scope.shareurl = $scope.surl + '/details/' + $scope.item._id;

                        $scope.imageArray = itemArray;
                    });
                };

                var surl = $location.protocol() + "://" + $location.host();
                if ($location.port() !== 80) {
                    surl = surl + ":" + $location.port();
                }

                $scope.surl = surl;
                $scope.showshareurl = false;
                $scope.toogleShareUrl = function() {
                    $scope.showshareurl = !$scope.showshareurl;
                }

                searchService.getgame(gameId).then(function(result) {
                    $scope.item = {};
                    $scope.imageArray = [];

                    var prepend = function(value, array) {
                        var newArray = array.slice(0);
                        newArray.unshift(value);
                        return newArray;
                    }

                    var images = result.screens;
                    var i = 0,
                        add, itemArray = []; //[src: 'http://sinclair.kolbeck.dk/images/empty.png'
                    for (;
                        (images !== undefined) && (i < images.length); i++) {
                        add = images[i];
                        if (add.type == 'Loading screen' && "Picture" == add.format) {
                            itemArray = prepend({ src: media_url + add.url, title: add.title }, itemArray);
                        } else if (add.type == 'In-game screen' && "Picture" == add.format) {
                            itemArray.push({
                                src: media_url + add.url,
                                title: add.title
                            });
                        }
                    }
                    $scope.item = result;
                    getMagazines(gameId);
                    moreLikeThis(gameId);
                    $scope.shareurl = $scope.surl + '/details/' + $scope.item._id;

                    $scope.imageArray = itemArray;
                });

                return [];
            }

            $scope.showGameDetails = function(ev, gameId) {
                $mdDialog.show({
                        locals: {
                            gameId: gameId
                        },
                        controller: DialogController,
                        templateUrl: 'components/gamedetails/gamedetails.html',
                        parent: angular.element(document.body),
                        targetEvent: ev,
                        clickOutsideToClose: true,
                        fullscreen: true // Only for -xs, -sm breakpoints.
                    })
                    .then(function(answer) {
                        $scope.status = 'You said the information was "' + answer + '".';
                    }, function() {
                        $scope.status = 'You cancelled the dialog.';
                    });
            };

            if ($scope.gameId !== undefined) {
                $scope.showGameDetails('', $scope.gameId);
            }
        }
    ]);
