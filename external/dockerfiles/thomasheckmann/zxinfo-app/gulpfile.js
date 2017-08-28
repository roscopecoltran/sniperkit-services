'use strict';

var gulp = require('gulp');
var gulpNgConfig = require('gulp-ng-config');

gulp.task('config', function() {
	gulp.src('config.json')
		.pipe(gulpNgConfig('SinclairAppCfg', {
			environment: process.env.NODE_ENV
		}))
		.pipe(gulp.dest('public/javascripts'));
});