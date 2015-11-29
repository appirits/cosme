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
    return @warning('"data-content" is empty.', $cosmetic) if content.length <= 0

    target = $cosmetic.data('target')
    $target = $(target)
    return @warning("Target \"#{target}\" is not found.", $cosmetic) if $target.length <= 0

    action = $cosmetic.data('action')
    switch action
      when 'before'
        $target.before(content)
      when 'after'
        $target.after(content)
      when 'replace'
        $target.replaceWith(content)
      else
        @warning("Undefined action \"#{action}\".", $cosmetic)

  warning: (message, $element = null) ->
    return unless window.console
    return unless typeof window.console.warn is 'function'

    messages = ["Cosme warning: #{message}"]
    messages.push($element) if $element

    console.warn.apply(console, messages)
