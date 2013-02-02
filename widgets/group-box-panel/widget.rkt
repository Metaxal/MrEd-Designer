#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         racket/gui/base)


(make-plugin
 [type 'group-box-panel]
 [tooltip "Group-Box-Panel"]
 [button-group "Containers"]
 [widget-class group-box-panel%]
 [parent-class container-classes]
 [necessary '(label parent)]     ; necessary properties
 [options '()]
 ( ; widget properties
  [label "Group Box Panel"]
  ; optional
  [style (prop:some-of '(deleted) '())]
  [font (font-values)]
  [enabled #t]
  [vert-margin  2]
  [horiz-margin 2]
  [border  0]
  [spacing 0]
  [alignment (alignment-values)]
  [min-width  0]
  [min-height 0]
  [stretchable-width  #t]
  [stretchable-height #t]
  ))

