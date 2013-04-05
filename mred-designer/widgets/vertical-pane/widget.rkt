#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         racket/gui/base)


(make-plugin
 [type 'vertical-pane]
 [tooltip "Vertical Pane"]
 [button-group "Containers"]
 [widget-class vertical-pane%]
 [parent-class container-classes]
 [necessary '(label parent)]     ; necessary properties
 [options '()]
 ( ; widget properties
  ; optional
  [vert-margin 0]
  [horiz-margin 0]
  [border 0]
  [spacing 0]
  [alignment (alignment-values)]
  [min-width  0]
  [min-height 0]
  [stretchable-width  #t]
  [stretchable-height #t]
  ))

