#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)


(make-plugin
 [type 'tab]
 [tooltip "Tab"]
 [button-group "Containers"]
 [widget-class 
  (class vertical-panel%
    (init parent)
    (init-field label) ; should be code-writable ??!!
    (super-new [parent 
                (send parent get-single-panel)])
    (send parent add-child-panel this label)
    )]
 [parent-class tab-panel%]
 [necessary '(parent)]     ; necessary properties
 [options '()]
 ( ; widget properties
  [label "Tab"]
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

