const gulp 		= require('gulp');
const elm			= require('gulp-elm');
const gutil   = require('gulp-util');
const plumber = require('gulp-plumber');
const connect = require('gulp-connect');

//file paths

const paths = {
	dest 		: 'dist',
	elm  		: 'src/*.elm',
	static 	: 'src/*.{html,css}'
};


//init elm

gulp.task('elm-init', elm.init);

//compile elm to html

gulp.task('elm', ['elm-init'], () => {
	return gulp.src(paths.elm)
		.pipe(plumber())
		.pipe(elm())
		.pipe(gulp.dest(paths.dest));
});

//move static assets to dist

gulp.task('static', () => {
	return gulp.src(paths.static)
		.pipe(plumber())
		.pipe(gulp.dest(paths.dest));
});

//watch for changes

gulp.task('watch', () => {
	gulp.watch(paths.elm, ['elm']);
	gulp.watch(paths.static, ['static']);
});

//local server

gulp.task('connect', () => {
	connect.server({
		root: 'dist',
		port : 3000
	});
});


//main gulp tasks

gulp.task('build', ['elm', 'static']);
gulp.task('default', ['connect', 'build', 'watch']);