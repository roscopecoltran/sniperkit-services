(function () {
    "use strict";
    var onSubmitError = function(error, form, progression, notification) {
            // mark fields based on errors from the response
            if (!('error_details' in error.data)){
                return true;
            }
            _.mapObject(error.data.error_details, function(error_msg, field_name) {
                if (form[field_name]) {
                    form[field_name].$valid = false;
                }
                return {}
            });
            // stop the progress bar
            progression.done();
            // add a notification
            notification.log('Some values are invalid, see details in the form',
                             { addnCls: 'humane-flatty-error' });
            // cancel the default action (default error messages)
            return false;
        }

    var app = angular.module('aiohttp_admin', ['ng-admin']);
    app.config(['RestangularProvider', function(RestangularProvider) {
        var token = window.localStorage.getItem('aiohttp_admin_token');
        RestangularProvider.setDefaultHeaders({'Authorization': token});
    }]);

    app.config(['NgAdminConfigurationProvider', function (NgAdminConfigurationProvider) {
        var nga = NgAdminConfigurationProvider;

        var admin = nga.application("aiohttp_admin")
            .debug(true)
            .baseApiUrl('/admin/');

        admin.errorMessage(function (response) {
            var msg = '<p>Oops error occured with status code: ' + response.status + '</p>\n';

            if ('error_details' in response.data ){
                msg += '<code>';
                msg += JSON.stringify(response.data.error_details, null, 2);
                msg += '</code>';
            }
            return msg;
        });

        var artist = nga.entity('artist').identifier(nga.field('id'));
        var song = nga.entity('song').identifier(nga.field('id'));
        var party = nga.entity('party').identifier(nga.field('password'));
        

        admin.addEntity(artist);
        admin.addEntity(song);
        admin.addEntity(party);
        
            
artist.listView()
    .title('List entity artist')
    .description('List of artist')
    .perPage(50)
    .fields([
        nga.field('id', 'number').isDetailLink(true),
        nga.field('name').isDetailLink(true),
            
    ])
    .sortField('id')
    .listActions(['show', 'edit', 'delete']);

            
artist.creationView()
    .title('Create entity artist')
    .fields([
        nga.field('name', 'string'),
        
    ]);
artist.creationView()
    .onSubmitError(['error', 'form', 'progression', 'notification', onSubmitError]);

            
artist.editionView()
    .title('Edit entity artist')
    .fields([
        nga.field('id', 'number').editable(false),
            
        nga.field('name', 'string'),
            
    ]);
artist.editionView()
    .onSubmitError(['error', 'form', 'progression', 'notification', onSubmitError]);

            
artist.showView()
    .title('Show entity artist')
    .fields([
        nga.field('id', 'number'),
        nga.field('name', 'string'),
        
    ]);

            
artist.deletionView()
    .title('Deletion confirmation for entity artist');

        
            
song.listView()
    .title('List entity song')
    .description('List of song')
    .perPage(50)
    .fields([
        nga.field('id', 'number').isDetailLink(true),
        nga.field('title', 'string').isDetailLink(true),,
        nga.field('artist_id', 'reference')
            .label('Artist')
            .targetEntity(artist)
            .targetField(nga.field('name'))
            .singleApiCall(function (ids) {
                return {'id': {'in': ids}};
            })
    ])
    .sortField('id')
    .listActions(['show', 'edit', 'delete']);

            
song.creationView()
    .title('Create entity song')
    .fields([
        nga.field('title', 'string'),
        nga.field('artist_id', 'reference')
            .targetEntity(artist)
            .targetField(nga.field('name'))
            .sortField('name')
            .sortDir('ASC')
            .validation({required: true})
            .remoteComplete(true, {
                refreshDelay: 200,
                searchQuery: function (search) {
                    return {q: search};
                }
            }),

        nga.field('text', 'text'),
        
    ]);
song.creationView()
    .onSubmitError(['error', 'form', 'progression', 'notification', onSubmitError]);

            
song.editionView()
    .title('Edit entity song')
    .fields([
        nga.field('id', 'number').editable(false),
        song.creationView().fields()
    ]);
song.editionView()
    .onSubmitError(['error', 'form', 'progression', 'notification', onSubmitError]);

            
song.showView()
    .title('Show entity song')
    .fields([
        nga.field('id', 'number'),
        nga.field('artist_id', 'number'),
        nga.field('title', 'string'),
        nga.field('text', 'text')
        
    ]);

            
song.deletionView()
    .title('Deletion confirmation for entity song');

party.listView()
     .title('List entity party')
     .description('List of party')
     .perPage(50)
     .fields([
         nga.field('password', 'string').isDetailLink(true),
         nga.field('master_token', 'string').isDetailLink(true),
         nga.field('user_token', 'string').isDetailLink(true)
    ])
    .sortField('password')
    .listActions(['show', 'edit', 'delete']);


party.creationView()
     .title('Create entity party')
     .fields([
         nga.field('password', 'string'),
         nga.field('master_token', 'string'),
         nga.field('user_token', 'string')

    ]);
party.creationView()
     .onSubmitError(['error', 'form', 'progression', 'notification', onSubmitError]);


party.editionView()
     .title('Edit entity party')
     .fields([
         nga.field('password', 'string').editable(false),
         nga.field('master_token', 'string'),
         nga.field('user_token', 'string')

    ]);
party.editionView()
     .onSubmitError(['error', 'form', 'progression', 'notification', onSubmitError]);


party.showView()
     .title('Show entity party')
     .fields([
         nga.field('password', 'string'),
         nga.field('master_token', 'string'),
         nga.field('user_token', 'string')
    ]);


party.deletionView()
    .title('Deletion confirmation for entity party');

nga.configure(admin);
    }]);

}());