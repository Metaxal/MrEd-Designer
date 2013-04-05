#lang racket/gui

;; ##################################################################################
;; # ============================================================================== #
;; # property-frame.rkt                                                             #
;; # http://mred-designer.origo.ethz.ch                                             #
;; # Copyright (C) Laurent Orseau, 2010                                             #
;; # ============================================================================== #
;; #                                                                                #
;; # This program is free software; you can redistribute it and/or                  #
;; # modify it under the terms of the GNU General Public License                    #
;; # as published by the Free Software Foundation; either version 2                 #
;; # of the License, or (at your option) any later version.                         #
;; #                                                                                #
;; # This program is distributed in the hope that it will be useful,                #
;; # but WITHOUT ANY WARRANTY; without even the implied warranty of                 #
;; # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  #
;; # GNU General Public License for more details.                                   #
;; #                                                                                #
;; # You should have received a copy of the GNU General Public License              #
;; # along with this program; if not, write to the Free Software                    #
;; # Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.    #
;; #                                                                                #
;; ##################################################################################


(require "misc.rkt"
         "preview-widgets.rkt"
         "properties.rkt"
         "property-widgets.rkt"
         )

(define/provide property-frame #f)
(define/provide (show-property-frame)
  (send property-frame show #t))

(define current-prop-panel #f)

(define update-callback #f)

(define/provide (make-property-frame 
                  [parent #f]
                  #:update-callback update-cb
                  )
  (set! update-callback update-cb)
  (let-values ([(screen-w screen-h) (get-display-size)])
    (set! property-frame
          (new frame% 
               [label "Properties"]
               [parent parent]
               [x (- screen-w 320)]
               [y 5]
               [min-width 300]
               [stretchable-width #f]
               [stretchable-height #f])))
  (set! current-prop-panel (make-properties-panel #f))
  )

;(define widget-properties #f)
;(define (make-properties parent properties)
;  (set! widget-properties
;        (field-id-properties->widgets properties)))

(define prop-panel-hash (make-weak-hasheq))
; references are not kept if not necessary!

(define (make-properties-panel mid)
  (debug-printf "make-properties-panel: creating a new prop-panel for ~a\n" (and mid (send mid get-id)))
  (let ([vp (new vertical-panel% [parent property-frame])])
    (if mid
        (let ([prop-widgets ; add all the property widgets:
               (parameterize ([current-property-mred-id mid])
                 (field-id-properties->widgets vp (send mid get-properties)))])
          ; add an update button:
          (new button% 
               [parent vp]
               [label "Apply && Update Preview"]
               [style '(border)]
               [callback (λ _ 
                           (debug-printf "make-properties-panel: update enter\n")
                           (for-each (λ(p)(when p (send p commit))) prop-widgets)
                           (update-callback)
                           (debug-printf "make-properties-panel: update exit\n")
                           )])
          )
        ; else
        (let ([vp2 (new vertical-panel% 
                        [parent vp]
                        [min-height 300]
                        [alignment '(center center)])])
          (new message% [parent vp2]
                        [label "No widget selected."]))
        )
    ; return value :
    vp
    ))

(define/provide (update-property-frame mid)
  (send property-frame begin-container-sequence)
  (send property-frame change-children (λ(l)'())) ; remove all children
  (set! current-prop-panel
        (hash-ref! prop-panel-hash mid 
                   (λ()(make-properties-panel mid))))
  (send property-frame change-children 
        (λ(l)(list current-prop-panel)))
  (send property-frame end-container-sequence)
  )
