# Manages state for the student side panel. Only in place on the Predictor Page
# for now, but built to accomodate side panels on other pages.

@gradecraft.factory 'StudentPanelService', [ ()->

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
    showingHint: showingHint
    focusArticle: focusArticle
    clearInfoHint: clearInfoHint
    isFocusArticle: isFocusArticle
    changeFocusArticle: changeFocusArticle
  }
]
