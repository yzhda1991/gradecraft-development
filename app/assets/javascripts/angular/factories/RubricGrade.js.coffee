@gradecraft.factory 'CriterionGrade', ->
	class CriterionGrade
		constructor: (attrs={})->
		  @id = attrs.id
		  @criterion_id = attrs.criterion_id
		  @level_id = attrs.level_id
		  @comments = attrs.comments
