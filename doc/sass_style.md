# Sass
* [Structure](#structure)
* [Classes](#classes)
* [Variables](#variables)
* [Syntax](#syntax)
* [Nesting](#nesting)
* [Mixins & Includes](#mixins-&-includes)
* [Media Queries](#media-queries)
* [Autoprefixer](#autoprefixer)

## Structure
### Directory Structure
We are following these [Sass Guidelines](https://sass-guidelin.es/) for our `app/assets/stylesheets` folder structure:
* base
  * _base.sass
  * _typography.sass
* components
 * _buttons.sass
 * _cards.sass ... etc
* layout
 * _footer.sass
 * _staff
* pages
 * _assignments.sass
* utilities
 * _mixins.sass
 * _variables.sass
* vendor
 * _froala.sass


## Classes
* Prefer dash-cased names instead of snake_case or camelCase (e.g. `.badge-icon`)
* Prefer adding styles to class rather than element or id

## Variables
Please include all variables in the `_variables.sass` file inside the `utilities` folder. This will make our styles less dependent on file ordering in our manifest file.

## Nesting
Please do not nest more than three levels deep. This makes css very hard to maintain due to specificity and then we result to using `!important` which should try to be avoided *always*.

## Mixins & Includes
* Please include all mixins in the `_mixins.sass` file inside the `utilities` folder. 
* Always use a mixin if it exists
* Consider creating a mixin if you are styling a component that can be used elsewhere in the application (e.g. `@ mixin hover-card`)

## Media Queries
Please write all media queries inline rather than including them at the end of the file. This will help us keep legacy code at a minimum as all styles related to each class are contained.

## Autoprefixer
We are using Autoprefixer to handle all vendor prefixing in post-production, so please don't add any vendor prefixes to the sass files.
