#lang scheme/gui

;; ##################################################################################
;; # ============================================================================== #
;; # widgets.ss                                                                     #
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

(require "mreddesigner-misc.ss")

(define/provide valued<%> 
  (interface () set-value get-value))

(define (key-code-number? k)
  (member 
   k 
   '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9
         numpad0 numpad1 numpad2 numpad3 numpad4 
         numpad5 numpad6 numpad7 numpad8 numpad9)))
          
;; A text-field that accepts only numbers
(define/provide number-field%
  (class* text-field% (valued<%>)
    (init callback)
    (super-new)
    
    (define/override (on-subwindow-char receiver event)
      (let ([k (send event get-key-code)])
        (if (key-code-number? k)
            #f
            #t)))
    
    (define/override (get-value)
      (string->number (super get-value)))
    (define/override (set-value v)
      (super set-value (number->string v)))
    ))
            
    

;; A button that asks for a file when pressed.
;; The value is initially #f.
;; Once chosen, the file path can be retrieved with get-value.
(define/provide file-button%
  (class* button% (valued<%>)
    (init [parent #f]
          [get? #t]
          [message #f]
          [directory #f]
          [extension #f]
          [style '()]
          [filters '(("Any" "*.*"))]
          [[file-callback callback] (lambda (file) (void))]
          )
    (init-field [[value filename] #f])
    
    (getter/setter value)

    (define (choose-file)
      (let ([file
             ((if get?
                  get-file put-file)
              message
              (send this get-top-level-window)
              directory
              value
              extension
              style
              filters)])
        (when file
          (send this set-value file)
          (file-callback file)
          )))
      
    (super-new
     [parent parent]
     [callback (λ _ (choose-file))]
     )
      
    ))


; pouvoir demander un fichier ou un label
; able to request a file or a label

;; A mixin to add a check-box to the side of another control
;; to enable or disable it.
;; The value of the whole widget is #f if the check-box is unchecked,
;; otherwise it is the value of the side widget.
(define/provide checkable%% 
  (mixin (valued<%> window<%>) ()
    (init parent [check-box-position 'left])
    (define cb #f)
    
    (define hp
      (new horizontal-panel%
           [parent parent]))
    
    (define (set-super)
      (super-new [parent hp]))

    (define (set-cb)
      (set! cb (new check-box% [parent hp]
                    [label ""]
                    [callback (λ _ (update-field))]
                    )))
    
    (if (symbol=? check-box-position 'right)
        (begin (set-super) (set-cb))
        (begin (set-cb) (set-super)))
    
    
    (define/override (get-value)
      (and (send cb get-value)
           (super get-value)))
    
    (define/override (set-value v)
      (send cb set-value v)
      (when v
        (super set-value v))
      )
    
    (define/private (update-field)
      (send this enable (send cb get-value)))
    
    (update-field)
    
    ))

;; Needs to implement get-value and set value to use checkable%.
;; Nothing to do by default on text-field%.
(define valued-text-field% 
  (class* text-field% (valued<%>)
    (super-new)))


#| TESTS

(define f (new frame% [label ""]))
(define cbt (new (checkable%% valued-text-field%)
                 [parent f]
                 [check-box-position 'right]
                 [label #f]; ""]
                 ))
(define fb (new (checkable%% file-button%)
                [parent f]
                [check-box-position 'right]
                [get? #f]
                [label "..."]
                [callback (λ(file)(write file))]
                ))
(define nf (new (checkable%% number-field%)
                [parent f]
                [label ""]
                [callback (λ _ (void))]
                ))

(send f show #t) 

;|#