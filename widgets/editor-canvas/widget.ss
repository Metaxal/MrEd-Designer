#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)

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
  [label "Editor-Canvas"]
  [wheel-step 3]	 
  [line-count  (prop:false-or-number #f)]	 
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
