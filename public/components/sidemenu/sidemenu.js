'use strict';

angular.module('zxinfoApp.sidemenu.sideMenu', ['ngRoute'])
.service('client', function(esFactory) {
    return esFactory({
        host: es_host,
        apiVersion: es_apiVersion,
        log: es_log
    });
})
.controller('sideMenuCtrl', ['$scope', '$routeParams', 'client',
    function sideMenuCtrl($scope, $routeParams, client) {
        $scope.gametypes = [];
        $scope.machinetypes = [];

        var getGameTypes = function() {
	        client.search({
	            "index": zxinfo_index,
	            "type": zxinfo_type,
	            "body": {
					"size": 0,
					   "aggs": {
					      "types": {
					         "terms": {
					         "size" : 0,
					            "field": "type",
					            "order" : { "_term" : "asc" }
					         }
					      }
					   }
	            }
	        }).then(function(result) {
	        	var aggs = result.aggregations;
	        	var items = [];
	            var i = 0;
	            for (; i < aggs.types.buckets.length; i++) {
	            	var bucket = aggs.types.buckets[i];
	            	var item = {name: bucket.key, count: bucket.doc_count};
	            	items.push(item);
	            }
	            $scope.gametypes = items;
	        }).catch(function(err) { console.log(err) });
        }

        var getMachineTypes = function() {
	        client.search({
	            "index": zxinfo_index,
	            "type": zxinfo_type,
	            "body": {
					"size": 0,
					   "aggs": {
					      "types": {
					         "terms": {
					         "size" : 0,
					            "field": "machinetype",
					            "order" : { "_term" : "desc" }
					         }
					      }
					   }
	            }
	        }).then(function(result) {
	        	var aggs = result.aggregations;
	        	var items = [];
	            var i = 0;
	            for (; i < aggs.types.buckets.length; i++) {
	            	var bucket = aggs.types.buckets[i];
	            	var item = {name: bucket.key, count: bucket.doc_count};
	            	items.push(item);
	            }
	            $scope.machinetypes = items;
	        }).catch(function(err) { console.log(err) });
        }

        getGameTypes();
        getMachineTypes();
    }
]);
