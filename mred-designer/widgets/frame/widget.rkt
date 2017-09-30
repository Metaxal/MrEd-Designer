#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         "preview.rkt"
         "../project/preview.rkt" ; needed for plugin% class... ; ????  WARNING: make-plugin??
         racket/gui/base)

(make-plugin
 [type 'frame]
 [tooltip "Frame"]
 [button-group "Containers"]
 [widget-class preview-frame%]
 [code-gen-class frame%] ; for code generation. By default the same as widget-class
 [parent-class (list frame% project%)] ; can only instantiate under a frame% or a project%
 [necessary '(label parent)] ; necessary properties
 [options '(id)]
 [no-code '(show-at-init)]
 [post-code (λ(mid)(if (send mid get-property-value 'show-at-init)
                       `(send ,(send mid get-id) show #t)
                       #f
                       ))]
 ( ; widget properties
  [label "Frame"]
  ;[parent #f] ; NO! do NOT use the parent property!
  ; optional
  [width  (prop:false-or-number #f)]
  [height (prop:false-or-number #f)]
  [x      (prop:false-or-number #f)]
  [y      (prop:false-or-number #f)]
  [style (prop:popup
          (prop:some-of '(no-resize-border 
                          no-caption no-system-menu hide-menu-bar
                          toolbar-button float metal
                          fullscreen-button fullscreen-aux)
                        '()))]
  [enabled #t]	 
  [border 0]	 
  [spacing 0]	 
  [alignment (alignment-values)]
  [min-width 70]
  [min-height 30]	 
  [stretchable-width #t]
  [stretchable-height #t]
  [show-at-init #t]
  ))
