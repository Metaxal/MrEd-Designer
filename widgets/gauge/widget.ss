#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)

(make-plugin
 [type 'gauge]
 [tooltip "Gauge"]
 [button-group "Controls"]
 [widget-class gauge%]
 [parent-class container-classes]
 [necessary '(label parent range)] ; necessary properties
 [options '(callback)]
 ( ; widget properties
  [label (prop:false-or-string "Gauge")]
  [range 100]
  ; optional
  [style (prop:proc
          (prop:group (prop:one-of (list 'horizontal 'vertical)
                                   'horizontal)
                      (prop:one-of '(vertical-label horizontal-label)
                                   'horizontal-label)
                      (prop:some-of '(deleted) '()))
          (λ(l)(list* (first l) (second l) (third l))))]
  [font (font-values)]
  [enabled #t]
  [vert-margin 2]
  [horiz-margin 2]
  [min-width 0]
  [min-height 0]
  [stretchable-width #f]
  [stretchable-height #f]
  ))
