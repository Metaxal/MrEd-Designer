#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         racket/gui/base)

(make-plugin
 [type 'editor-canvas]
 [tooltip "Editor-Canvas"]
 [button-group "Controls"]
 [widget-class editor-canvas%]
 [parent-class container-classes]
 [necessary '(parent)]     ; necessary properties
 [options '()]
 ( ; widget properties
  [editor (prop:code #f)]
  [style (prop:popup
          (prop:some-of '(no-border
                          control-border  combo
                          no-hscroll      no-vscroll
                          hide-hscroll    hide-vscroll
                          auto-hscroll    auto-vscroll
                          resize-corner   no-focus
                          deleted         transparent)
                        '()))]
  [scrolls-per-page 100]	 
  [label (prop:false-or-string "Editor-Canvas")]
  [wheel-step (prop:false-or-number 3)]	 
  [line-count (prop:false-or-number #f)]	 
  [horizontal-inset 5]	 
  [vertical-inset 5]	 
  [enabled #t]
  [vert-margin  0]
  [horiz-margin 0]
  [min-width  0]
  [min-height 0]
  [stretchable-width  #t]
  [stretchable-height #t]
  )
 )
