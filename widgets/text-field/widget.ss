#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)

(make-plugin
 [type 'text-field]
 [tooltip "Text Field"]
 [button-group "Controls"]
 [widget-class text-field%]
 [parent-class container-classes]
 [necessary '(label parent)] ; necessary properties
 [options '(callback)]
 ( ; widget properties
  [label (prop:false-or-string "Text Field")]
  [callback (prop:code (lambda (text-field control-event) (void)))]
  [init-value "Text"]
  [style (prop:proc
          (prop:group (prop:one-of '(single multiple)
                                   'single)
                      (prop:one-of '(vertical-label horizontal-label)
                                   'horizontal-label)
                      (prop:some-of '(hscroll password deleted) '()))
          (λ (l) (list* (first l) (second l) (third l))))]
  [font (font-values)]
  [enabled #t]
  [vert-margin 2]
  [horiz-margin 2]
  [min-width 0]
  [min-height 0]
  [stretchable-width #f]
  [stretchable-height #f]
  ))
