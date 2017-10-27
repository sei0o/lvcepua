var gulp = require('gulp');
var stylus = require("gulp-stylus");
var plumber = require("gulp-plumber");

gulp.task("stylus", function(){
  gulp.src("public/stylesheets/*.styl")
    .pipe(plumber())
    .pipe(stylus())
    .pipe(gulp.dest("public/stylesheets/"));
});

gulp.task("watch", function(){
  gulp.watch("public/stylesheets/*.styl", ["stylus"]);
})

gulp.task("default", ["stylus", "watch"]);
