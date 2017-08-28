'use strict';
/**
  Faceted search - based on: https://blog.madewithlove.be/post/faceted-search-using-elasticsearch/

  * machinetype
  * control

*/

angular.module('zxinfoApp.test', ['ngRoute', 'zxinfoApp.search.searchUtils'])
    .service('client', function(esFactory) {
        return esFactory({
            host: es_host,
            apiVersion: es_apiVersion,
            log: es_log
        });
    })
    .config(['$routeProvider', function($routeProvider) {
        $routeProvider.when('/test', {
            templateUrl: 'test/test.html',
            controller: 'TestCtrl'
        })
    }])
    .controller('TestCtrl', ['$q', '$scope', 'searchService', 'searchUtilities', '$routeParams', 'client',
        function testViewCtrl($q, $scope, searchService, searchUtilities, $routeParams, client) {

            $scope.machinetypeselected = [];
            $scope.controlselected = [];
            $scope.multiplayermodeselected = [];
            $scope.multiplayertypeselected = [];
            $scope.originalpublicationselected = [];
            $scope.availabilityselected = [];

            var facets = {
                machinetype: $scope.machinetypeselected,
                control: $scope.controlselected,
                multiplayermode: $scope.multiplayermodeselected,
                multiplayertype: $scope.multiplayertypeselected,
                originalpublication: $scope.originalpublicationselected,
                availability: $scope.availabilityselected
            };

            $scope.toggle = function(item, list) {
                var idx = list.indexOf(item);
                if (idx > -1) {
                    list.splice(idx, 1);
                } else {
                    list.push(item);
                }
            };

            $scope.exists = function(item, list) {
                return list.indexOf(item) > -1;
            };

            var sHelper = searchUtilities;
            sHelper.init($scope);

            $scope.search = function() {
                return sHelper.search();
            }

            // sHelper.search();
            $scope.loadMore = function() {
                return sHelper.loadmore(facetSearch(facets, searchService, $q, client, $scope.page++));
            }

            $scope.search();
        }
    ]);

