#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)


(make-plugin
 [type 'pane]
 [tooltip "Pane"]
 [button-group "Containers"]
 [widget-class pane%]
 [parent-class container-classes]
 [necessary '(parent)]     ; necessary properties
 [options '()]
 ( ; widget properties
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

