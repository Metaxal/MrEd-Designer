#lang racket/base

;; ##################################################################################
;; # ============================================================================== #
;; # MrEd Designer - edit-list.rkt                                                  #
;; # https://github.com/Metaxal/MrEd-Designer                                       #
;; # http://mreddesigner.lozi.org                                                   #
;; # Copyright (C) Lozi Jean-Pierre, 2004 - mailto:jean-pierre@lozi.org             #
;; # Copyright (C) Peter Ivanyi, 2007                                               #
;; # Copyright (C) Laurent Orseau, 2013                                             #
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


(require racket/gui/base
         racket/class)

(provide property-edit-list%)
(define property-edit-list%
  (class dialog%
    
    (init-field
      (empty-allowed? #f)
    )
    
    ; determines whether the Cancel or the OK button has been pressed
    (define cancel? #f)
    ; list box widget
    (define list-box-data #f)
    
    (public empty-allowed-get)
    (define (empty-allowed-get)
      empty-allowed?
    )
    
    (public empty-allowed-set)
    (define (empty-allowed-set bool)
      (set! empty-allowed? bool)
    )
    
    (public get-choices)
    (define (get-choices)
      (define (get-choices-aux i n)
        (cond
          ((= i n) '())
          (else
           (cons (send list-box-data get-string i)
                 (get-choices-aux (add1 i) n)))))
      (if (not cancel?)
        (get-choices-aux 0 (send list-box-data get-number))
        #f
      )
    )
    
    (public set-choices)
    (define (set-choices lst)
      (for-each
        (lambda (x)
          (when (not (string? x))
            (error "invalid choice for property-edit%: " x)
          )
        )
        lst
      )
      ; FIXME: clear here the text field
      (send list-box-data set lst)
    )
    
    (define (init)
      (letrec 
        ((horizontal-panel-data (new horizontal-panel%
                                     (parent this)
                                     (style '(border))
                                     ))
         (list-box-panel (new horizontal-panel% (parent horizontal-panel-data)))
         (vertical-panel-modify (new vertical-panel%
                                     (parent horizontal-panel-data)
                                     (alignment '(left top))
                                     (stretchable-width #f)))
         (message (new message% 
                       (label "Value")
                       (parent vertical-panel-modify)))
         (add-entry (λ()(let 
                            ((text (send text-field-data get-value))
                             (idx  (send list-box-data get-selection))
                             )
                          ; if something is selected, unselect it
                          (when idx
                            (send list-box-data select idx #f)
                            )
                          ; if something is typed in append to the list
                          (when (> (string-length text) 0)
                            (send list-box-data append text)))))
         (text-field-data (new text-field%
                               (parent vertical-panel-modify)
                               (min-width 100)
                               (init-value "")
                               (style '(single))
                               (label #f)
                               (stretchable-height #f)
                               [callback (λ(bt ev)(when (eq? 'text-field-enter
                                                             (send ev get-event-type))
                                                    (add-entry)))]))
         (horizontal-panel-add (new horizontal-panel% 
                                    (parent vertical-panel-modify)))

         (button-add (new button%
                          (parent horizontal-panel-add)
                          (label "Add")
                          (stretchable-width #t)
                          (stretchable-height #f)
                          (min-width 50)
                          (callback 
                            (lambda (b e)
                              (add-entry)))))
         (button-edit (new button%
                           (parent horizontal-panel-add)
                           (label "Edit")
                           (stretchable-width #t)
                           (stretchable-height #f)
                           (min-width 50)
                           (callback 
                            (lambda (b e)
                              (let 
                                ((text (send text-field-data get-value))
                                 (idx  (send list-box-data get-selection))
                                )
                                ; if something is selected and there is a typed text
                                (when (and idx (> (string-length text) 0))
                                    (send list-box-data set-string idx text)))))))
         (horizontal-panel-move (new horizontal-panel% 
                                     (parent vertical-panel-modify)))
         (button-up     (new button%
                             (parent horizontal-panel-move)
                             (label "Up")
                             (stretchable-width #t)
                             (stretchable-height #f)
                             (min-width 50)
                             (vert-margin 0)
                             (callback 
                              (lambda (b e)
                                (let 
                                  ((idx  (send list-box-data get-selection)))
                                  ; if there is a selection and it is not the first element
                                  (when (and idx (> idx 0))
                                    (let
                                      ((prev (send list-box-data get-string (- idx 1)))
                                       (curr (send list-box-data get-string idx))
                                      )
                                      (send list-box-data set-string idx prev)
                                      (send list-box-data set-string (- idx 1) curr)
                                      (send list-box-data set-selection (- idx 1))
                                      )))))))
         (button-down   (new button%
                             (parent horizontal-panel-move)
                             (label "Down")
                             (stretchable-width #t)
                             (stretchable-height #f)
                             (min-width 50)
                             (vert-margin 0)
                             (callback 
                              (lambda (b e)
                                (let 
                                  ((idx  (send list-box-data get-selection))
                                   (n    (send list-box-data get-number))
                                  )
                                  ; if there is a selection and it is not the last element
                                  (when (and idx (< idx (- n 1)))
                                    (let
                                      ((next (send list-box-data get-string (+ idx 1)))
                                       (curr (send list-box-data get-string idx))
                                      )
                                      (send list-box-data set-string idx next)
                                      (send list-box-data set-string (+ idx 1) curr)
                                      (send list-box-data set-selection (+ idx 1))
                                      )))))))
         (button-delete (new button%
                             (parent vertical-panel-modify)
                             (stretchable-width #t)
                             (label "Delete")
                             (stretchable-height #f)
                             (callback 
                              (lambda (b e)
                                (let 
                                  ((text (send text-field-data get-value))
                                   (idx  (send list-box-data get-selection))
                                   (n    (send list-box-data get-number))
                                  )
                                  ; if there is a selection and
                                  ;   empty list is allowed or
                                  ;   empty list is not allowed and there are more than 1 element
                                  (when (and idx
                                           (or empty-allowed?
                                               (and (not empty-allowed?)
                                                    (> n 1))))
                                    (send text-field-data set-value "")
                                    (send list-box-data select idx #f)
                                    (send list-box-data delete idx)))))))
         (horizontal-panel-buttons (new horizontal-panel%
                                        (parent this)
                                        (alignment '(center center))
                                        (vert-margin 2)
                                        (stretchable-height #f)
                                        (stretchable-width #t)))
         (button-ok (new button%
                         (parent horizontal-panel-buttons)
                         (min-width 70)
                         (label "OK")
                         (stretchable-width #f)
                         (stretchable-height #f)
                         (callback
                           (lambda (b e)
                             ; Ok was pressed, clear text field and hide window
                             (set! cancel? #f)
                             (send text-field-data set-value "")
                             (send this show #f)))))
         (button-cancel (new button%
                             (parent horizontal-panel-buttons)
                             (stretchable-width #f)
                             (min-width 70)
                             (label "Cancel")
                             (stretchable-height #f)
                             (callback
                               (lambda (b e)
                                 ; Cancel was pressed, clear text field and hide window
                                 (set! cancel? #t)
                                 (send text-field-data set-value "")
                                 (send this show #f)))))
        )
        (set! list-box-data (new list-box%
                                 (parent list-box-panel)
                                 (choices '())
                                 (selection #f)
                                 (style '(single vertical-label))
                                 (label "List of choices")
                                 (callback
                                   (lambda (l e)
                                     (let*
                                       ((idx (send l get-selection)))
                                       ; if there is a selection set the text in the edit box
                                       (when idx
                                         (send text-field-data 
                                               set-value 
                                               (send l get-string idx))))))))
        ; double clicking for the text field
        (let*
          ((editor (send text-field-data get-editor))
           (keymap (send editor get-keymap)))
          (send keymap add-function "all-text-select"
            (lambda (edit event) (send edit select-all)))
          (send keymap map-function "leftbuttondouble" "all-text-select")
        )
      )
    )
    
    (super-new (style '(no-caption))
               (width 300)
               (height 150)
               (border 4)
    )
    ;
    (init)
  )
)

(module+ main
  (define fr (new frame% [label "auie"]
                  [min-width 200][min-height 200]))
  (define bt (new button% [parent fr] [label "Show list"]
                  [callback (λ _ (send edl show #t))]))
  (define edl (new property-edit-list% [parent fr] [label "list"]
                   [empty-allowed? #t]))
  (send fr show #t)
  )