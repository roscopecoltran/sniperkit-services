'use strict';

function loadscreen(source) {
    // iterate all additionals to find loading screen, if any
    var loadscreen = "/images/empty.png";
    if (source.type == "Compilation") {
        loadscreen = "/images/compilation.png";
    } else if (typeof(source.screens) != "undefined") {
        var idx = 0;
        var screen = null;
        for (; screen == null && idx < source.screens.length; idx++) {
            if ("Loading screen" == source.screens[idx].type && "Picture" == source.screens[idx].format) {
                screen = source.screens[idx].url;
                loadscreen = source.screens[idx].url;
            }
        }
    }
    return loadscreen;
}

angular.module('zxinfoApp.search.search', ['ngResource'])
    .factory('searchService', ['$q', '$resource', function($q, $resource) {
        var mapSingleGame = function(result) {
            var g = {};
            var r = result._source;
            // Map result from Elasticsearch to result object
            g._id = result._id;
            g.fulltitle = r.fulltitle;
            g.alsoknownas = r.alsoknownas;

            g.loadscreen = media_url + loadscreen(r);
            g.screens = r.screens;
            g.yearofrelease = r.yearofrelease;
            g.publisher = r.publisher;
            g.releases = r.releases;
            g.authors = r.authors;
            g.roles = r.roles;
            g.licensed = r.licensed;
            g.authoring = r.authoring;
            g.authored = r.authored;

            g.machinetype = r.machinetype;

            if (r.numberofplayers == null) {
                g.numberofplayers = undefined;
            } else {
                g.numberofplayers = r.numberofplayers;

                if (r.multiplayermode != null) {
                    g.numberofplayers += " - " + r.multiplayermode;
                }
                if (r.multiplayertype != null) {
                    g.numberofplayers += "(" + r.multiplayertype + ")";
                }
            }
            g.controls = r.controls;
            g.type = r.type;
            g.subtype = r.subtype;
            g.isbn = r.isbn;
            g.messagelanguage = r.messagelanguage;
            g.originalpublication = r.originalpublication;
            g.originalprice = r.originalprice;
            g.budgetprice = r.budgetprice;
            g.availability = r.availability;

            // ZXDB
            g.features = r.features;
            g.sites = r.sites;
            g.incompilations = r.incompilations;
            g.booktypeins = r.booktypeins;

            g.series = r.series;
            g.spotcomments = r.spotcomments;
            g.knownerrors = r.knownerrors;
            g.remarks = r.remarks;
            g.othersystems = r.othersystems;
            g.score = r.score;
            g.contents = r.contents;

            // iterate releases to find downloads and available format and encodingschemes
            g.availableformat = [];
            g.protectionscheme = [];
            g.downloads = [];
            var ridx = 0;
            for (; g.releases !== undefined && ridx < g.releases.length; ridx++) {
                if (g.availableformat.indexOf(g.releases[ridx].format) < 0) {
                    g.availableformat.push(g.releases[ridx].format);
                }
                if (g.protectionscheme.indexOf(g.releases[ridx].encodingscheme) < 0) {
                    g.protectionscheme.push(g.releases[ridx].encodingscheme);
                }
                if (g.releases[ridx].filename !== null) {
                    var download = {
                        filename: r.releases[ridx].filename,
                        url: r.releases[ridx].url,
                        type: r.releases[ridx].type,
                        format: r.releases[ridx].format,
                        encodingscheme: r.releases[ridx].encodingscheme,
                        origin: r.releases[ridx].origin
                    };
                    g.downloads.push(download);
                }
            }
            g.availableformat.sort();
            g.protectionscheme.sort();

            g.additionals = r.additionals;
            g.magazines = r.magrefs;

            /**
                From ZXDB.txt:
                * magazines - published magazines (printed or electronic). The magazine link mask follows this convention:
                    -> "{iN}": magazine issue number, with N digits
                    -> "{vN}": magazine issue volume number, with N digits
                    -> "{yN}": magazine issue year, with N digits
                    -> "{mN}": magazine issue month, with N digits
                    -> "{dN}": magazine issue day, with N digits
                    -> "{pN}": page number, with N digits

            */

            function replaceMask(input, pattern, value) {
                var result = input;
                var found = input.match(pattern);
                if (found != null) {
                    var template = found[0];
                    var padding = found[1];
                    var zero = ("0".repeat(padding) + value).slice(-padding);
                    var re = new RegExp(template, "g");
                    result = input.replace(re, zero);
                }
                return result;
            }

            var i = 0;
            for (; i < r.magazinereview.length; i++) {
                var link_mask = r.magazinereview[i].link_mask;
                if (link_mask != null) {
                    // console.log("BEFORE - ", link_mask);
                    link_mask = replaceMask(link_mask, /{i(\d)+}/i, r.magazinereview[i].issueno);
                    link_mask = replaceMask(link_mask, /{v(\d)+}/i, r.magazinereview[i].issuevolume);
                    link_mask = replaceMask(link_mask, /{y(\d)+}/i, r.magazinereview[i].issueyear);
                    link_mask = replaceMask(link_mask, /{m(\d)+}/i, r.magazinereview[i].issuemonth);
                    link_mask = replaceMask(link_mask, /{d(\d)+}/i, r.magazinereview[i].issueday);
                    link_mask = replaceMask(link_mask, /{p(\d)+}/i, r.magazinereview[i].pageno);
                    r.magazinereview[i].maglink = 'https://archive.zx-spectrum.org.uk/WoS' + link_mask;
                    // console.log("AFTER - ", link_mask);
                }
            }
            g.magazinereview = r.magazinereview;

            g.adverts = r.adverts;
            g.tosec = r.tosec;
            g.highlight = r.highlight;

            return g;
        };

        /**
         * Map fields required for search results page.
         */
        var mapListOfGames = function(result) {
            var i = 0,
                hitsIn, hitsOut = [],
                source;
            hitsIn = (result.hits || {}).hits || [];
            for (; i < hitsIn.length; i++) {
                //source = hitsIn[i]._source;
                source = {};
                source.fulltitle = hitsIn[i]._source.fulltitle;
                source.yearofrelease = hitsIn[i]._source.yearofrelease;
                source.publisher = hitsIn[i]._source.publisher;
                source.machinetype = hitsIn[i]._source.machinetype;
                source.type = hitsIn[i]._source.type;
                source.availability = hitsIn[i]._source.availability;
                source.releases = hitsIn[i]._source.releases;

                source.screens = hitsIn[i]._source.screens;

                source._id = hitsIn[i]._id;
                source._index = hitsIn[i]._index;
                source._type = hitsIn[i]._type;
                source._score = hitsIn[i]._score;
                source.highlight = hitsIn[i].highlight;

                source._loadscreen = media_url + loadscreen(source);
                // iterate downloads to find available format
                source.availableformat = [];
                var schemes = 0;
                for (; source.releases !== undefined && schemes < source.releases.length; schemes++) {
                    if ((source.releases[schemes].format !== null) && (source.availableformat.indexOf(source.releases[schemes].format)) < 0) {
                        source.availableformat.push(source.releases[schemes].format);
                    }
                }
                source.availableformat.sort();
                hitsOut.push(source);
            }
            return hitsOut;
        };

        var getGame = function(gameid) {
            var deferred = $q.defer();
            var game = $resource(api_url + '/zxinfo/games/:gameid');
            game.get({
                    gameid: gameid
                })
                .$promise.then(function(result) {
                    var g = mapSingleGame(result);

                    deferred.resolve(g);
                }, deferred.reject);

            return deferred.promise;
        };

        var getGameByPublisher = function(title, publisher) {
            var deferred = $q.defer();
            var game = $resource(api_url + '/zxinfo/publishers/:pub/games/:title');
            game.get({
                    pub: publisher,
                    title: title
                })
                .$promise.then(function(result) {
                    var g = mapSingleGame(result);

                    deferred.resolve(g);
                }, deferred.reject);

            return deferred.promise;
        };

        var search = function(query, offset) {
            var deferred = $q.defer();

            if (query.length === 0) {
                deferred.resolve({
                    timeTook: 0,
                    hitsCount: 0,
                    hits: []
                });
                return deferred.promise;
            }

            var games = $resource(api_url + '/zxinfo/games/search/:query');
            games.get({
                    query: query,
                    offset: offset,
                    size: PAGE_SIZE
                })
                .$promise.then(function(result) {
                    var hitsOut = mapListOfGames(result);
                    deferred.resolve({
                        timeTook: result.took,
                        hitsCount: result.hits.total,
                        hits: hitsOut
                    });
                }, deferred.reject);

            return deferred.promise;
        };

        var searchByPublisher = function(name, offset) {
            var deferred = $q.defer();

            if (name.length === 0) {
                deferred.resolve({
                    timeTook: 0,
                    hitsCount: 0,
                    hits: []
                });
                return deferred.promise;
            }

            var publisher = $resource(api_url + '/zxinfo/publishers/:name/games');
            publisher.get({
                    name: name,
                    offset: offset,
                    size: PAGE_SIZE
                })
                .$promise.then(function(result) {
                    var hitsOut = mapListOfGames(result);
                    deferred.resolve({
                        timeTook: result.took,
                        hitsCount: result.hits.total,
                        hits: hitsOut
                    });
                }, deferred.reject);

            return deferred.promise;
        };


        var searchAllGames = function(filterObject, offset) {
            var deferred = $q.defer();

            var games = $resource(api_url + '/zxinfo/games');
            var requestObject = Object.assign({
                    offset: offset,
                    size: PAGE_SIZE
                }, filterObject);

            games.get(requestObject)
                .$promise.then(function(result) {
                    var hitsOut = mapListOfGames(result);
                    deferred.resolve({
                        timeTook: result.took,
                        hitsCount: result.hits.total,
                        hits: hitsOut
                    });
                }, deferred.reject);

            return deferred.promise;
        };

        var searchAllGamesByGroup = function(groupid, groupname, offset) {
            var deferred = $q.defer();

            var games = $resource(api_url + '/zxinfo/group/:groupid/:groupname/games');

            games.get({
                    groupid: groupid,
                    groupname: groupname,
                    offset: offset,
                    size: PAGE_SIZE
                })
                .$promise.then(function(result) {
                    var hitsOut = mapListOfGames(result);
                    deferred.resolve({
                        timeTook: result.took,
                        hitsCount: result.hits.total,
                        hits: hitsOut
                    });
                }, deferred.reject);

            return deferred.promise;
        };

        var getAllScreens = function(offset) {
            var deferred = $q.defer();

            var games = $resource(api_url + '/zxinfo/screens/loading');
            games.get({
                    offset: offset,
                    size: PAGE_SIZE
                })
                .$promise.then(function(result) {
                    var hitsOut = mapListOfGames(result);
                    deferred.resolve({
                        timeTook: result.took,
                        hitsCount: result.hits.total,
                        hits: hitsOut
                    });
                }, deferred.reject);

            return deferred.promise;
        };

        return {
            "search": search,
            "searchpublisher": searchByPublisher,
            "getallgames": searchAllGames,
            "getallgamesbygroup": searchAllGamesByGroup,
            "getgame": getGame,
            "getgamebypublisher": getGameByPublisher,
            "getallscreens": getAllScreens,
            "mapgames": mapListOfGames
        };

    }]);