var facetSearch = function(facets, searchService, $q, client, offset) {
    var deferred = $q.defer();

    /**
      Build query

      * machinetype
      * control (nested)

    */

    var filters = [];

    /**

    MACHINETYPE
    -----------
    {
       "bool": {
          "should": [
             {
                "match": {
                   "machinetype": "ZX-Spectrum 48K"
                }
             },
             {
                "match": {
                   "machinetype": "ZX-Spectrum 128K"
                }
             }
          ]
       }
    }
    */

    var machinetype = facets.machinetype;
    var machinetype_should = {};
    if (machinetype.length > 0) {
        var i = 0;
        var should = [];
        /**
        MATCH ITEM
        ----------
        {
           "match": {
              "machinetype": "ZX-Spectrum 48K"
           }
        }

        */

        for (; i < machinetype.length; i++) {
            var machine = { match: { machinetype: machinetype[i] } };
            should.push(machine)
        }

        machinetype_should = { bool: { should: should } };
        filters.push(machinetype_should);
    }


    /**

    CONTROL (nested)
    -----------
    {
       "bool": {
          "should": [
             {
                "nested": {
                   "path": "controls",
                   "query": {
                      "bool": {
                         "should": [
                            {
                               "match": {
                                  "controls.control": "Cursor"
                               }
                            },
                            {
                               "match": {
                                  "controls.control": "Kempston"
                               }
                            }
                         ]
                      }
                   }
                }
             }
          ]
       }
    }
    */


    var controls = facets.control;
    var controls_should = {};

    if (controls.length > 0) {
        var i = 0;
        var should = [];
        /**
        MATCH ITEM
        ----------
        {
          "match": {
            "controls.control": "Cursor"
          }
        }
        */

        for (; i < controls.length; i++) {
            var control = { match: { "controls.control": controls[i] } };
            should.push(control)
        }

        controls_should = { bool: { should: [{ nested: { path: "controls", query: { bool: { should: should } } } }] } };
        filters.push(controls_should);
    }


    var multiplayermode = facets.multiplayermode;
    var multiplayermode_should = {};
    if (multiplayermode.length > 0) {
        var i = 0;
        var should = [];
        /**
        MATCH ITEM
        ----------
        {
           "match": {
              "machinetype": "ZX-Spectrum 48K"
           }
        }

        */

        for (; i < multiplayermode.length; i++) {
            var item = { match: { multiplayermode: multiplayermode[i] } };
            should.push(item)
        }

        multiplayermode_should = { bool: { should: should } };
        filters.push(multiplayermode_should);
    }

    var multiplayertype = facets.multiplayertype;
    var multiplayertype_should = {};
    if (multiplayertype.length > 0) {
        var i = 0;
        var should = [];
        /**
        MATCH ITEM
        ----------
        {
           "match": {
              "machinetype": "ZX-Spectrum 48K"
           }
        }

        */

        for (; i < multiplayertype.length; i++) {
            var item = { match: { multiplayertype: multiplayertype[i] } };
            should.push(item)
        }

        multiplayertype_should = { bool: { should: should } };
        filters.push(multiplayertype_should);
    }


    var originalpublication = facets.originalpublication;
    var originalpublication_should = {};
    if (originalpublication.length > 0) {
        var i = 0;
        var should = [];
        /**
        MATCH ITEM
        ----------
        {
           "match": {
              "machinetype": "ZX-Spectrum 48K"
           }
        }

        */

        for (; i < originalpublication.length; i++) {
            var item = { match: { originalpublication: originalpublication[i] } };
            should.push(item)
        }

        originalpublication_should = { bool: { should: should } };
        filters.push(originalpublication_should);
    }

    var availability = facets.availability;
    var availability_should = {};
    if (availability.length > 0) {
        var i = 0;
        var should = [];
        /**
        MATCH ITEM
        ----------
        {
           "match": {
              "machinetype": "ZX-Spectrum 48K"
           }
        }

        */

        for (; i < availability.length; i++) {
            var item = { match: { availability: availability[i] } };
            should.push(item)
        }

        availability_should = { bool: { should: should } };
        filters.push(availability_should);
    }

    client.search({
        "index": zxinfo_index,
        "type": zxinfo_type,
        "body": {
            "size": PAGE_SIZE,
            "from": offset * PAGE_SIZE,

            "query": {
                "match_all": {}
            },
            // FILTER
            "filter": {
                "bool": {
                    "must": filters
                }
            },
            "sort": [{
                "fulltitle.raw": {
                    "order": "asc"
                }
            }],
            "aggregations": {
                "all_entries": {
                    "global": {},
                    "aggregations": {
                        "machinetypes": {
                            "filter": {
                                "bool": {
                                    "must": [controls_should, multiplayermode_should, multiplayertype_should, originalpublication_should, availability_should]
                                }
                            },
                            "aggregations": {
                                "filtered_machinetypes": {
                                    "terms": {
                                        "size": 0,
                                        "field": "machinetype",
                                        "order": {
                                            "_term": "desc"
                                        }
                                    }
                                }
                            }
                        },
                        "controls": {
                            "filter": {
                                "bool": {
                                    "must": [machinetype_should, multiplayermode_should, multiplayertype_should, originalpublication_should, availability_should]
                                }
                            },
                            "aggregations": {
                                "controls": {
                                    "nested": {
                                        "path": "controls"
                                    },
                                    "aggregations": {
                                        "filtered_controls": {
                                            "terms": {
                                                "size": 0,
                                                "field": "controls.control",
                                                "order": {
                                                    "_term": "asc"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        "multiplayermode": {
                            "filter": {
                                "bool": {
                                    "must": [machinetype_should, controls_should, multiplayertype_should, availability_should, originalpublication_should]
                                }
                            },
                            "aggregations": {
                                "filtered_multiplayermode": {
                                    "terms": {
                                        "size": 0,
                                        "field": "multiplayermode",
                                        "order": {
                                            "_term": "asc"
                                        }
                                    }
                                }
                            }
                        },
                        "multiplayertype": {
                            "filter": {
                                "bool": {
                                    "must": [machinetype_should, controls_should, multiplayermode_should, availability_should, originalpublication_should]
                                }
                            },
                            "aggregations": {
                                "filtered_multiplayertype": {
                                    "terms": {
                                        "size": 0,
                                        "field": "multiplayertype",
                                        "order": {
                                            "_term": "asc"
                                        }
                                    }
                                }
                            }
                        },
                        "originalpublication": {
                            "filter": {
                                "bool": {
                                    "must": [machinetype_should, controls_should, multiplayermode_should, multiplayertype_should, availability_should]
                                }
                            },
                            "aggregations": {
                                "filtered_originalpublication": {
                                    "terms": {
                                        "size": 0,
                                        "field": "originalpublication",
                                        "order": {
                                            "_term": "asc"
                                        }
                                    }
                                }
                            }
                        },
                        "availability": {
                            "filter": {
                                "bool": {
                                    "must": [machinetype_should, controls_should, multiplayermode_should, multiplayertype_should, originalpublication_should]
                                }
                            },
                            "aggregations": {
                                "filtered_availability": {
                                    "terms": {
                                        "size": 0,
                                        "field": "availability",
                                        "order": {
                                            "_term": "asc"
                                        }
                                    }
                                }
                            }
                        }
                        /** insert new here */
                    }
                }
            }

        } // end body
    }).then(function(result) {
        var hitsOut = searchService.mapgames(result);

        deferred.resolve({
            timeTook: result.took,
            hitsCount: result.hits.total,
            hits: hitsOut,
            facets: result.aggregations
        });
    });

    return deferred.promise;
}