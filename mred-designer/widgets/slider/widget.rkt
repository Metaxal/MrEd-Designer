#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         racket/gui/base)

(make-plugin
 [type 'slider]
 [tooltip "Slider"]
 [button-group "Controls"]
 [widget-class slider%]
 [parent-class container-classes]
 [necessary '(label parent min-value max-value)] ; necessary properties
 [options '(callback)]
 ( ; widget properties
  [label (prop:false-or-string "Slider")]
  [min-value 0]
  [max-value 100]
  [init-value 0]
  [callback (prop:code (λ (slider control-event) (void)))]
  [style (prop:proc
          (prop:group (prop:one-of (list 'horizontal 'vertical)
                                   'horizontal)
                      (prop:one-of '(vertical-label horizontal-label)
                                   'horizontal-label)
                      (prop:some-of '(deleted plain) '()))
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
