#lang scheme

(require "../../mred-plugin.ss"
         "../../mreddesigner-misc.ss"
         "../../default-values.ss"
         "../../controller.ss"
         scheme/gui/base
         framework
         )

(define tab-panel-preview%
  (class tab-panel% (super-new)
    (define single-panel (new panel:single% [parent this]))
    (define/public (get-single-panel) single-panel)
    (define child-panels '())
    (define/public (add-child-panel p label)
      (set! child-panels (append child-panels (list p)))
      (send this append label))
    
    (define/public (active-child n)
      (if (empty? child-panels)
          (controller-select-mred-id (send this get-mred-id))
          (let ([child-panel (list-ref child-panels n)])
            (send single-panel active-child child-panel)
            (controller-select-mred-id (send child-panel get-mred-id))
            )))
    
    (define/override (delete-child c)
      (send single-panel delete-child c)
      (send this delete (list-pos child-panels c))
      (set! child-panels (remq c child-panels))
      (send this refresh)
      )
    ))

(make-plugin
 [type 'tab-panel]
 [tooltip "Tab Panel"]
 [button-group "Containers"]
 [widget-class tab-panel-preview%]
 [code-gen-class 
 ; here we could now use `precode' to avoid writing this class each time:
  (class tab-panel% (super-new)
    (define single-panel (new panel:single% [parent this]))
    (define/public (get-single-panel) single-panel)
    (define child-panels '())
    (define/public (add-child-panel p label)
      (set! child-panels (append child-panels (list p)))
      (send this append label))
    
    (define/public (active-child n)
      (send single-panel active-child (list-ref child-panels n)))
    )]
 [parent-class container-classes]
 [necessary '(parent choices)]     ; necessary properties
 [options '()]
 ( ; widget properties
  [choices '()]
  [callback (prop:code (λ(tp e)
                         (send tp active-child (send tp get-selection))))] 
  [style (prop:some-of '(no-border deleted) '())]
  [enabled #t]
  [vert-margin 0]
  [horiz-margin 0]
  [border 0]
  [spacing 0]
  [alignment (alignment-values 'center 'center)]
  [min-width  0]
  [min-height 0]
  [stretchable-width  #t]
  [stretchable-height #t]
  ))

