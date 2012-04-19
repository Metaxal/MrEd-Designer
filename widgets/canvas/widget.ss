#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)


(make-plugin
 [type 'canvas]
 [tooltip "Canvas"]
 [button-group "Controls"]
 [widget-class canvas%]
 [parent-class container-classes]
 [necessary '(parent)]     ; necessary properties
 [options '(paint-callback)]
 ( ; widget properties
  [style (prop:some-of (list 'border 'control-border 'combo
                             'vscroll 'hscroll 'resize-corner
                             'gl 'no-autoclear 'transparent
                             'no-focus 'deleted)
                       '())]
  [paint-callback (prop:code (λ (canvas dc) (void)))]
  [label "Canvas"]
  [gl-config #f]
  [enabled #t]
  [vert-margin  2]
  [horiz-margin 2]
  [min-width  0]
  [min-height 0]
  [stretchable-width  #t]
  [stretchable-height #t]
  ))

