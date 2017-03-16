## Level Badges

  * Level Badges are Badges attached to Levels that students earn
  * Unlike Badges, Level Badges have no impact on students' scores
  * The only Badge attributes used for Level Badges are `name` and `icon`

### Level Badge Model

#### Associations

##### belongs_to

The `updated_at` attributes in the following models will be set to the current date when one of its badges is set.

  * [[Level | rubrics]]
  * Badge
