#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         racket/gui/base)

(make-plugin
 [type 'button]
 [tooltip "Button"]
 [button-group "Controls"]
 [widget-class button%]
 [parent-class container-classes]
 [necessary '(label parent callback)] ; necessary properties
 [options '(callback)]
 ( ; widget properties
  [label (label-bitmap-values "Button")] ; For backward compatibility, DO NOT modify label-bitmap-values ! use another name!
  ;[parent #f] ; NO! do NOT use the parent property!
  [callback (prop:code (lambda (button control-event) (void)))]
  ; optional
  [style (prop:some-of '(border deleted) '())]
  [font (font-values)]
  [enabled #t]
  [vert-margin 2]
  [horiz-margin 2]
  [min-width 0]
  [min-height 0]
  [stretchable-width #f]
  [stretchable-height #f]
  ))
