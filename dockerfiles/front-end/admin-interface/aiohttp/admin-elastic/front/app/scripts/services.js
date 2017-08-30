'use strict';

angular.module('sps')
    .factory('songFactory',['$http', 'httpBaseUrl', function($http,httpBaseUrl) {
        var songfac = {};
        var inGroup = false;
        var proposed = [];
        songfac.getSongsInfo = function(){
            return $http.get(httpBaseUrl+"api/songs/?text=exclude&artist=name");
        };
        songfac.getSongInfo = function(index){
            return $http.get(httpBaseUrl+"api/songs/" + index +"/?text=exclude&artist=name");
        };
        songfac.getSong = function (index) {
            return $http.get(httpBaseUrl+"api/songs/"+index + "/?artist=name");
        };
        songfac.getArtists = function () {
            return $http.get(httpBaseUrl+"api/artists");
        };
        songfac.setInGroup = function (isIn) {
            inGroup = isIn;
        };
        songfac.getInGroup = function () {
            return inGroup;
        };
        songfac.setProposed = function (newprop) {
            proposed = newprop;
        };
        songfac.getProposed = function () {
            return proposed;
        };
        songfac.askSong = function(artist, title) {
            var song = {};
            var config = {
                headers : {
                    'Content-Type': 'application/json;charset=utf-8;'
                }
            };
            song.artist = artist;
            song.title = title;
            return $http.post(httpBaseUrl+"propose", JSON.stringify(song), config);
        };
        songfac.addSong = function(id) {
            return $http.get(httpBaseUrl+"propose/"+id);
        }
        return songfac;
    }])
    .factory('groupFactory', function($http, $websocket, httpBaseUrl, wsBaseUrl) {
        var groupfac = {};
        var proposed = [];
        groupfac.token = '';
        var socket = {};
        groupfac.setSocket = function(newsock) {
            socket = newsock;
        };
        groupfac.getSocket = function() {
            return socket;
        };
        var regex =  new RegExp("[0-9a-fA-F]{16}");
        groupfac.getProposed = function(){
            return proposed;
        };
        groupfac.setProposed = function (newprop) {
            proposed = newprop;
        };
        groupfac.getNowPlaying = function(){
            return nowplaying;
        };
        groupfac.setNowPlaying = function(){
            return nowplaying;
        };
        groupfac.getToken = function() {
            return groupfac.token;
        };
        groupfac.setToken = function(token) {
            groupfac.token = token;
        };
        groupfac.connect = function() {
            return (wsBaseUrl + "/" + groupfac.token);
        };
        groupfac.joinGroup = function(password) {
            var got = true;
            var resp = {};
            if (typeof password === "string") {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', httpBaseUrl+"party/register/" + password, false);
                xhr.send();
                resp = JSON.parse(xhr.responseText);
                if (xhr.status != 200)
                    return 1;

                if (resp.token == '') {
                    return 2;
                } else if (regex.test(resp.token)) {
                    groupfac.token = resp.token;
                    return 0;
                } else {
                    return 1;
                }
            } else {
                return false;
            }
        };
        groupfac.createGroup = function(password) {
            var resp = {};
            if (typeof password === "string") {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', httpBaseUrl+"party/new/" + password, false);
                xhr.send();
                resp = JSON.parse(xhr.responseText);
                if (xhr.status != 200)
                    return 1;

                if (resp.token == '') {
                    return 2; //Group exists|not
                } else if (true) {
                    groupfac.token = resp.token;
                    return 0;
                } else {
                    return 1; //server problem 
                }
            } else {
                return 1;
            }
        };

        return groupfac;
    });




