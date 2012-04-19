#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)


(make-plugin
 [type 'combo-field]
 [tooltip "Combo Field"]
 [button-group "Controls"]
 [widget-class combo-field%]
 [parent-class container-classes]
 [necessary '(label choices parent)] ; necessary properties
 [options '(callback)]
 ( ; widget properties
  [label "Combo Field"]
  [choices '("First" "Second")]
  [callback (prop:code (lambda (combo-field control-event) (void)))]
  [init-value "Text"]
  [style (prop:proc
          (prop:group (prop:one-of '(vertical-label horizontal-label)
                                   'horizontal-label)
                      (prop:some-of '(deleted) '()))
          (λ(l)(list* (first l) (second l))))]
  [font (font-values)]
  [enabled #t]
  [vert-margin 2]
  [horiz-margin 2]
  [min-width 0]
  [min-height 0]
  [stretchable-width #f]
  [stretchable-height #f]
  ))
