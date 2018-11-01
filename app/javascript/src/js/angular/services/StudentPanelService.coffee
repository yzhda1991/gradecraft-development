# Manages state for the student side panel.

gradecraft.factory 'StudentPanelService', [ 'GradeCraftAPI', (GradeCraftAPI)->

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  # Show the helpful hint when the page loads
  _showHint = true

  # A single model who's details will be visible in the side panel
  _focusArticle = null

  showingHint = ()->
    _showHint

  clearInfoHint = ()->
    _showHint = false

  changeFocusArticle = (article)->
    _showHint = false
    _focusArticle = article

  isFocusArticle = (article)->
    _focusArticle && _focusArticle.id == article.id

  focusArticle = ()->
    _focusArticle

  return {
    termFor: termFor
    showingHint: showingHint
    focusArticle: focusArticle
    clearInfoHint: clearInfoHint
    isFocusArticle: isFocusArticle
    changeFocusArticle: changeFocusArticle
  }
]
