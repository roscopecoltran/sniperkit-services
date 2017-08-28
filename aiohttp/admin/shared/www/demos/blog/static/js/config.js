/*global angular*/

/*
 * This is an example ng-admin configuration for a blog administration composed
 * of three entities: post, comment, and tag. Reading the code and the comments
 * will help you understand how a typical ng-admin application works. You can
 * browse the result online at http://ng-admin.marmelab.com.
 *
 * The remote REST API is simulated in the browser, using FakeRest
 * (https://github.com/marmelab/FakeRest). Look at the JSON responses in the
 * browser console to see the data used by ng-admin.
 *
 * For simplicity's sake, the entire configuration is written in a single file,
 * but in a real world situation, you would probably split that configuration
 * into one file per entity. For another example configuration on a larger set
 * of entities, and using the best development practices, check out the
 * Posters Galore demo (http://marmelab.com/ng-admin-demo/).
 */
(function () {
    'use strict';

    var app = angular.module('aiohttp_admin', ['ng-admin']);

    app.config(['RestangularProvider', function(RestangularProvider) {
        var token = window.localStorage.getItem('aiohttp_admin_token');
        RestangularProvider.setDefaultHeaders({'Authorization': token});
    }]);

    app.config(['NgAdminConfigurationProvider', function (NgAdminConfigurationProvider) {
        var nga = NgAdminConfigurationProvider;

        function truncate(value) {
            if (!value) {
                return '';
            }

            return value.length > 50 ? value.substr(0, 50) + '...' : value;
        }

        var admin = nga.application('ng-admin backend demo') // application main title
            .debug(false) // debug disabled
            .baseApiUrl('/admin/'); // main API endpoint

        // define all entities at the top to allow references between them
        var post = nga.entity('posts'); // the API endpoint for posts will be http://localhost:3000/posts/:id

        var comment = nga.entity('comments')
            .baseApiUrl('/admin/') // The base API endpoint can be customized by entity
            .identifier(nga.field('id')); // you can optionally customize the identifier used in the api ('id' by default)

        var tag = nga.entity('tags')
            .readOnly(); // a readOnly entity has disabled creation, edition, and deletion views

        var subCategories = [
            { category: 'tech', label: 'Computers', value: 'computers' },
            { category: 'tech', label: 'Gadgets', value: 'gadgets' },
            { category: 'lifestyle', label: 'Travel', value: 'travel' },
            { category: 'lifestyle', label: 'Fitness', value: 'fitness' }
        ];

        // set the application entities
        admin
            .addEntity(post)
            .addEntity(tag)
            .addEntity(comment);

        // customize entities and views

        /*****************************
         * post entity customization *
         *****************************/
        post.listView()
            .title('All posts') // default title is "[Entity_name] list"
            .description('List of posts with infinite pagination') // description appears under the title
            .infinitePagination(true) // load pages as the user scrolls
            .fields([
                nga.field('id').label('id'), // The default displayed name is the camelCase field name. label() overrides id
                nga.field('title'), // the default list field type is "string", and displays as a string
                nga.field('published_at', 'date'),  // Date field type allows date formatting
                nga.field('average_note', 'float') // Float type also displays decimal digits
                    .cssClasses('hidden-xs'),
                nga.field('views', 'number')
                    .cssClasses('hidden-xs'),
                nga.field('backlinks', 'embedded_list') // display list of related comments
                    .label('Links')
                    .map(links => links ? links.length : '')
                    .template('{{ value }}'),
                nga.field('tags', 'reference_many') // a Reference is a particular type of field that references another entity
                    .targetEntity(tag) // the tag entity is defined later in this file
                    .targetField(nga.field('name')) // the field to be displayed in this list
                    .cssClasses('hidden-xs')
                    .singleApiCall(ids => { return {'id': {'in': ids} }; })
            ])
            .filters([
                nga.field('category', 'choice').choices([
                    { label: 'Tech', value: 'tech' },
                    { label: 'Lifestyle', value: 'lifestyle' }
                ]).label('Category'),
                nga.field('subcategory', 'choice').choices(subCategories).label('Subcategory')
            ])
            .listActions(['show', 'edit', 'delete']);

        post.creationView()
            .fields([
                nga.field('title') // the default edit field type is "string", and displays as a text input
                    .attributes({ placeholder: 'the post title' }) // you can add custom attributes, too
                    .validation({ required: true, minlength: 3, maxlength: 100 }), // add validation rules for fields
                nga.field('teaser', 'text'), // text field type translates to a textarea
                nga.field('body', 'wysiwyg'), // overriding the type allows rich text editing for the body
                nga.field('published_at', 'date') // Date field type translates to a datepicker
            ]);

        post.editionView()
            .title('Edit post "{{ entry.values.title }}"') // title() accepts a template string, which has access to the entry
            .actions(['list', 'show', 'delete']) // choose which buttons appear in the top action bar. Show is disabled by default
            .fields([
                post.creationView().fields(), // fields() without arguments returns the list of fields. That way you can reuse fields from another view to avoid repetition
                nga.field('category', 'choice') // a choice field is rendered as a dropdown in the edition view
                    .choices([ // List the choice as object literals
                        { label: 'Tech', value: 'tech' },
                        { label: 'Lifestyle', value: 'lifestyle' }
                    ]),
                nga.field('subcategory', 'choice')
                    .choices(function(entry) { // choices also accepts a function to return a list of choices based on the current entry
                        return subCategories.filter(function (c) {
                            return c.category === entry.values.category;
                        });
                    }),
                nga.field('tags', 'reference_many') // ReferenceMany translates to a select multiple
                    .targetEntity(tag)
                    .targetField(nga.field('name'))
                    .attributes({ placeholder: 'Select some tags...' })
                    .remoteComplete(true, {
                        refreshDelay: 300 ,
                        searchQuery: function(search) { return { q: search }; }
                    })
                    .singleApiCall(ids => { return {'id': {'in': ids }}; })
                    .cssClasses('col-sm-4'), // customize look and feel through CSS classes
                nga.field('pictures', 'json'),
                nga.field('views', 'number')
                    .cssClasses('col-sm-4'),
                nga.field('average_note', 'float')
                    .cssClasses('col-sm-4'),
                nga.field('backlinks', 'embedded_list') // display embedded list
                    .targetFields([
                        nga.field('date', 'datetime'),
                        nga.field('url')
                            .cssClasses('col-lg-10')
                    ])
                    .sortField('date')
                    .sortDir('DESC'),
                nga.field('comments', 'referenced_list') // display list of related comments
                    .targetEntity(nga.entity('comments'))
                    .targetReferenceField('post_id')
                    .targetFields([
                        nga.field('id').isDetailLink(true),
                        nga.field('created_at').label('Posted'),
                        nga.field('body').label('Comment')
                    ])
                    .sortField('created_at')
                    .sortDir('DESC')
                    .listActions(['edit']),
                nga.field('').label('')
                    .template('<span class="pull-right"><ma-filtered-list-button entity-name="comments" filter="{ post_id: entry.values.id }" size="sm"></ma-filtered-list-button><ma-create-button entity-name="comments" size="sm" label="Create related comment" default-values="{ post_id: entry.values.id }"></ma-create-button></span>')
            ]);

        post.showView() // a showView displays one entry in full page - allows to display more data than in a a list
            .fields([
                nga.field('id'),
                nga.field('category', 'choice') // a choice field is rendered as a dropdown in the edition view
                    .choices([ // List the choice as object literals
                        { label: 'Tech', value: 'tech' },
                        { label: 'Lifestyle', value: 'lifestyle' }
                    ]),
                nga.field('subcategory', 'choice')
                    .choices(subCategories),
                nga.field('tags', 'reference_many') // ReferenceMany translates to a select multiple
                    .targetEntity(tag)
                    .targetField(nga.field('name')),
                nga.field('pictures', 'json'),
                nga.field('views', 'number'),
                nga.field('average_note', 'float'),
                nga.field('backlinks', 'embedded_list') // display embedded list
                    .targetFields([
                        nga.field('date', 'datetime'),
                        nga.field('url')
                    ])
                    .sortField('date')
                    .sortDir('DESC'),
                nga.field('comments', 'referenced_list') // display list of related comments
                    .targetEntity(nga.entity('comments'))
                    .targetReferenceField('post_id')
                    .targetFields([
                        nga.field('id').isDetailLink(true),
                        nga.field('created_at').label('Posted'),
                        nga.field('body').label('Comment')
                    ])
                    .sortField('created_at')
                    .sortDir('DESC')
                    .listActions(['edit']),
                nga.field('').label('')
                    .template('<span class="pull-right"><ma-filtered-list-button entity-name="comments" filter="{ post_id: entry.values.id }" size="sm"></ma-filtered-list-button><ma-create-button entity-name="comments" size="sm" label="Create related comment" default-values="{ post_id: entry.values.id }"></ma-create-button></span>'),
                nga.field('custom_action').label('')
                    .template('<send-email post="entry"></send-email>')
            ]);

        /********************************
         * comment entity customization *
         ********************************/
        comment.listView()
            .title('Comments')
            .perPage(10) // limit the number of elements displayed per page. Default is 30.
            .fields([
                nga.field('id'),
                nga.field('created_at', 'date')
                    .label('Posted'),
                nga.field('author.name')
                    .label('Author')
                    .cssClasses('hidden-xs'),
                nga.field('body', 'wysiwyg')
                    .stripTags(true)
                    .map(truncate),
                nga.field('post_id', 'reference')
                    .label('Post')
                    .targetEntity(post)
                    .targetField(nga.field('title').map(truncate))
                    .cssClasses('hidden-xs')
                    .singleApiCall(ids => { return {'id': {'in': ids} }; })
            ])
            .filters([
                nga.field('q')
                    .label('Search')
                    .pinned(true)
                    .attributes({'q': 'text search'}),
                nga.field('created_at', 'date')
                    .label('Posted')
                    .attributes({'placeholder': 'Filter by date'}),
                nga.field('post_id', 'reference')
                    .label('Post')
                    .targetEntity(post)
                    .targetField(nga.field('title'))
                    .remoteComplete(true, {
                        refreshDelay: 200,
                        searchQuery: function(search) { return { q: search }; }
                    })
            ])
            .listActions(['edit', 'delete']);

        comment.creationView()
            .fields([
                nga.field('created_at', 'date')
                    .label('Posted')
                    .defaultValue(new Date()), // preset fields in creation view with defaultValue
                nga.field('author.name')
                    .label('Author'),
                nga.field('body', 'wysiwyg'),
                nga.field('post_id', 'reference')
                    .label('Post')
                    .targetEntity(post)
                    .targetField(nga.field('title').map(truncate))
                    .sortField('title')
                    .sortDir('ASC')
                    .validation({ required: true })
                    .remoteComplete(true, {
                        refreshDelay: 200,
                        searchQuery: function(search) { return { q: search }; }
                    })
            ]);

        comment.editionView()
            .fields(comment.creationView().fields())
            .fields([
                nga.field('').label('')
                    .template('<post-link entry="entry"></post-link>') // template() can take a function or a string
            ]);

        comment.deletionView()
            .title('Deletion confirmation'); // customize the deletion confirmation message

        /****************************
         * tag entity customization *
         ****************************/
        tag.listView()
            .infinitePagination(false) // by default, the list view uses infinite pagination. Set to false to use regulat pagination
            .fields([
                nga.field('id').label('ID'),
                nga.field('name'),
                nga.field('published', 'boolean').cssClasses(function(entry) { // add custom CSS classes to inputs and columns
                    if(entry && entry.values){
                        if (entry.values.published) {
                            return 'bg-success text-center';
                        }
                        return 'bg-warning text-center';
                    }
                }),
                nga.field('custom')
                    .label('Upper name')
                    .template('{{ entry.values.name.toUpperCase() }}')
                    .cssClasses('hidden-xs')
            ])
            .filters([
                nga.field('published')
                    .label('Not yet published')
                    .template(' ')
                    .defaultValue(false)
            ])
            .batchActions([]) // disable checkbox column and batch delete
            .listActions(['show', 'edit']);

        tag.editionView()
            .fields([
                nga.field('name'),
                nga.field('published', 'boolean').validation({
                    required: true // as this boolean is required, ng-admin will use a checkbox instead of a dropdown
                })
            ]);

        tag.showView()
            .fields([
                nga.field('name'),
                nga.field('published', 'boolean')
            ]);

        // customize header
        var customHeaderTemplate =
        '<div class="navbar-header">' +
            '<button type="button" class="navbar-toggle" ng-click="isCollapsed = !isCollapsed">' +
              '<span class="icon-bar"></span>' +
              '<span class="icon-bar"></span>' +
              '<span class="icon-bar"></span>' +
            '</button>' +
            '<a class="navbar-brand" href="#" ng-click="appController.displayHome()">ng-admin backend demo</a>' +
        '</div>' +
        '<p class="navbar-text navbar-right hidden-xs">' +
            '<a href="https://github.com/marmelab/ng-admin/blob/master/examples/blog/config.js"><span class="glyphicon glyphicon-sunglasses"></span>&nbsp;View Source</a>' +
        '</p>';
        admin.header(customHeaderTemplate);

        // customize menu
        admin.menu(nga.menu()
            .addChild(nga.menu(post).icon('<span class="glyphicon glyphicon-file"></span>')) // customize the entity menu icon
            .addChild(nga.menu(comment).icon('<strong style="font-size:1.3em;line-height:1em">✉</strong>')) // you can even use utf-8 symbols!
            .addChild(nga.menu(tag).icon('<span class="glyphicon glyphicon-tags"></span>'))
            .addChild(nga.menu().title('Other')
                .addChild(nga.menu().title('Stats').icon('').link('/stats'))
            )
        );

        // customize dashboard
        var customDashboardTemplate =
        '<div class="row dashboard-starter"></div>' +
        '<div class="row dashboard-content"><div class="col-lg-12"><div class="alert alert-info">' +
            'Welcome to the demo! Fell free to explore and modify the data.' +
        '</div></div></div>' +
        '<div class="row dashboard-content">' +
            '<div class="col-lg-12">' +
                '<div class="panel panel-default">' +
                    '<ma-dashboard-panel collection="dashboardController.collections.comments" entries="dashboardController.entries.comments" datastore="dashboardController.datastore"></ma-dashboard-panel>' +
                '</div>' +
            '</div>' +
        '</div>' +
        '<div class="row dashboard-content">' +
            '<div class="col-lg-6">' +
                '<div class="panel panel-green">' +
                    '<ma-dashboard-panel collection="dashboardController.collections.recent_posts" entries="dashboardController.entries.recent_posts" datastore="dashboardController.datastore"></ma-dashboard-panel>' +
                '</div>' +
                '<div class="panel panel-green">' +
                    '<ma-dashboard-panel collection="dashboardController.collections.popular_posts" entries="dashboardController.entries.popular_posts" datastore="dashboardController.datastore"></ma-dashboard-panel>' +
                '</div>' +
            '</div>' +
            '<div class="col-lg-6">' +
                '<div class="panel panel-yellow">' +
                    '<ma-dashboard-panel collection="dashboardController.collections.tags" entries="dashboardController.entries.tags" datastore="dashboardController.datastore"></ma-dashboard-panel>' +
                '</div>' +
            '</div>' +
        '</div>';
        admin.dashboard(nga.dashboard()
            .addCollection(nga.collection(post)
                .name('recent_posts')
                .title('Recent posts')
                .perPage(5) // limit the panel to the 5 latest posts
                .fields([
                    nga.field('published_at', 'date').label('Published').format('MMM d'),
                    nga.field('title').isDetailLink(true).map(truncate),
                    nga.field('views', 'number')
                ])
                .sortField('published_at')
                .sortDir('DESC')
                .order(1)
            )
            .addCollection(nga.collection(post)
                .name('popular_posts')
                .title('Popular posts')
                .perPage(5) // limit the panel to the 5 latest posts
                .fields([
                    nga.field('published_at', 'date').label('Published').format('MMM d'),
                    nga.field('title').isDetailLink(true).map(truncate),
                    nga.field('views', 'number')
                ])
                .sortField('views')
                .sortDir('DESC')
                .order(3)
            )
            .addCollection(nga.collection(comment)
                .title('Last comments')
                .perPage(10)
                .fields([
                    nga.field('created_at', 'date')
                        .label('Posted'),
                    nga.field('body', 'wysiwyg')
                        .label('Comment')
                        .stripTags(true)
                        .map(truncate)
                        .isDetailLink(true),
                    nga.field('post_id', 'reference')
                        .label('Post')
                        .targetEntity(post)
                        .targetField(nga.field('title').map(truncate))
                ])
                .sortField('created_at')
                .sortDir('DESC')
                .order(2)
            )
            .addCollection(nga.collection(tag)
                .title('Tags publication status')
                .perPage(10)
                .fields([
                    nga.field('name'),
                    nga.field('published', 'boolean').label('Is published ?')
                ])
                .listActions(['show'])
                .order(4)
            )
            .template(customDashboardTemplate)
        );

        nga.configure(admin);
    }]);

    app.directive('postLink', ['$location', function ($location) {
        return {
            restrict: 'E',
            scope: { entry: '&' },
            template: '<p class="form-control-static"><a ng-click="displayPost()">View&nbsp;post</a></p>',
            link: function (scope) {
                scope.displayPost = function () {
                    $location.path('/posts/show/' + scope.entry().values.post_id); // jshint ignore:line
                };
            }
        };
    }]);

    app.directive('sendEmail', ['$location', function ($location) {
        return {
            restrict: 'E',
            scope: { post: '&' },
            template: '<a class="btn btn-default" ng-click="send()">Send post by email</a>',
            link: function (scope) {
                scope.send = function () {
                    $location.path('/sendPost/' + scope.post().values.id);
                };
            }
        };
    }]);

    // custom 'send post by email' page

    function sendPostController($stateParams, notification) {
        this.postId = $stateParams.id;
        // notification is the service used to display notifications on the top of the screen
        this.notification = notification;
    }
    sendPostController.prototype.sendEmail = function() {
        if (this.email) {
            this.notification.log('Email successfully sent to ' + this.email, {addnCls: 'humane-flatty-success'});
        } else {
            this.notification.log('Email is undefined', {addnCls: 'humane-flatty-error'});
        }
    };
    sendPostController.$inject = ['$stateParams', 'notification'];

    var sendPostControllerTemplate =
        '<div class="row"><div class="col-lg-12">' +
            '<ma-view-actions><ma-back-button></ma-back-button></ma-view-actions>' +
            '<div class="page-header">' +
                '<h1>Send post #{{ controller.postId }} by email</h1>' +
                '<p class="lead">You can add custom pages, too</p>' +
            '</div>' +
        '</div></div>' +
        '<div class="row">' +
            '<div class="col-lg-5"><input type="text" size="10" ng-model="controller.email" class="form-control" placeholder="name@example.com"/></div>' +
            '<div class="col-lg-5"><a class="btn btn-default" ng-click="controller.sendEmail()">Send</a></div>' +
        '</div>';

    app.config(['$stateProvider', function ($stateProvider) {
        $stateProvider.state('send-post', {
            parent: 'main',
            url: '/sendPost/:id',
            params: { id: null },
            controller: sendPostController,
            controllerAs: 'controller',
            template: sendPostControllerTemplate
        });
    }]);

    // custom page with menu item
    var customPageTemplate = '<div class="row"><div class="col-lg-12">' +
            '<ma-view-actions><ma-back-button></ma-back-button></ma-view-actions>' +
            '<div class="page-header">' +
                '<h1>Stats</h1>' +
                '<p class="lead">You can add custom pages, too</p>' +
            '</div>' +
        '</div></div>';
    app.config(['$stateProvider', function ($stateProvider) {
        $stateProvider.state('stats', {
            parent: 'main',
            url: '/stats',
            template: customPageTemplate
        });
    }]);

}());
