#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         "../project/preview.rkt" ; needed for plugin% class... ; ????  WARNING: make-plugin??
         "../frame/preview.rkt"
         racket/gui/base)

(make-plugin
  [type 'dialog]
  [tooltip "Dialog"]
  [button-group "Containers"]
  [widget-class preview-frame%] ; dialogs are modal, so use a frame for a preview
  [code-gen-class dialog%] ; for code generation. By default the same as widget-class
  [parent-class (list dialog% frame% project%)] ; can only instantiate under a frame% or under nothing
  [necessary '(label parent)] ; necessary properties
  [options '(id)]
  [no-code '(show-at-init)]
  [post-code (λ (mid) (if (send mid get-property-value 'show-at-init)
                          `(send ,(send mid get-id) show #t)
                          #f
                          ))]
  ( ; widget properties
    [label "Dialog"]
    ;[parent #f] ; NO! do NOT use the parent property!
    ; optional
    [width  (prop:false-or-number #f)]
    [height (prop:false-or-number #f)]
    [x      (prop:false-or-number #f)]
    [y      (prop:false-or-number #f)]
    [style  (prop:popup
              (prop:some-of (list 'no-caption 'resize-border 'no-sheet)
                            '()))]
    [enabled #t]	 
    [border 0]	 
    [spacing 0]	 
    [alignment (alignment-values)]
    [min-width 70]
    [min-height 30]	 
    [stretchable-width #t]
    [stretchable-height #t]
    [show-at-init #f]
    ))
