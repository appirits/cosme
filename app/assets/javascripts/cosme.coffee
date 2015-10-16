$( ->
  new Cosme
)

class Cosme
  constructor: ->
    _this = @
    $('.cosmetic').each( ->
      _this.create($(this))
    )

  create: ($cosmetic) ->
    content = $cosmetic.data('content')
    return false if content.length <= 0

    target = $cosmetic.data('target')
    $target = $(target)
    return false if $target.length <= 0

    action = $cosmetic.data('action')
    switch action
      when 'before'
        $target.before(content)
      when 'after'
        $target.after(content)
      when 'replace'
        $target.replaceWith(content)
      else
        false
