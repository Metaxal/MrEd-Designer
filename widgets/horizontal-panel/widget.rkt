#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         racket/gui/base)


(make-plugin
 [type 'horizontal-panel]
 [tooltip "Horizontal Panel"]
 [button-group "Containers"]
 [widget-class horizontal-panel%]
 [parent-class container-classes]
 [necessary '(parent)]     ; necessary properties
 [options '()]
 ( ; widget properties
  [style (prop:some-of '(border deleted) '())]
  [enabled #t]
  [vert-margin 0]
  [horiz-margin 0]
  [border 0]
  [spacing 0]
  [alignment (alignment-values 'left 'center)]
  [min-width  0]
  [min-height 0]
  [stretchable-width  #t]
  [stretchable-height #t]
  ))

