#lang racket

(require "../../mred-id.rkt"
         "../../controller.rkt"
         "../../toolbox-frame.rkt"
         racket/gui/base)

(provide preview-frame%)
(define preview-frame%
  (class frame%
    (init parent)
    (init-field [show-at-init #t])
    (super-new [parent (or (and (is-a? parent frame%) parent) toolbox-frame)])
    (define/override (on-subwindow-event w e)
      (when (and (equal? (send e get-event-type) 'left-down)
                 (is-a? w mred-widget<%>))
        (controller-select-mred-id (send w get-mred-id))
        )
      ;#t;#f ; don't propagate the event down the chain; (?)
      #f
      )
    
    ;; Every widget is a mred-widget%%, so this works...
    ;(define/override (on-move x y)
    ;  (send (send this get-mred-id) change-property-value 'x x)
    ;  (send (send this get-mred-id) change-property-value 'y y)
    ;  )

;    (define/override (on-size w h)
;      (send (send this get-mred-id) change-property-value 'width w)
;      (send (send this get-mred-id) change-property-value 'height h)
;      )

    (send this show show-at-init);#t)
    ))
