#lang scheme/base

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)


(make-plugin
 [type 'message]
 [tooltip "Message"]
 [button-group "Controls"]
 [widget-class message%]
 [parent-class container-classes]
 [necessary '(label parent)] ; necessary properties
 [options '()]
 ( ; widget properties
  [label (label-bitmap-values "Message")] ; or: 'app 'caution 'stop !!
  [style (prop:some-of '(deleted) '())]
  [font (font-values)]
  [enabled #t]
  [vert-margin 2]
  [horiz-margin 2]
  [min-width 0]
  [min-height 0]
  [stretchable-width #f]
  [stretchable-height #f]
  [auto-resize #f]
  ))
