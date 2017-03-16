# Unlocks

Unlocks, as the name might suggest, allow instructors to create locked assignments, badges and grade scheme elements which can only be unlocked by a combination of assignment types, assignments, badges and courses which have achieved a certain state.

  * The UnlockableCondition concern is included in all models that can be locked and/or used as a condition
  * Conditions are stored in the UnlockCondition model, which has a polymorphic association with both the unlockable model and the model which serves as the condition
  * The UnlockState model stores the state of unlock conditions
  * There is no limit on the number of conditions that an unlockable model may have

## Unlockable Models

  * [[Assignments]]
  * [[Badges]]
  * [[Grade Scheme Elements]]

## Models Used as Conditions

  * [[Assignments]]
  * [[Assignment Types]]
  * [[Badges]]
  * [[Courses]]

## UnlockCondition Model

### Associations

The model has two belongs_to associations, both being polymorphic and with the UnlockableCondition model concern.

  * `Unlockable` - model that can be locked and unlocked
  * `Condition` - model that serves as a key or "condition" for `Unlockable`

### Instance Method

  * `name` - name of the instance of the condition (eg., the name of an assignment)
  * `unlockable_name` - name of the instance of the unlockable model
  * `is_complete_for_group?(group)` - returns true when the condition is complete for all students in the passed in group
  * `requirements_description_sentence` - creates a human readable sentence describing the requirement of the condition
