#lang racket/base

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         racket/gui/base)


(make-plugin
 [type 'check-box]
 [tooltip "Check Box"]
 [button-group "Controls"]
 [widget-class check-box%]
 [parent-class container-classes]
 [necessary '(label parent callback)] ; necessary properties
 [options '(callback)]
 ( ; widget properties
  [label (label-bitmap-values "Check Box")]
  ;[parent #f] ; NO! do NOT use the parent property!
  [callback (prop:code (lambda (button control-event) (void)))]
  ; optional
  [style (prop:some-of '(deleted) '())]
  [value #t]
  [font (font-values)]
  [enabled #t]
  [vert-margin 2]
  [horiz-margin 2]
  [min-width 0]
  [min-height 0]
  [stretchable-width #f]
  [stretchable-height #f]
  ))
